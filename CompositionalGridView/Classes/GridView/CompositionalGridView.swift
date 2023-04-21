//
//  CompositionalGridView.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/14/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Combine
import UIKit

// MARK: CompositionalGridViewDelegate

public protocol CompositionalGridViewDelegate: AnyObject {
    func gridViewDidTriggerLoadMore(_ gridView: CompositionalGridView)
    func gridViewDidTriggerReload(_ gridView: CompositionalGridView)
    func gridViewDidSelectItem(_ gridView: CompositionalGridView, item: GridItemModelConfigurable)
    func gridViewDidTriggerEvent(_ gridView: CompositionalGridView, event: GridCellEvent)
}

public extension CompositionalGridViewDelegate {
    func gridViewDidTriggerLoadMore(_ gridView: CompositionalGridView) {}
    func gridViewDidTriggerReload(_ gridView: CompositionalGridView) {}
    func gridViewDidSelectItem(_ gridView: CompositionalGridView, item: GridItemModelConfigurable) {}
    func gridViewDidTriggerEvent(_ gridView: CompositionalGridView, event: GridCellEvent) {}
}

// MARK: CompositionalGridView

private typealias GridViewDataSource = UICollectionViewDiffableDataSource<Int, GridViewItem>

public final class CompositionalGridView: UIView {

    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: createLayout())
        collectionView.fill(in: self)
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Private
    
    private weak var delegate: CompositionalGridViewDelegate?
    private var containerViewController: UIViewController?
    private var registedReuseIdentifiers = Set<String>()
    private var selfHandlingViews: [String: Any] = [:]
    @Published private var selfHandlingItems: [SelfHandlingItemModel: Bool] = [:]
    @Published private var items: [GridItemModelConfigurable] = []
    @Published private var hasNext: Bool = false
    @Published private var settings: GridViewSettings = GridViewSettings()
    private let loadMoreTrigger = PassthroughSubject<Void, Never>()
    // Store subscriptions
    private var subscriptions: Set<AnyCancellable> = []

    private lazy var dataSource: GridViewDataSource = createDataSource()
    private var viewModel: GridViewModel? {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Int, GridViewItem>()
            let sections = viewModel?.sections ?? []
            for section in sections {
                snapshot.appendSections([section.index])
                snapshot.appendItems(section.items)
            }
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
                
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        Publishers
            .CombineLatest4($items, $selfHandlingItems, $hasNext.removeDuplicates(), $settings.removeDuplicates())
            .debounce(for: .milliseconds(10), scheduler: DispatchQueue.global())
            .map { items, selfHandlingItems, hasNext, settings -> GridViewModel in
                let allItems = items + selfHandlingItems.keys.filter { selfHandlingItems[$0] == true }
                return GridViewModel(items: allItems, hasLoadMore: hasNext && settings.isLoadMoreEnabled)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModel in
                viewModel.allItems.forEach { self?.registerCellIfNeeded(for: $0) }
                self?.viewModel = viewModel
            }
            .store(in: &subscriptions)
        
        loadMoreTrigger
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self, self.isLoadMoreAvailable else { return }
                self.delegate?.gridViewDidTriggerLoadMore(self)
            }
            .store(in: &subscriptions)
        
        $settings.removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateSettings($0) }
            .store(in: &subscriptions)
    }
    
    private func updateSettings(_ settings: GridViewSettings) {
        if settings.isScrollEnabled {
            collectionView.contentInsetAdjustmentBehavior = .automatic
        } else {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = settings.backgroundColor
        collectionView.refreshControl = settings.isReloadEnabled ? refreshControl : nil
        collectionView.contentInset = settings.contentInset
        collectionView.isScrollEnabled = settings.isScrollEnabled
        if !settings.isLoadMoreEnabled {
            endLoading()
        }
    }
    
    private func registerCellIfNeeded(for item: GridViewItem) {
        guard !registedReuseIdentifiers.contains(item.model.reuseIdentifier) else { return }
        registedReuseIdentifiers.insert(item.model.reuseIdentifier)
        collectionView.registerCell(for: item.model)
    }
    
    private func addSelfHandlingViewIfNeeded(to cell: SelfHandlingCell, model: GridItemModelConfigurable) {
        guard let itemView = selfHandlingViews[model.identity] else { return }
        if let viewController = itemView as? UIViewController {
            containerViewController.flatMap {
                guard viewController.parent !== $0 else { return }
                $0.addChild(viewController)
                viewController.didMove(toParent: $0)
            }
            cell.addViewIfNeeded(viewController.view)
        } else if let view = itemView as? UIView {
            cell.addViewIfNeeded(view)
        }
    }
    
    private func endLoading() {
        collectionView.refreshControl?.endRefreshing()
    }
    
    @objc
    private func pullToRefresh() {
        delegate?.gridViewDidTriggerReload(self)
    }
    
    private var isLoadMoreAvailable: Bool { settings.isLoadMoreEnabled && hasNext }
}

extension CompositionalGridView {
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIdx, environment -> NSCollectionLayoutSection? in
            self?.viewModel?.makeLayoutSection(sectionIdx, environment: environment)
        }
    }
    
    private func createDataSource() -> GridViewDataSource {
        GridViewDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, data -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.model.reuseIdentifier, for: indexPath)
            switch data.model.viewType {
            case .cell:
                guard let gridCell = cell as? GridCellConfigurable else { return cell }
                gridCell.handleEvent { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.gridViewDidTriggerEvent(self, event: $0)
                }
                return gridCell.configure(data.model)
            case .selfHandling:
                guard let selfHandlingCell = cell as? SelfHandlingCell else { return cell }
                self?.addSelfHandlingViewIfNeeded(to: selfHandlingCell, model: data.model)
            }
            return cell
        }
    }
}

extension CompositionalGridView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sections = viewModel?.sections else { return }
        guard let section = (sections.first { $0.index == indexPath.section }) else { return }
        guard indexPath.row < section.items.count else { return }
        delegate?.gridViewDidSelectItem(self, item: section.items[indexPath.row].model)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isLoadMoreAvailable, scrollView === collectionView else { return }
        if collectionView.shouldTriggerLoadmoreRightNow {
            loadMoreTrigger.send(())
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard cell is LoadMoreCell else { return }
        loadMoreTrigger.send(())
    }
}

// MARK: - publics

extension CompositionalGridView {
    public func updateItems(_ items: [GridItemModelConfigurable], hasNext: Bool = false) {
        endLoading(hasNext: hasNext)
        self.items = items
    }
    
    public func setDelegate(_ delegate: CompositionalGridViewDelegate) {
        self.delegate = delegate
    }
    
    public func endLoading(hasNext: Bool) {
        self.hasNext = hasNext
        endLoading()
    }
    
    public func addTo(_ view: UIView, in viewController: UIViewController? = nil) {
        containerViewController = viewController
        fill(in: view)
    }
    
    public func addSelfHandlingLogicItem(_ item: SelfHandlingItemModel, viewController: UIViewController, isHidden: Bool) {
        selfHandlingViews[item.identity] = viewController
        selfHandlingItems[item] = !isHidden
    }

    public func addSelfHandlingLogicItem(_ item: SelfHandlingItemModel, view: UIView, isHidden: Bool) {
        selfHandlingViews[item.identity] = view
        selfHandlingItems[item] = !isHidden
    }
    
    public func setHiddenItem(_ isHidden: Bool, identity: String) {
        guard let item = selfHandlingItems.keys.first(where: { $0.identity == identity }) else { return }
        selfHandlingItems[item] = !isHidden
    }
    
    public func setSettings(_ settings: GridViewSettings) {
        self.settings = settings
    }
}

// CompositionalGridView+UICollectionView

extension CompositionalGridView {
    public var contentSize: CGSize { collectionView.contentSize }
    public var contentOffset: CGPoint { collectionView.contentOffset }
    public var visibleCells: [UICollectionViewCell] { collectionView.visibleCells }
    
    public func updateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
        
    public func scrollToOffset(_ offset: CGPoint, animated: Bool) {
        collectionView.setContentOffset(offset, animated: animated)
    }
    
    public func scrollToItem(at index: IndexPath, scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        collectionView.scrollToItem(at: index, at: scrollPosition, animated: animated)
    }
    
    public func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        collectionView.indexPath(for: cell)
    }
    
    public func indexPath(for item: GridItemModelConfigurable) -> IndexPath? {
        guard let section = viewModel?.sections.first(where: { $0.containsItem(item) }) else { return nil }
        guard let row = section.index(of: item) else { return nil }
        return IndexPath(row: row, section: section.index)
    }
}

// CompositionalGridView+Combine

extension CompositionalGridView {
    public var contentSizePublisher: AnyPublisher<CGSize, Never> {
        collectionView.publisher(for: \.contentSize, options: [.new]).eraseToAnyPublisher()
    }
    
    public var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        collectionView.publisher(for: \.contentOffset, options: [.new]).eraseToAnyPublisher()
    }
}

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
    
    /// Tells the delegate that the grid view needs to load more data.
    ///
    /// - Parameter gridView: The `CompositionalGridView` instance that triggered the event.
    func gridViewDidTriggerLoadMore(_ gridView: CompositionalGridView)
    
    /// Tells the delegate that the grid view needs to reload data.
    ///
    /// - Parameter gridView: The `CompositionalGridView` instance that triggered the event.
    func gridViewDidTriggerReload(_ gridView: CompositionalGridView)
    
    /// Tells the delegate that an item in the grid view was selected.
    ///
    /// - Parameters:
    ///   - gridView: The `CompositionalGridView` instance that triggered the event.
    ///   - item: The `GridItemModelConfigurable` instance that was selected.
    func gridViewDidSelectItem(_ gridView: CompositionalGridView, item: GridItemModelConfigurable)
    
    /// Tells the delegate that an event occurred in a grid cell.
    ///
    /// - Parameters:
    ///   - gridView: The `CompositionalGridView` instance that triggered the event.
    ///   - event: The `GridCellEvent` instance that occurred.
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
    private weak var containerViewController: UIViewController?
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
        collectionView.contentInset = UIEdgeInsets(top: settings.contentInset.top,
                                                   left: 0,
                                                   bottom: settings.contentInset.bottom,
                                                   right: 0)
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
            guard let self = self else { return nil }
            let contentSize = environment.container.contentSize
            let contentInsets = self.settings.contentInset
            return self.viewModel?
                .makeLayoutSection(sectionIdx, containerContentSize: contentSize, containerContentInsets: contentInsets)?
                .layoutSection
        }
    }
    
    private func createDataSource() -> GridViewDataSource {
        let source = GridViewDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, data -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.model.reuseIdentifier, for: indexPath)
            switch data.model.viewType {
            case .cell:
                guard let gridCell = cell as? (any GridCellConfigurable) else { return cell }
                gridCell.handleEvent { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.gridViewDidTriggerEvent(self, event: $0)
                }
                return gridCell.configureModel(data.model) ?? cell
            case .selfHandling:
                guard let selfHandlingCell = cell as? SelfHandlingCell else { return cell }
                self?.addSelfHandlingViewIfNeeded(to: selfHandlingCell, model: data.model)
            case .header, .footer: return nil
            }
            return cell
        }
        
        source.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let item = self?.viewModel?.supplementaryItemOfSection(indexPath.section, kind: kind)
            guard let model = item?.model else { return nil }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: model.reuseIdentifier, for: indexPath)
            guard let gridView = view as? (any GridSupplementaryViewConfigurable) else { return view }
            gridView.handleEvent { [weak self] in
                guard let self = self else { return }
                self.delegate?.gridViewDidTriggerEvent(self, event: $0)
            }
            return gridView.configureModel(model) ?? view
        }
        
        return source
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
    
    /// Updates the items in the grid view with new data.
    ///
    /// Use this method to update the items displayed in the grid view with new data.
    ///
    /// - Parameters:
    ///   - items: The new items to display in the grid view.
    ///   - hasNext: A Boolean value that indicates whether there is more data available to load.
    public func updateItems(_ items: [GridItemModelConfigurable], hasNext: Bool = false) {
        endLoading(hasNext: hasNext)
        self.items = items
    }
    
    /// Sets the delegate for the grid view.
    ///
    /// Use this method to set the delegate for the `CompositionalGridView` instance.
    /// The delegate must conform to the `CompositionalGridViewDelegate` protocol, which defines methods for handling events in the grid view.
    ///
    /// - Parameter delegate: The delegate to set for the grid view.
    public func setDelegate(_ delegate: CompositionalGridViewDelegate) {
        self.delegate = delegate
    }
    
    /// Ends the loading animation in the grid view.
    ///
    /// - Parameter hasNext: A Boolean value that indicates whether there is more data available to load.
    public func endLoading(hasNext: Bool) {
        self.hasNext = hasNext
        endLoading()
    }
    
    /// Adds the grid view to a specified view and view controller.
    ///
    /// Use this method to add the `CompositionalGridView` instance to a specified view and view controller.
    /// The `view` parameter is the view to which the grid view is added, and the optional `viewController` parameter is the view controller that manages the view.
    ///
    /// - Parameters:
    ///   - view: The view to which to add the grid view.
    ///   - viewController: The view controller that manages the view.
    ///   - contraints: The closure to customize the constraints for the layout of the grid view within the provided view. By default, the grid view is constrained to the edges of the provided view.
    public func addTo(
        _ view: UIView,
        in viewController: UIViewController? = nil,
        contraints: (UIView, UIView) -> Void = { container, gridView in
            container.addSubview(gridView)
            gridView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gridView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                gridView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                gridView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                gridView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        }
    ) {
        containerViewController = viewController
        contraints(view, self)
    }
    
    /// Adds a self-handling logic item to the grid view.
    ///
    /// Use this method to add a `SelfHandlingItemModel` instance, which is an item that handles its own events, to the `CompositionalGridView` instance.
    ///
    /// - Parameters:
    ///   - item: The item to add to the grid view.
    ///   - viewController: The view controller that links to the item.
    ///   - isHidden: A Boolean value that indicates whether the item is initially hidden.
    public func addSelfHandlingLogicItem(_ item: SelfHandlingItemModel, viewController: UIViewController, isHidden: Bool) {
        selfHandlingViews[item.identity] = viewController
        selfHandlingItems[item] = !isHidden
    }

    /// Adds a self-handling logic item to the grid view.
    ///
    /// Use this method to add a `SelfHandlingItemModel` instance, which is an item that handles its own events, to the `CompositionalGridView` instance.
    ///
    /// - Parameters:
    ///   - item: The item to add to the grid view.
    ///   - view: The view that links to the item.
    ///   - isHidden: A Boolean value that indicates whether the item is initially hidden.
    public func addSelfHandlingLogicItem(_ item: SelfHandlingItemModel, view: UIView, isHidden: Bool) {
        selfHandlingViews[item.identity] = view
        selfHandlingItems[item] = !isHidden
    }
    
    /// Sets the hidden state of a self-handling item with the specified identity.
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that indicates whether the item should be hidden.
    ///   - identity: A unique string that identifies the self-handling item.
    public func setHiddenItem(_ isHidden: Bool, identity: String) {
        guard let item = selfHandlingItems.keys.first(where: { $0.identity == identity }) else { return }
        selfHandlingItems[item] = !isHidden
    }
    
    /// Sets the settings for the grid view.
    ///
    /// Use this method to set the `GridViewSettings` instance, which defines the appearance and behavior of the `CompositionalGridView` instance.
    ///
    /// - Parameter settings: The settings to set for the grid view.
    public func setSettings(_ settings: GridViewSettings) {
        self.settings = settings
    }
}

// CompositionalGridView+UICollectionView

extension CompositionalGridView {
    
    /// The size of the grid view’s content area.
    public var contentSize: CGSize { collectionView.contentSize }
    
    /// The current scroll offset of the grid view’s content.
    public var contentOffset: CGPoint { collectionView.contentOffset }
    
    /// An array of cells that are currently visible in the grid view.
    /// This array includes cells that are fully or partially visible in the grid view’s content area.
    public var visibleCells: [UICollectionViewCell] { collectionView.visibleCells }
    
    /// Updates the layout of the grid view.
    public func updateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    /// Reloads all of the data for the grid view.
    public func reloadData() {
        collectionView.reloadData()
    }
      
    /// Scrolls the grid view’s content to the specified offset.
    ///
    /// - Parameters:
    ///   - offset: The point at which to set the content offset. The point is specified in the grid view's bounds coordinates.
    ///   - animated: A Boolean value that determines whether the scrolling should be animated.
    public func scrollToOffset(_ offset: CGPoint, animated: Bool) {
        collectionView.setContentOffset(offset, animated: animated)
    }
    
    /// Scrolls the grid view’s content so that the specified item is visible.
    ///
    /// - Parameters:
    ///   - index: The index path of the item to scroll to.
    ///   - scrollPosition: An option that specifies where the item should be positioned when scrolling finishes.
    ///   - animated: A Boolean value that determines whether the scrolling should be animated.
    public func scrollToItem(at index: IndexPath, scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        collectionView.scrollToItem(at: index, at: scrollPosition, animated: animated)
    }
    
    /// Returns the index path of the specified cell.
    ///
    /// - Parameter cell: A cell object belonging to the grid view.
    /// - Returns: The index path of the cell or `nil` if the specified cell is not visible or is not a cell in the grid view.
    public func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        collectionView.indexPath(for: cell)
    }
    
    /// Returns the index path of the specified item.
    ///
    /// - Parameter item: An item conforming to the `GridItemModelConfigurable` protocol.
    /// - Returns: The index path of the item or `nil` if the specified item is not in the grid view.
    public func indexPath(for item: GridItemModelConfigurable) -> IndexPath? {
        guard let section = viewModel?.sections.first(where: { $0.containsItem(item) }) else { return nil }
        guard let row = section.index(of: item) else { return nil }
        return IndexPath(row: row, section: section.index)
    }
}

// CompositionalGridView+Combine

extension CompositionalGridView {
    
    /// A publisher emitting the content size of the grid view.
    ///
    /// Use this publisher to receive notifications when the content size of the `CompositionalGridView` instance changes.
    /// The publisher emits the content size as a `CGSize` value and never fails.
    public var contentSizePublisher: AnyPublisher<CGSize, Never> {
        collectionView.publisher(for: \.contentSize, options: [.new]).eraseToAnyPublisher()
    }
    
    /// A publisher emitting the content offset of the grid view.
    ///
    /// Use this publisher to receive notifications when the content offset of the `CompositionalGridView` instance changes.
    /// The publisher emits the content offset as a `CGPoint` value and never fails.
    public var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        collectionView.publisher(for: \.contentOffset, options: [.new]).eraseToAnyPublisher()
    }
}

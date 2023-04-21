//
//  GridViewController.swift
//  CompositionalGridView_Example
//
//  Created by tiennv166 on 21/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Combine
import CompositionalGridView

final class GridViewController: UIViewController {
    
    private lazy var gridView = CompositionalGridView()
    
    @Published var settings: GridViewSettings = GridViewSettings(isReloadEnabled: true, isLoadMoreEnabled: true)
    @Published var items: [GridItemModelConfigurable] = []
    @Published var hasNext: Bool = false
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureGridView()
    }
    
    private func configureGridView() {
        gridView.addTo(view, in: self)
        gridView.setDelegate(self)
        
        $settings.removeDuplicates()
            .sink { [weak self] in self?.gridView.setSettings($0) }
            .store(in: &subscriptions)
        
        Publishers
            .CombineLatest($items, $hasNext)
            .sink { [weak self] items, hasNext in self?.gridView.updateItems(items, hasNext: hasNext) }
            .store(in: &subscriptions)
    }
}

extension GridViewController: CompositionalGridViewDelegate {
    func gridViewDidTriggerReload(_ gridView: CompositionalGridView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gridView.endLoading(hasNext: true)
        }
    }
    
    func gridViewDidTriggerLoadMore(_ gridView: CompositionalGridView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.gridView.endLoading(hasNext: false)
        }
    }
}

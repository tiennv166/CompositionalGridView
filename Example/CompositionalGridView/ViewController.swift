//
//  ViewController.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 04/20/2023.
//  Copyright (c) 2023 tiennv166. All rights reserved.
//

import CompositionalGridView

final class ViewController: UIViewController {
    
    private lazy var gridView = CompositionalGridView()
    private lazy var layouts: [ExampleLayoutType] = ExampleLayoutType.all

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Compositional Grid View"
        configureGridView()
    }
    
    private func configureGridView() {
        gridView.addTo(view, in: self)
        gridView.setDelegate(self)
        gridView.setSettings(
            GridViewSettings(
                isScrollEnabled: true,
                contentInset: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            )
        )
        gridView.updateItems(layouts.map { OutlineItemCellModel(title: $0.description) })
    }
}

extension ViewController: CompositionalGridViewDelegate {
    func gridViewDidSelectItem(_ gridView: CompositionalGridView, item: GridItemModelConfigurable) {
        guard let model = item as? OutlineItemCellModel else { return }
        guard let layout = layouts.first(where: { $0.description == model.title }) else { return }
        print("Select item: \(layout.title)")
    }
    
    func gridViewDidTriggerEvent(_ gridView: CompositionalGridView, event: GridCellEvent) {
        guard let event = event as? OutlineItemCellEvent else { return }
        switch event {
        case let .view(title):
            guard let layout = layouts.first(where: { $0.description == title }) else { return }
            let viewController = GridViewController()
            viewController.title = layout.title
            viewController.items = layout.items
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

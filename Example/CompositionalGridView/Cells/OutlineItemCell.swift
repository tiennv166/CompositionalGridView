//
//  OutlineItemCell.swift
//  CompositionalGridView_Example
//
//  Created by tiennv166 on 21/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import CompositionalGridView
import UIKit

// MARK: OutlineItemCellEvent

enum OutlineItemCellEvent: GridCellEvent {
    case view(String)
}

// MARK: OutlineItemCellModel

struct OutlineItemCellModel: Equatable, GridItemModelConfigurable {
    let title: String
    let section: Int
    let hasSeparator: Bool
    let hasViewAction: Bool
    let isBoldStyle: Bool
    
    init(title: String, section: Int = 0, hasSeparator: Bool = true, hasViewAction: Bool = true, isBoldStyle: Bool = false) {
        self.title = title
        self.section = section
        self.hasSeparator = hasSeparator
        self.hasViewAction = hasViewAction
        self.isBoldStyle = isBoldStyle
    }

    var identity: String { title }
    var reuseIdentifier: String { "OutlineItemCell" }
    var viewType: GridLayout.ViewType { .cell(OutlineItemCell.self) }
    var itemSize: GridLayout.Size { .init(width: .fit, height: .estimated(60)) }
    var layoutIndex: GridLayout.Index { .init(section: GridLayout.Section(index: section, style: .dynamicHeightColumn(1))) }
}

// MARK: OutlineItemCell

final class OutlineItemCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var viewButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    private var title: String?
    private var eventHandler: ((GridCellEvent) -> Void)?

    @IBAction private func tapView(_ sender: Any) {
        title.flatMap { eventHandler?(OutlineItemCellEvent.view($0)) }
    }
}

extension OutlineItemCell: GridReusableViewType {
    func configure(_ model: OutlineItemCellModel) {
        title = model.title
        titleLabel.text = model.title
        separatorView.isHidden = !model.hasSeparator
        viewButton.isHidden = !model.hasViewAction
        if model.isBoldStyle {
            titleLabel.font = .boldSystemFont(ofSize: 20)
        } else {
            titleLabel.font = .systemFont(ofSize: 16)
        }
    }
    
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void)) {
        eventHandler = event
    }
}

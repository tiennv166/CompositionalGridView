//
//  HeaderView.swift
//  CompositionalGridView_Example
//
//  Created by tiennv166 on 29/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import CompositionalGridView
import UIKit

// MARK: OutlineItemCellModel

struct HeaderModel: Equatable, GridItemModelConfigurable {
    let title: String
    let section: Int
    let insets: UIEdgeInsets

    var identity: String { title }
    var reuseIdentifier: String { "HeaderView" }
    var viewType: GridLayout.ViewType { .header(HeaderView.self) }
    var itemSize: GridLayout.Size { .init(width: .fit, height: .estimated(60)) }
    var layoutIndex: GridLayout.Index { .init(section: GridLayout.Section(index: section, style: .normal)) }
}

// MARK: HeaderView

final class HeaderView: UICollectionReusableView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleLabelRight: NSLayoutConstraint!
    @IBOutlet private weak var titleLabelLeft: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .boldSystemFont(ofSize: 20)
    }
    
}

extension HeaderView: GridSupplementaryViewConfigurable {
    func configure(_ model: HeaderModel) -> UICollectionReusableView {
        titleLabel.text = model.title
        titleLabelRight.constant = model.insets.right
        titleLabelLeft.constant = model.insets.left
        return self
    }
}

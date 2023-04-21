//
//  SelfHandlingCell.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/17/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

// The container cell for UIView/UIViewController embeded item

final class SelfHandlingCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewIfNeeded(_ view: UIView) {
        guard view.superview !== contentView else { return }
        view.fill(in: contentView)
    }
}

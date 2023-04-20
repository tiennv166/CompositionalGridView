//
//  UICollectionView+Extension.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/18/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

extension UICollectionView {
    var shouldTriggerLoadmoreRightNow: Bool {
        // Not trigger if being refreshing
        guard refreshControl?.isRefreshing == false else { return false }
//        guard panGestureRecognizer.state != .possible else { return false }
        
        let translation = panGestureRecognizer.translation(in: superview)
        
        // Not trigger if swipes from bottom to top of screen -> up
        guard translation.y < 0 else { return false }

        // swipes from top to bottom of screen -> down
        let currentOffsetY = contentOffset.y
        let contentHeight = contentSize.height
        let visibleHeight = frame.height - contentInset.top - contentInset.bottom
        let remainingScreen = (contentHeight - currentOffsetY) / visibleHeight
        return remainingScreen <= 2
    }
    
    func registerCell(for item: GridItemModelConfigurable) {
        switch item.viewType {
        case let .cell(cellType):
            let bundle = Bundle(for: cellType)
            if bundle.path(forResource: String(describing: cellType), ofType: "nib") != nil {
                let nib = UINib(nibName: String(describing: cellType), bundle: bundle)
                register(nib, forCellWithReuseIdentifier: item.reuseIdentifier)
            } else {
                register(cellType, forCellWithReuseIdentifier: item.reuseIdentifier)
            }
        case .selfHandling:
            register(SelfHandlingCell.self, forCellWithReuseIdentifier: item.reuseIdentifier)
        }
    }
}

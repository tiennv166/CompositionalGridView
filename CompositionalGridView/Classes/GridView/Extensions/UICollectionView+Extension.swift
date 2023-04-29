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
            if let nib = getNib(from: cellType) {
                register(nib, forCellWithReuseIdentifier: item.reuseIdentifier)
            } else {
                register(cellType, forCellWithReuseIdentifier: item.reuseIdentifier)
            }
        case .selfHandling:
            register(SelfHandlingCell.self, forCellWithReuseIdentifier: item.reuseIdentifier)
        case let .header(cellType):
            registerSupplementaryView(
                with: cellType,
                reuseIdentifier: item.reuseIdentifier,
                kind: UICollectionView.elementKindSectionHeader
            )
        case let .footer(cellType):
            registerSupplementaryView(
                with: cellType,
                reuseIdentifier: item.reuseIdentifier,
                kind: UICollectionView.elementKindSectionFooter
            )
        }
    }
    
    private func registerSupplementaryView(with classType: AnyClass, reuseIdentifier: String, kind: String) {
        if let nib = getNib(from: classType) {
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        } else {
            register(classType, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        }
    }
}

private func getNib(from classType: AnyClass) -> UINib? {
    let bundle = Bundle(for: classType)
    guard bundle.path(forResource: String(describing: classType), ofType: "nib") != nil else { return nil }
    return UINib(nibName: String(describing: classType), bundle: bundle)
}

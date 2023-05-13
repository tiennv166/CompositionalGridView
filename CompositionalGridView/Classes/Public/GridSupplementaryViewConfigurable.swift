//
//  GridSupplementaryViewConfigurable.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 29/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation
import UIKit

public protocol GridSupplementaryViewConfigurable {
    
    associatedtype GridItemModel: GridItemModelConfigurable

    func configure(_ model: GridItemModel) -> UICollectionReusableView
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void))
}

public extension GridSupplementaryViewConfigurable {
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void)) {}
}

public extension GridSupplementaryViewConfigurable where Self: UICollectionReusableView {
    func configure(_ model: GridItemModel) -> UICollectionReusableView {
        self
    }
}

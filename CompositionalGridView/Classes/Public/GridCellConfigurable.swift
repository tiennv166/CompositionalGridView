//
//  GridCellConfigurable.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/14/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation
import UIKit

public protocol GridCellConfigurable {
    
    associatedtype GridItemModel: GridItemModelConfigurable

    func configure(_ model: GridItemModel) -> UICollectionViewCell
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void))
}

public extension GridCellConfigurable {
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void)) {}
}

public extension GridCellConfigurable where Self: UICollectionViewCell {
    func configure(_ model: GridItemModel) -> UICollectionViewCell {
        self
    }
}

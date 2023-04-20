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
    func configure(_ model: GridItemModelConfigurable) -> UICollectionViewCell
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void))
}

public extension GridCellConfigurable {
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void)) {}
}

public extension GridCellConfigurable where Self: UICollectionViewCell {
    func configure(_ model: GridItemModelConfigurable) -> UICollectionViewCell {
        self
    }
}

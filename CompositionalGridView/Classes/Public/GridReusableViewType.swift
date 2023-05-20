//
//  GridReusableViewType.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 21/05/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation

public protocol GridReusableViewType {
    
    associatedtype GridItemModel: GridItemModelConfigurable

    func configure(_ model: GridItemModel)
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void))
}

public extension GridReusableViewType {
    func configure(_ model: GridItemModel) {}
    func handleEvent(_ event: @escaping ((GridCellEvent) -> Void)) {}
}

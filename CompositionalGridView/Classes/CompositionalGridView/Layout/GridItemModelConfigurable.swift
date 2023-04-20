//
//  GridItemModelConfigurable.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/14/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation

public protocol GridItemModelConfigurable {
    var layoutIndex: GridLayout.Index { get }
    var identity: String { get }
    var reuseIdentifier: String { get }
    var viewType: GridLayout.ViewType { get }
    var itemSize: GridLayout.Size { get }
    var itemSpacing: CGFloat { get }
    var lineSpacing: CGFloat { get }
    func isEqualTo(_ other: GridItemModelConfigurable) -> Bool
}

public extension GridItemModelConfigurable where Self: Equatable {
    func isEqualTo(_ other: GridItemModelConfigurable) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

public extension GridItemModelConfigurable {
    func isEqualTo(_ other: GridItemModelConfigurable) -> Bool {
        guard let other = other as? Self else { return false }
        return identity == other.identity
    }
    var itemSpacing: CGFloat { 0 }
    var lineSpacing: CGFloat { 0 }
}

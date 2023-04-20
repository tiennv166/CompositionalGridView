//
//  SelfHandlingItemModel.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/17/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation

public struct SelfHandlingItemModel: GridItemModelConfigurable {
    public let layoutIndex: GridLayout.Index
    public let identity: String
    public let itemSize: GridLayout.Size
    public let itemSpacing: CGFloat
    public let lineSpacing: CGFloat
    
    public var reuseIdentifier: String { identity }
    public var viewType: GridLayout.ViewType { .selfHandling }
    
    public init(identity: String,
                layoutIndex: GridLayout.Index,
                itemSize: GridLayout.Size,
                itemSpacing: CGFloat = 0,
                lineSpacing: CGFloat = 0) {
        self.identity = identity
        self.layoutIndex = layoutIndex
        self.itemSize = itemSize
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
    }
}

extension SelfHandlingItemModel: Hashable {
    public static func == (lhs: SelfHandlingItemModel, rhs: SelfHandlingItemModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}

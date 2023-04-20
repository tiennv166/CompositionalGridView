//
//  GridViewSettings.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/18/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

public struct GridViewSettings: Equatable {
    public let isReloadEnabled: Bool
    public let isLoadMoreEnabled: Bool
    public let isScrollEnabled: Bool
    public let backgroundColor: UIColor
    public let contentInset: UIEdgeInsets

    public init(isReloadEnabled: Bool = false,
                isLoadMoreEnabled: Bool = false,
                isScrollEnabled: Bool = true,
                backgroundColor: UIColor = .clear,
                contentInset: UIEdgeInsets = .zero) {
        self.isReloadEnabled = isReloadEnabled
        self.isLoadMoreEnabled = isLoadMoreEnabled
        self.isScrollEnabled = isScrollEnabled
        self.backgroundColor = backgroundColor
        self.contentInset = contentInset
    }
}

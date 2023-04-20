//
//  GridLayoutSize+Extension.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/20/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

extension GridLayout.Size {
    var heightValue: CGFloat {
        switch height {
        case let .fixed(value): return value
        case let .estimated(value): return value ?? 100
        case .fit:
            assertionFailure("Not support fit height")
            return CGFloat.zero
        }
    }
    
    func widthValue(containerWidth: CGFloat) -> CGFloat {
        switch width {
        case let .fixed(value): return value
        case .fit: return containerWidth
        case let .estimated(value): return value ?? 100
        }
    }
    
    var heightDimension: NSCollectionLayoutDimension {
        switch height {
        case let .fixed(value): return .absolute(value)
        case let .estimated(value): return .estimated(value ?? 100)
        case .fit:
            assertionFailure("Not support fit height")
            return .absolute(CGFloat.zero)
        }
    }
    
    var widthDimension: NSCollectionLayoutDimension {
        switch width {
        case let .fixed(value): return .absolute(value)
        case let .estimated(value): return .estimated(value ?? 100)
        case .fit: return .fractionalWidth(1)
        }
    }
    
    var layoutSize: NSCollectionLayoutSize {
        NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
    }
}

//
//  GridLayout.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/14/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation
import UIKit

// MARK: GridLayout

public enum GridLayout {}

// MARK: ScrollDirection

extension GridLayout {
    public enum ScrollDirection: Equatable {
        case vertical
        case horizontal
    }
}

// MARK: Size

extension GridLayout {
    public struct Size {
        public let width: SizeType
        public let height: SizeType
        public init(width: SizeType, height: SizeType) {
            self.width = width
            self.height = height
        }
    }
    
    public enum SizeType {
        case fixed(CGFloat) // static with exactly size
        case estimated(CGFloat?) // dynamic with estimated size
        case fit // full width/height
        
        var isEstimated: Bool {
            if case .estimated = self { return true }
            return false
        }
    }
    
    public enum GroupStyle: Equatable {
        case normal
        case staticHeightColumn(UInt)
        case orthogonal
        case dynamicHeightColumn(UInt)
        
        var isOrthogonal: Bool {
            if case .orthogonal = self { return true }
            return false
        }
    }
}

// MARK: ViewType

extension GridLayout {
    public enum ViewType {
        case cell(AnyClass) // CellType
        case selfHandling // use for embeded UIView/UIViewController in a cell
    }
}

// MARK: Section, Index

extension GridLayout {
    
    public struct Section: Equatable {
        let index: Int
        let style: GroupStyle
        let contentInsets: UIEdgeInsets
        
        public init(index: Int, style: GroupStyle, contentInsets: UIEdgeInsets = .zero) {
            self.index = index
            self.style = style
            self.contentInsets = contentInsets
        }
    }
    
    public struct Index: Equatable {
        public let section: Section
        public let row: Int

        public init(section: Section, row: Int = 0) {
            self.section = section
            self.row = row
        }

        public static func > (lhs: Index, rhs: Index) -> Bool {
            if lhs.section.index > rhs.section.index { return true }
            if lhs.section.index < rhs.section.index { return false }
            return lhs.row > rhs.row
        }

        public static func < (lhs: Index, rhs: Index) -> Bool {
            if lhs.section.index < rhs.section.index { return true }
            if lhs.section.index > rhs.section.index { return false }
            return lhs.row < rhs.row
        }
    }
}

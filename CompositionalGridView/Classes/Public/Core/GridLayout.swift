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
        
        // wrap text based on the size of each item and the screen size
        case normal
        
        // fractional width & same height for all items
        // the associate value is the number of columns (inverse of the fractional width)
        case staticHeightColumn(UInt)
        
        // fractional width & dynamic height for each item
        // the associate value is the number of columns (inverse of the fractional width)
        case dynamicHeightColumn(UInt)
        
        // horizotal scrolling (similar to Carousel style) & same size for all items
        // the associate value is the number of rows
        case staticSizeRow(UInt)

        // horizotal scrolling (similar to Carousel style) & dynamic size for each item
        // the associate value is the number of rows
        case dynamicSizeRow(UInt)
        
        var isOrthogonal: Bool {
            switch self {
            case .dynamicSizeRow, .staticSizeRow: return true
            default: return false
            }
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

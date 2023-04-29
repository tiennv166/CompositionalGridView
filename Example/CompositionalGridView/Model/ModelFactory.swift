//
//  ModelFactory.swift
//  CompositionalGridView_Example
//
//  Created by tiennv166 on 21/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import CompositionalGridView
import Foundation

enum ExampleLayoutType: Int {
    case listView
    case gridViewStaticHeight
    case gridViewDynamicHeigt
    case normal
    case carouselStaticSize
    case carouselDynamicSize
    case combine
}

extension ExampleLayoutType {
    static var all: [ExampleLayoutType] {
        [
            .listView,
            .gridViewStaticHeight,
            .gridViewDynamicHeigt,
            .normal,
            .carouselStaticSize,
            .carouselDynamicSize,
            .combine
        ]
    }
    
    var description: String {
        switch self {
        case .listView:
            return "List layout:\n Full width similar to a table view"
        case .gridViewStaticHeight:
            return "Grid layout with static height:\n  3 items in a row"
        case .gridViewDynamicHeigt:
            return "Grid layout with dynamic height:\n  3 items in a row"
        case .normal:
            return "Grid layout with normal style:\n  Breaks line same as text"
        case .carouselStaticSize:
            return "Grid layout with orthogonal style:\n  Horizontal scrolling slider / carousel (stactic size)"
        case .carouselDynamicSize:
            return "Grid layout with orthogonal style:\n  Horizontal scrolling slider / carousel (dynamic size)"
        case .combine:
            return "Combine multi styles in a single view:\n  - List layout\n  - Carousel\n  - Grid static height\n  - Grid dynamic height"
        }
    }
    
    var title: String {
        switch self {
        case .listView:
            return "List layout"
        case .gridViewStaticHeight:
            return "Grid staticHeightColumn(3)"
        case .gridViewDynamicHeigt:
            return "Grid dynamicHeightColumn(3)"
        case .normal:
            return "Grid normal style"
        case .carouselStaticSize:
            return "Carousel static size"
        case .carouselDynamicSize:
            return "Carousel dynamic size"
        case .combine:
            return "Grid view combine"
        }
    }
    
    var items: [GridItemModelConfigurable] {
        switch self {
        case .listView:
            return makeListViewData(section: 0)
        case .gridViewStaticHeight:
            return makeGridViewStaticHeightData(section: 0)
        case .gridViewDynamicHeigt:
            return makeGridViewDynamicHeightData(section: 0)
        case .normal:
            return makeGridViewNormalData(section: 0)
        case .carouselStaticSize:
            let items: [[GridItemModelConfigurable]] = [
                [makeSectionTitle("Carousel 1 row", section: 0)],
                makeGridViewStaticSizeCarouselData(section: 0, rows: 1),
                [makeSectionTitle("Carousel 2 rows", section: 1)],
                makeGridViewStaticSizeCarouselData(section: 1, rows: 2),
                [makeSectionTitle("Carousel 3 rows", section: 2)],
                makeGridViewStaticSizeCarouselData(section: 2, rows: 3),
                [makeSectionTitle("Carousel 4 rows", section: 3)],
                makeGridViewStaticSizeCarouselData(section: 3, rows: 4)
            ]
            return items.flatMap { $0 }
        case .carouselDynamicSize:
            let items: [[GridItemModelConfigurable]] = [
                [makeSectionTitle("Carousel 1 row", section: 0)],
                makeGridViewDynamicSizeCarouselData(section: 0, rows: 1),
                [makeSectionTitle("Carousel 2 rows", section: 1)],
                makeGridViewDynamicSizeCarouselData(section: 1, rows: 2),
                [makeSectionTitle("Carousel 3 rows", section: 2)],
                makeGridViewDynamicSizeCarouselData(section: 2, rows: 3),
                [makeSectionTitle("Carousel 4 rows", section: 3)],
                makeGridViewDynamicSizeCarouselData(section: 3, rows: 4)
            ]
            return items.flatMap { $0 }
        case .combine:
            let items: [[GridItemModelConfigurable]] = [
                [
                    makeSectionTitle(
                        for: .listView,
                        section: 0,
                        insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                    )
                ],
                makeListViewData(section: 0),
                [makeSectionTitle("Carousel 1 row", section: 1)],
                makeGridViewStaticSizeCarouselData(section: 1, rows: 1),
                [makeSectionTitle("Carousel 2 rows", section: 2)],
                makeGridViewStaticSizeCarouselData(section: 2, rows: 2),
                [makeSectionTitle("Carousel 3 rows", section: 3)],
                makeGridViewDynamicSizeCarouselData(section: 3, rows: 3),
                [makeSectionTitle(for: .gridViewStaticHeight, section: 4)],
                makeGridViewStaticHeightData(section: 4),
                [makeSectionTitle(for: .gridViewDynamicHeigt, section: 5)],
                makeGridViewDynamicHeightData(section: 5)
            ]
            return items.flatMap { $0 }
        }
    }
}

extension ExampleLayoutType {
    private func makeListViewData(section: Int) -> [GridItemModelConfigurable] {
        let texts: [String] = [
            "1. Lorem ipsum dolor sit er elit lamet",
            "2. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            "3. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            "4. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            "5. Lorem ipsum dolor sit er elit lamet",
            "6. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            "7. Lorem ipsum dolor sit er elit lamet",
            "8. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            "9. Lorem ipsum dolor sit er elit lamet",
            "10. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"
        ]
        return texts.map { OutlineItemCellModel(title: $0, section: section, hasViewAction: false) }
    }
    
    private func makeGridViewDynamicHeightData(section: Int) -> [GridItemModelConfigurable] {
        let heights: [CGFloat] = [180, 160, 100, 120, 130, 150, 200, 168, 180, 200, 240, 150, 200, 120, 160, 140, 150, 170]
        let sectionLayout = GridLayout.Section(
            index: section,
            style: .dynamicHeightColumn(3),
            contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        return heights.enumerated().map { index, height in
            GridItemCellModel(
                width: 1,
                height: height,
                index: index + 1,
                layoutIndex: GridLayout.Index(section: sectionLayout)
            )
        }
    }
    
    private func makeGridViewStaticHeightData(section: Int) -> [GridItemModelConfigurable] {
        let sectionLayout = GridLayout.Section(
            index: section,
            style: .staticHeightColumn(3),
            contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        return (1...40).map { index in
            GridItemCellModel(
                width: 100,
                height: 180,
                index: index,
                layoutIndex: GridLayout.Index(section: sectionLayout)
            )
        }
    }
    
    private func makeGridViewNormalData(section: Int) -> [GridItemModelConfigurable] {
        let sizes: [(CGFloat, CGFloat)] = [(100, 180), (80, 160), (180, 100), (260, 180), (140, 180), (130, 160), (150, 100), (180, 180), (130, 140)]
        let sectionLayout = GridLayout.Section(
            index: section,
            style: .normal,
            contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        return sizes.enumerated().map { index, size in
            GridItemCellModel(
                width: size.0,
                height: size.1,
                index: index + 1,
                layoutIndex: GridLayout.Index(section: sectionLayout)
            )
        }
    }
    
    private func makeGridViewStaticSizeCarouselData(section: Int, rows: UInt) -> [GridItemModelConfigurable] {
        let sectionLayout = GridLayout.Section(
            index: section,
            style: .staticSizeRow(rows),
            contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        return (1...20).map { index in
            GridItemCellModel(
                width: 150,
                height: 80,
                index: index,
                layoutIndex: GridLayout.Index(section: sectionLayout)
            )
        }
    }
    
    private func makeGridViewDynamicSizeCarouselData(section: Int, rows: UInt) -> [GridItemModelConfigurable] {
        let sectionLayout = GridLayout.Section(
            index: section,
            style: .dynamicSizeRow(rows),
            contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        let sizes: [(CGFloat, CGFloat)] = [(100, 160), (80, 160), (180, 160), (260, 160), (140, 160), (130, 160), (150, 160), (180, 160), (130, 160), (130, 160), (130, 160), (100, 160), (80, 160), (180, 160), (160, 160), (160, 160)]
        return sizes.enumerated().map { index, size in
            GridItemCellModel(
                width: size.0,
                height: size.1,
                index: index + 1,
                layoutIndex: GridLayout.Index(section: sectionLayout)
            )
        }
    }
    
    private func makeSectionTitle(for layout: ExampleLayoutType, section: Int, insets: UIEdgeInsets = .zero) -> HeaderModel {
        HeaderModel(title: layout.title, section: section, insets: insets)
    }
    
    private func makeSectionTitle(_ title: String, section: Int, insets: UIEdgeInsets = .zero) -> HeaderModel {
        HeaderModel(title: title, section: section, insets: insets)
    }
}

//
//  GridViewModel.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/16/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation
import UIKit

// MARK: GridViewItem

struct GridViewItem: Hashable {
    let model: GridItemModelConfigurable
    var identifier: String {
        "\(model.layoutIndex.section.index)-\(model.layoutIndex.row)-\(model.identity)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: GridViewItem, rhs: GridViewItem) -> Bool {
        lhs.model.isEqualTo(rhs.model)
    }
}

// MARK: GridViewSection

struct GridViewSection {
    let index: Int
    let items: [GridViewItem]
    
    func containsItem(_ item: GridItemModelConfigurable) -> Bool {
        items.contains { $0.model.isEqualTo(item) }
    }
    
    func index(of item: GridItemModelConfigurable) -> Int? {
        items.firstIndex(where: { $0.model.isEqualTo(item) })
    }
}

// MARK: GridViewModel

struct GridViewModel {
    let sections: [GridViewSection]
    
    var allItems: [GridViewItem] { sections.flatMap(\.items) }
    
    init(items: [GridItemModelConfigurable], hasLoadMore: Bool) {
        let sortedItems = items.sorted(by: { $0.layoutIndex < $1.layoutIndex })
        var sections: [Int: [GridViewItem]] = [:]
        sortedItems.forEach { item in
            let sectionIdx = item.layoutIndex.section.index
            let oldItems: [GridViewItem] = sections[sectionIdx] ?? []
            sections[sectionIdx] = oldItems + [GridViewItem(model: item)]
        }
        if hasLoadMore {
            sections[Int.max] = [GridViewItem(model: LoadMoreCellModel())]
        }
        self.sections = sections.keys.sorted(by: { $0 < $1 })
            .compactMap { index -> GridViewSection? in
                guard let items = sections[index], let firstItem = items.first else { return nil }
                let sortedItems: [GridViewItem] = {
                    switch firstItem.model.layoutIndex.section.style {
                    case let .dynamicHeightColumn(column):
                        guard column > 0 else { return [] }
                        return (0..<column).flatMap { columnIdx -> [GridViewItem] in
                            items.enumerated().compactMap { itemIdx, item -> GridViewItem? in
                                guard UInt(itemIdx) % column == columnIdx else { return nil }
                                return item
                            }
                        }
                    default: return items
                    }
                }()
                return GridViewSection(index: index, items: sortedItems)
            }
            .enumerated()
            .map { index, section in GridViewSection(index: index, items: section.items) }
    }
    
    func makeLayoutSection(_ sectionIndex: Int,
                           environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        guard let section = sections.first(where: { $0.index == sectionIndex }) else { return nil }
        let items = section.items
        guard let firstItem = items.first else { return nil }
        let groupStyle = firstItem.model.layoutIndex.section.style
        let insets = firstItem.model.layoutIndex.section.contentInsets
        let containerWidth = environment.container.effectiveContentSize.width - insets.left - insets.right
        guard let group = makeLayoutGroup(groupStyle, items: items, containerWidth: containerWidth) else { return nil }
        let layout = NSCollectionLayoutSection(group: group)
        if groupStyle.isOrthogonal {
            layout.orthogonalScrollingBehavior = .continuous
        }
        layout.contentInsets = insets.directionalEdgeInsets
        return layout
    }
}

private extension GridViewModel {
    func makeLayoutGroup(_ style: GridLayout.GroupStyle, items: [GridViewItem], containerWidth: CGFloat) -> NSCollectionLayoutGroup? {
        switch style {
        case .normal:
            return makeNormalLayoutGroup(items: items, containerWidth: containerWidth)
        case let .staticHeightColumn(column):
            return makeStaticHeightColumnLayoutGroup(column, items: items, containerWidth: containerWidth)
        case .orthogonal:
            return makeOrthogonalLayoutGroup(items: items, containerWidth: containerWidth)
        case let .dynamicHeightColumn(column):
            return makeDynamicHeightColumnLayoutGroup(column, items: items, containerWidth: containerWidth)
        }
    }
    
    func makeNormalLayoutGroup(items: [GridViewItem], containerWidth: CGFloat) -> NSCollectionLayoutGroup? {
        guard let firstItem = items.first else { return nil }
        let itemSpacing = firstItem.model.itemSpacing
        var itemsIn2D: [(rowItems: [GridViewItem], rowWidth: CGFloat)] = [([], 0)]
        items.forEach { item in
            guard let lastRow = itemsIn2D.last else { return }
            let itemWidth = item.model.itemSize.widthValue(containerWidth: containerWidth)
            if lastRow.rowWidth + itemSpacing + itemWidth <= containerWidth {
                // Update last row
                itemsIn2D.removeLast()
                let newRowItems = lastRow.rowItems + [item]
                let newRowWidth = lastRow.rowWidth + itemSpacing + itemWidth
                itemsIn2D.append((newRowItems, newRowWidth))
            } else {
                // Make new row
                itemsIn2D.append(([item], itemWidth))
            }
        }
        
        let groups: [NSCollectionLayoutGroup] = itemsIn2D
            .map { rowItems, _ -> NSCollectionLayoutGroup in
                let hasDynamicItem = rowItems.contains { $0.model.itemSize.height.isEstimated }
                let maxHeight: CGFloat = rowItems.map(\.model.itemSize.heightValue).reduce(0, { max($0, $1) })
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: hasDynamicItem ? .estimated(maxHeight) : .absolute(maxHeight)
                )
                let itemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: rowItems.map(\.layout))
                itemGroup.interItemSpacing = .fixed(firstItem.model.itemSpacing)
                return itemGroup
            }
        // Update container height with spacing
        let containerHeight: CGFloat = {
            let spacing = firstItem.model.lineSpacing * CGFloat(groups.count - 1)
            return spacing + groups.map(\.layoutSize.heightDimension.dimension).reduce(0, { max($0, $1) })
        }()
        let hasDynamicItem: Bool = groups.contains { $0.layoutSize.heightDimension.isEstimated }
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: hasDynamicItem ? .estimated(containerHeight) : .absolute(containerHeight)
            ),
            subitems: groups
        )
        containerGroup.interItemSpacing = .fixed(firstItem.model.lineSpacing)
        return containerGroup
    }
    
    func makeOrthogonalLayoutGroup(items: [GridViewItem], containerWidth: CGFloat) -> NSCollectionLayoutGroup? {
        guard let firstItem = items.first else { return nil }
        var containerHeight: CGFloat = 0
        var hasDynamicHeightItem: Bool = false
        var containerWidth: CGFloat = 0
        var hasDynamicWidthItem: Bool = false
        let groups: [NSCollectionLayoutGroup] = items
            .map { item -> NSCollectionLayoutGroup in
                let isDynamicHeightItem = item.model.itemSize.height.isEstimated
                let isDynamicWidthItem = item.model.itemSize.width.isEstimated
                let height = item.model.itemSize.heightValue
                let width = item.model.itemSize.widthValue(containerWidth: containerWidth)
                // Update for container
                hasDynamicHeightItem = hasDynamicHeightItem || isDynamicHeightItem
                containerHeight = max(containerHeight, height)
                hasDynamicWidthItem = hasDynamicWidthItem || isDynamicWidthItem
                containerWidth += width
                return NSCollectionLayoutGroup.vertical(layoutSize: item.size, subitems: [item.layout])
            }
        // Update container size with spacing
        containerWidth += CGFloat(items.count - 1) * firstItem.model.itemSpacing
        containerHeight += firstItem.model.lineSpacing
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: hasDynamicWidthItem ? .estimated(containerWidth) : .absolute(containerWidth),
                heightDimension: hasDynamicHeightItem ? .estimated(containerHeight) : .absolute(containerHeight)
            ),
            subitems: groups
        )
        containerGroup.interItemSpacing = .fixed(firstItem.model.lineSpacing)
        return containerGroup
    }
    
    func makeStaticHeightColumnLayoutGroup(_ column: UInt, items: [GridViewItem], containerWidth: CGFloat) -> NSCollectionLayoutGroup? {
        guard let firstItem = items.first else { return nil }
        guard column > 0 else { return nil }
        let itemSpacing = firstItem.model.itemSpacing
        let fractionWidth = (containerWidth - CGFloat(column - 1) * itemSpacing) / (containerWidth * CGFloat(column))
        let height = firstItem.model.itemSize.heightValue
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth),
                                              heightDimension: .absolute(height))
        
        let generateRowGroup: ((Int) -> NSCollectionLayoutGroup?) = { count in
            guard count > 0 else { return nil }
            let subGroups: [NSCollectionLayoutGroup] = (1...column).map { _ in
                NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [NSCollectionLayoutItem(layoutSize: fullLayoutSize)]
                )
            }
            let rowGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ),
                subitems: subGroups
            )
            rowGroup.interItemSpacing = .fixed(firstItem.model.itemSpacing)
            return rowGroup
        }
        
        var groups = [NSCollectionLayoutGroup]()
        (0..<(items.count / Int(column))).forEach { _ in
            generateRowGroup(Int(column)).flatMap { groups.append($0) }
        }
        let lastRow = generateRowGroup(items.count % Int(column))
        lastRow.flatMap { groups.append($0) }
        
        // Update container height with spacing
        let rowCount = items.count / Int(column) + (lastRow == nil ? 0 : 1)
        let containerHeight = CGFloat(rowCount) * height + firstItem.model.lineSpacing * CGFloat(rowCount - 1)
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(containerHeight)
            ),
            subitems: groups
        )
        containerGroup.interItemSpacing = .fixed(firstItem.model.lineSpacing)
        return containerGroup
    }
    
    func makeDynamicHeightColumnLayoutGroup(_ column: UInt, items: [GridViewItem], containerWidth: CGFloat) -> NSCollectionLayoutGroup? {
        guard let firstItem = items.first else { return nil }
        guard column > 0 else { return nil }
        let itemSpacing = firstItem.model.itemSpacing
        let fractionWidth = (containerWidth - CGFloat(column - 1) * itemSpacing) / (containerWidth * CGFloat(column))
        let groups: [NSCollectionLayoutGroup] = (1...column).map { index in
            let subItems: [NSCollectionLayoutItem] = items.enumerated()
                .compactMap { itemIndex, item -> GridViewItem? in
                    guard UInt(itemIndex) % column == index - 1 else { return nil }
                    return item
                }
                .map { item -> NSCollectionLayoutItem in
                    let height = item.model.itemSize.heightDimension
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
                    return NSCollectionLayoutItem(layoutSize: size)
                }
            let groupHeight: CGFloat = {
                let spacing: CGFloat = CGFloat(subItems.count - 1) * firstItem.model.lineSpacing
                let totalHeight = subItems.map(\.layoutSize.heightDimension.dimension).reduce(0, +)
                return totalHeight + spacing
            }()
            let hasDynamic: Bool = subItems.contains { $0.layoutSize.heightDimension.isEstimated }
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(fractionWidth),
                    heightDimension: hasDynamic ? .estimated(groupHeight) : .absolute(groupHeight)
                ),
                subitems: subItems
            )
            group.interItemSpacing = .fixed(firstItem.model.lineSpacing)
            return group
        }
        
        let groupHeight: CGFloat = groups.map(\.layoutSize.heightDimension.dimension).reduce(0, { max($0, $1) })
        let hasDynamic: Bool = groups.contains { $0.layoutSize.heightDimension.isEstimated }
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: hasDynamic ? .estimated(groupHeight) : .absolute(groupHeight)
            ),
            subitems: groups
        )
        group.interItemSpacing = .fixed(firstItem.model.itemSpacing)
        return group
    }
}

// MARK: private shorthand

private var fullLayoutSize: NSCollectionLayoutSize {
    NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
}

private extension GridViewItem {
    var layout: NSCollectionLayoutItem { NSCollectionLayoutItem(layoutSize: size) }
    var size: NSCollectionLayoutSize { model.itemSize.layoutSize }
}

private extension UIEdgeInsets {
    var directionalEdgeInsets: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

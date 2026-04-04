//
//  LayoutTestSupport.swift
//  CompositionalGridView_Tests
//
//  Created by Codex on 04/04/2026.
//

import UIKit
import XCTest
@testable import CompositionalGridView

func runOnMainThread(_ work: () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.sync(execute: work)
    }
}

struct LayoutTestCellModel: GridItemModelConfigurable {
    let index: Int
    let style: GridLayout.GroupStyle
    let width: GridLayout.SizeType
    let height: GridLayout.SizeType
    let itemSpacing: CGFloat
    let lineSpacing: CGFloat
    let sectionIndex: Int

    var identity: String { "\(index)" }
    var reuseIdentifier: String { "LayoutTestCell" }
    var viewType: GridLayout.ViewType { .cell(LayoutTestCell.self) }
    var itemSize: GridLayout.Size { .init(width: width, height: height) }
    var layoutIndex: GridLayout.Index { .init(section: .init(index: sectionIndex, style: style), row: index) }
}

final class LayoutTestCell: UICollectionViewCell, GridReusableViewType {
    typealias GridItemModel = LayoutTestCellModel
}

struct SupplementaryHeaderModel: GridItemModelConfigurable {
    let identity: String
    let sectionIndex: Int
    let style: GridLayout.GroupStyle

    var reuseIdentifier: String { "SupplementaryHeaderView" }
    var viewType: GridLayout.ViewType { .header(SupplementaryHeaderView.self) }
    var itemSize: GridLayout.Size { .init(width: .fit, height: .fixed(44)) }
    var layoutIndex: GridLayout.Index { .init(section: .init(index: sectionIndex, style: style), row: 0) }
}

struct SupplementaryFooterModel: GridItemModelConfigurable {
    let identity: String
    let sectionIndex: Int
    let style: GridLayout.GroupStyle

    var reuseIdentifier: String { "SupplementaryFooterView" }
    var viewType: GridLayout.ViewType { .footer(SupplementaryFooterView.self) }
    var itemSize: GridLayout.Size { .init(width: .fit, height: .fixed(30)) }
    var layoutIndex: GridLayout.Index { .init(section: .init(index: sectionIndex, style: style), row: 0) }
}

final class SupplementaryHeaderView: UICollectionReusableView, GridReusableViewType {
    typealias GridItemModel = SupplementaryHeaderModel
}

final class SupplementaryFooterView: UICollectionReusableView, GridReusableViewType {
    typealias GridItemModel = SupplementaryFooterModel
}

final class GridViewDelegateSpy: CompositionalGridViewDelegate {
    private(set) var loadMoreTriggerCount = 0
    private(set) var reloadTriggerCount = 0
    private(set) var selectedItems: [GridItemModelConfigurable] = []
    private(set) var events: [GridCellEvent] = []

    func gridViewDidTriggerLoadMore(_ gridView: CompositionalGridView) {
        loadMoreTriggerCount += 1
    }

    func gridViewDidTriggerReload(_ gridView: CompositionalGridView) {
        reloadTriggerCount += 1
    }

    func gridViewDidSelectItem(_ gridView: CompositionalGridView, item: GridItemModelConfigurable) {
        selectedItems.append(item)
    }

    func gridViewDidTriggerEvent(_ gridView: CompositionalGridView, event: GridCellEvent) {
        events.append(event)
    }
}

extension CompositionalGridView {
    func testCollectionView(file: StaticString = #filePath, line: UInt = #line) -> UICollectionView {
        let deadline = Date().addingTimeInterval(1)
        while Date() < deadline {
            if let collectionView = subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
                return collectionView
            }
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        XCTFail("Expected embedded collection view", file: file, line: line)
        fatalError("Expected embedded collection view")
    }
}

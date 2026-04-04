//
//  MultiSectionTests.swift
//  CompositionalGridView_Tests
//
//  Created by Codex on 04/04/2026.
//

import Nimble
import UIKit
import XCTest
@testable import CompositionalGridView

@MainActor
final class MultiSectionTests: XCTestCase {
    private var sut: GridViewModel!
    private var items: [LayoutTestCellModel]!

    override func setUp() {
        super.setUp()
        items = [
            LayoutTestCellModel(index: 1, style: .normal, width: .fit, height: .fixed(40), itemSpacing: 0, lineSpacing: 0, sectionIndex: 10),
            LayoutTestCellModel(index: 0, style: .staticHeightColumn(2), width: .fixed(80), height: .fixed(50), itemSpacing: 8, lineSpacing: 10, sectionIndex: 2),
            LayoutTestCellModel(index: 0, style: .normal, width: .fit, height: .fixed(40), itemSpacing: 0, lineSpacing: 0, sectionIndex: 10),
            LayoutTestCellModel(index: 1, style: .staticHeightColumn(2), width: .fixed(80), height: .fixed(50), itemSpacing: 8, lineSpacing: 10, sectionIndex: 2)
        ]
        sut = GridViewModel(items: items, hasLoadMore: false)
    }

    override func tearDown() {
        items = nil
        sut = nil
        super.tearDown()
    }

    func testSortSectionsByOriginalIndexAndReindexSequentially() {
        expect(self.sut.sections.count).to(equal(2))
        expect(self.sut.sections[0].index).to(equal(0))
        expect(self.sut.sections[1].index).to(equal(1))
        expect(self.sut.sections[0].items[0].model.isEqualTo(self.items[1])).to(beTruthy())
        expect(self.sut.sections[0].items[1].model.isEqualTo(self.items[3])).to(beTruthy())
        expect(self.sut.sections[1].items[0].model.isEqualTo(self.items[2])).to(beTruthy())
        expect(self.sut.sections[1].items[1].model.isEqualTo(self.items[0])).to(beTruthy())
    }

    func testCreateLayoutSectionsUsingStyleOfEachOriginalSection() {
        let firstLayout = self.sut.makeLayoutSection(
            0,
            containerContentSize: CGSize(width: 320, height: 640),
            containerContentInsets: .zero
        )
        let secondLayout = self.sut.makeLayoutSection(
            1,
            containerContentSize: CGSize(width: 320, height: 640),
            containerContentInsets: .zero
        )
        let firstScrollingBehavior = firstLayout?.orthogonalScrollingBehavior
        let firstGroupHeight = firstLayout?.group.layoutSize.heightDimension.dimension
        let secondScrollingBehavior = secondLayout?.orthogonalScrollingBehavior
        let secondHasFractionalWidth = secondLayout?.group.layoutSize.widthDimension.isFractionalWidth

        expect(firstScrollingBehavior).to(equal(UICollectionLayoutSectionOrthogonalScrollingBehavior.none))
        expect(firstGroupHeight).to(equal(50))
        expect(secondScrollingBehavior).to(equal(UICollectionLayoutSectionOrthogonalScrollingBehavior.none))
        expect(secondHasFractionalWidth).to(beTrue())
    }
}

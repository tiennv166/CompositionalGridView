//
//  CompositionalGridViewAPITests.swift
//  CompositionalGridView_Tests
//
//  Created by Codex on 04/04/2026.
//

import Nimble
import UIKit
import XCTest
@testable import CompositionalGridView

@MainActor
final class CompositionalGridViewAPITests: XCTestCase {
    private var sut: CompositionalGridView!
    private var delegate: GridViewDelegateSpy!
    private var collectionView: UICollectionView!

    override func setUp() {
        super.setUp()
        sut = CompositionalGridView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        let container = UIView(frame: sut.frame)
        sut.addTo(container)
        delegate = GridViewDelegateSpy()
        sut.setDelegate(delegate)
        collectionView = sut.testCollectionView()
    }

    override func tearDown() {
        collectionView = nil
        delegate = nil
        sut = nil
        super.tearDown()
    }

    func testApplySettingsToEmbeddedCollectionView() {
        let settings = GridViewSettings(
            isReloadEnabled: true,
            isLoadMoreEnabled: true,
            isScrollEnabled: false,
            backgroundColor: .red,
            contentInset: UIEdgeInsets(top: 12, left: 20, bottom: 24, right: 28)
        )

        sut.setSettings(settings)

        expect(self.collectionView.refreshControl).toEventuallyNot(beNil())
        expect(self.collectionView.isScrollEnabled).toEventually(beFalse())
        expect(self.collectionView.backgroundColor).toEventually(equal(UIColor.red))
        expect(self.collectionView.contentInset.top).toEventually(equal(12))
        expect(self.collectionView.contentInset.bottom).toEventually(equal(24))
        expect(self.collectionView.contentInset.left).toEventually(equal(0))
        expect(self.collectionView.contentInset.right).toEventually(equal(0))
    }

    func testExposeLoadMoreItemOnlyWhenLoadMoreIsEnabled() {
        let item = LayoutTestCellModel(
            index: 0,
            style: .normal,
            width: .fit,
            height: .fixed(50),
            itemSpacing: 0,
            lineSpacing: 0,
            sectionIndex: 0
        )

        sut.setSettings(GridViewSettings(isLoadMoreEnabled: true))
        sut.updateItems([item], hasNext: true)

        expect(self.sut.indexPath(for: LoadMoreCellModel())).toEventually(equal(IndexPath(row: 0, section: 1)))

        sut.setSettings(GridViewSettings(isLoadMoreEnabled: false))

        expect(self.sut.indexPath(for: LoadMoreCellModel())).toEventually(beNil())
    }

    func testNotifyDelegateWhenPullToRefreshIsTriggered() {
        sut.setSettings(GridViewSettings(isReloadEnabled: true))

        waitUntil(timeout: .seconds(1)) { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.collectionView.refreshControl?.sendActions(for: .valueChanged)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    expect(self.delegate.reloadTriggerCount).to(equal(1))
                    done()
                }
            }
        }
    }

    func testNotifyDelegateWhenLoadMoreCellIsDisplayed() {
        sut.setSettings(GridViewSettings(isLoadMoreEnabled: true))
        sut.endLoading(hasNext: true)

        waitUntil(timeout: .seconds(1)) { done in
            self.sut.collectionView(
                self.collectionView,
                willDisplay: LoadMoreCell(frame: .zero),
                forItemAt: IndexPath(row: 0, section: 0)
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                expect(self.delegate.loadMoreTriggerCount).to(equal(1))
                done()
            }
        }
    }
}

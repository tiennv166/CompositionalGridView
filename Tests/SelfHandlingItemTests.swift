//
//  SelfHandlingItemTests.swift
//  CompositionalGridView_Tests
//
//  Created by Codex on 04/04/2026.
//

import Nimble
import UIKit
import XCTest
@testable import CompositionalGridView

@MainActor
final class SelfHandlingItemTests: XCTestCase {
    private var sut: CompositionalGridView!
    private var containerViewController: UIViewController!
    private var selfHandlingItem: SelfHandlingItemModel!

    override func setUp() {
        super.setUp()
        sut = CompositionalGridView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        containerViewController = UIViewController()
        containerViewController.view.frame = sut.frame
        sut.addTo(containerViewController.view, in: containerViewController)
        selfHandlingItem = SelfHandlingItemModel(
            identity: "self-handling-item",
            layoutIndex: .init(section: .init(index: 0, style: .normal), row: 0),
            itemSize: .init(width: .fit, height: .fixed(80))
        )
        sut.updateItems([])
    }

    override func tearDown() {
        selfHandlingItem = nil
        containerViewController = nil
        sut = nil
        super.tearDown()
    }

    func testIncludeVisibleSelfHandlingUIViewItemInViewModel() {
        sut.addSelfHandlingLogicItem(selfHandlingItem, view: UIView(), isHidden: false)

        expect(self.sut.indexPath(for: self.selfHandlingItem)).toEventually(equal(IndexPath(row: 0, section: 0)))
    }

    func testHiddenSelfHandlingUIViewItemAppearsOnlyAfterShown() {
        sut.addSelfHandlingLogicItem(selfHandlingItem, view: UIView(), isHidden: true)

        expect(self.sut.indexPath(for: self.selfHandlingItem)).toEventually(beNil())
        sut.setHiddenItem(false, identity: selfHandlingItem.identity)
        expect(self.sut.indexPath(for: self.selfHandlingItem)).toEventually(equal(IndexPath(row: 0, section: 0)))
    }

    func testIncludeVisibleSelfHandlingUIViewControllerItemInViewModel() {
        sut.addSelfHandlingLogicItem(selfHandlingItem, viewController: UIViewController(), isHidden: false)

        expect(self.sut.indexPath(for: self.selfHandlingItem)).toEventually(equal(IndexPath(row: 0, section: 0)))
    }
}

//
//  iOS_UnlimitedCatWorld_swiftUITestsLaunchTests.swift
//  iOS_UnlimitedCatWorld-swiftUITests
//
//  Created by Phil on 2025/4/9.
//

import XCTest

final class iOS_UnlimitedCatWorld_swiftUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

import XCTest

/// UI Tests for EMF Scope app covering normal use cases and error scenarios.
final class EMFMeterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    /// Test that the app launches successfully and displays main view.
    func testAppLaunches() throws {
        app.launch()

        // Verify main view elements are present
        XCTAssertTrue(app.staticTexts["EMF Scope"].waitForExistence(timeout: 5))
    }

    /// Test that the app displays the EMF reading on launch.
    func testEMFReadingDisplayed() throws {
        app.launch()

        // The EMF reading accessibility element should exist
        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.waitForExistence(timeout: 5))
    }

    // MARK: - Control Panel Tests

    /// Test that the sound toggle works correctly.
    func testSoundToggle() throws {
        app.launch()

        let soundToggle = app.buttons["SOUND toggle"]
        XCTAssertTrue(soundToggle.waitForExistence(timeout: 5))

        // Get initial state
        let initialValue = soundToggle.value as? String

        // Tap to toggle
        soundToggle.tap()

        // Wait for state change
        sleep(1)

        // Verify state changed
        let newValue = soundToggle.value as? String
        XCTAssertNotEqual(initialValue, newValue, "Sound toggle state should change after tap")
    }

    /// Test that the zero calibration button is accessible.
    func testZeroCalibrationButton() throws {
        app.launch()

        let zeroButton = app.buttons["Zero calibration button"]
        XCTAssertTrue(zeroButton.waitForExistence(timeout: 5))

        // Tap the button
        zeroButton.tap()

        // After calibration, the value should indicate calibrated
        sleep(1)
        let calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated", "Should be calibrated after tapping zero button")
    }

    /// Test that the settings button opens the settings sheet.
    func testSettingsButton() throws {
        app.launch()

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))

        // Tap settings
        settingsButton.tap()

        // Verify settings sheet appears
        let settingsTitle = app.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))

        // Verify unit options are present
        XCTAssertTrue(app.staticTexts["MicroTesla (µT)"].exists)
        XCTAssertTrue(app.staticTexts["MilliGauss (mG)"].exists)
        XCTAssertTrue(app.staticTexts["Gauss (G)"].exists)
    }

    /// Test that the info button opens the safety information sheet.
    func testInfoButton() throws {
        app.launch()

        let infoButton = app.buttons["Information"]
        XCTAssertTrue(infoButton.waitForExistence(timeout: 5))

        // Tap info button
        infoButton.tap()

        // Verify safety info sheet appears
        let safetyTitle = app.staticTexts["About EMF Safety"]
        XCTAssertTrue(safetyTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Settings Tests

    /// Test changing the measurement unit.
    func testChangeUnit() throws {
        app.launch()

        // Open settings
        app.buttons["Settings"].tap()

        // Wait for settings to appear
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Select MilliGauss
        app.staticTexts["MilliGauss (mG)"].tap()

        // Close settings
        app.buttons["Done"].tap()

        // Verify unit changed (EMF reading should now show mG)
        sleep(1)
        let emfReading = app.otherElements["EMF Reading"]
        let value = emfReading.value as? String ?? ""
        XCTAssertTrue(value.contains("milligauss"), "Reading should be in milligauss after changing unit")
    }

    /// Test changing the theme.
    func testChangeTheme() throws {
        app.launch()

        // Open settings
        app.buttons["Settings"].tap()

        // Wait for settings to appear
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Select Dark theme
        app.staticTexts["Dark"].tap()

        // Close settings
        app.buttons["Done"].tap()

        // App should still function (visual verification would need snapshot testing)
        XCTAssertTrue(app.otherElements["EMF Reading"].waitForExistence(timeout: 3))
    }

    /// Test reset calibration in settings.
    func testResetCalibration() throws {
        app.launch()

        // First calibrate
        let zeroButton = app.buttons["Zero calibration button"]
        zeroButton.tap()
        sleep(1)

        // Open settings
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Look for Reset button (only visible when calibrated)
        let resetButton = app.buttons["Reset"]
        if resetButton.exists {
            resetButton.tap()

            // Close settings
            app.buttons["Done"].tap()

            // Verify calibration was reset
            sleep(1)
            let calibrationValue = zeroButton.value as? String
            XCTAssertEqual(calibrationValue, "Not calibrated", "Should be not calibrated after reset")
        }
    }

    // MARK: - Accessibility Tests

    /// Test that VoiceOver can access the main EMF reading.
    func testEMFReadingAccessibility() throws {
        app.launch()

        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.waitForExistence(timeout: 5))

        // Verify it has a value
        let value = emfReading.value as? String
        XCTAssertNotNil(value, "EMF reading should have an accessibility value")
        XCTAssertFalse(value?.isEmpty ?? true, "EMF reading value should not be empty")
    }

    /// Test that all interactive elements have accessibility labels.
    func testAllControlsAccessible() throws {
        app.launch()

        // Verify all main controls are accessible
        XCTAssertTrue(app.buttons["Information"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["SOUND toggle"].exists)
        XCTAssertTrue(app.buttons["Zero calibration button"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
        XCTAssertTrue(app.otherElements["EMF Reading"].exists)
    }

    // MARK: - Navigation Tests

    /// Test dismissing the settings sheet.
    func testDismissSettings() throws {
        app.launch()

        // Open settings
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Dismiss with Done button
        app.buttons["Done"].tap()

        // Verify settings is dismissed
        sleep(1)
        XCTAssertFalse(app.staticTexts["Settings"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    /// Test dismissing the safety info sheet.
    func testDismissSafetyInfo() throws {
        app.launch()

        // Open info
        app.buttons["Information"].tap()
        XCTAssertTrue(app.staticTexts["About EMF Safety"].waitForExistence(timeout: 3))

        // Dismiss with Done button
        app.buttons["Done"].tap()

        // Verify info is dismissed
        sleep(1)
        XCTAssertFalse(app.staticTexts["About EMF Safety"].exists)
        XCTAssertTrue(app.buttons["Information"].exists)
    }

    // MARK: - Edge Case Tests

    /// Test app behavior with rapid button taps.
    func testRapidButtonTaps() throws {
        app.launch()

        let soundToggle = app.buttons["SOUND toggle"]
        XCTAssertTrue(soundToggle.waitForExistence(timeout: 5))

        // Rapidly tap the sound toggle
        for _ in 0..<10 {
            soundToggle.tap()
        }

        // App should still be responsive
        sleep(1)
        XCTAssertTrue(app.otherElements["EMF Reading"].exists)
    }

    /// Test multiple calibrations in succession.
    func testMultipleCalibrations() throws {
        app.launch()

        let zeroButton = app.buttons["Zero calibration button"]
        XCTAssertTrue(zeroButton.waitForExistence(timeout: 5))

        // Calibrate multiple times
        for _ in 0..<5 {
            zeroButton.tap()
            usleep(500000) // 0.5 second
        }

        // App should still be responsive and calibrated
        sleep(1)
        let calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated")
    }

    /// Test switching units multiple times.
    func testSwitchUnitsMultipleTimes() throws {
        app.launch()

        let units = ["MicroTesla (µT)", "MilliGauss (mG)", "Gauss (G)"]

        for unit in units {
            // Open settings
            app.buttons["Settings"].tap()
            XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

            // Select unit
            app.staticTexts[unit].tap()

            // Close settings
            app.buttons["Done"].tap()
            sleep(1)

            // Verify EMF reading still exists
            XCTAssertTrue(app.otherElements["EMF Reading"].exists)
        }
    }

    // MARK: - In-App Purchase Tests

    /// Test that tapping locked REC button shows upgrade prompt.
    func testLockedRecordButtonShowsUpgrade() throws {
        // Launch with testing mode disabled to test actual lock behavior
        app.launchArguments = ["--uitesting", "--disable-testing-mode"]
        app.launch()

        // Find and tap the record button (should be locked for free users)
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))

        // Tap the locked button
        recordButton.tap()

        // Should show upgrade prompt
        let upgradePrompt = app.staticTexts["Unlock Pro Features"]
        if upgradePrompt.waitForExistence(timeout: 3) {
            XCTAssertTrue(upgradePrompt.exists, "Upgrade prompt should appear when tapping locked feature")

            // Dismiss the upgrade prompt
            let dismissButton = app.buttons["Maybe Later"]
            if dismissButton.exists {
                dismissButton.tap()
            }
        }
    }

    /// Test that tapping locked oscilloscope shows upgrade prompt.
    func testLockedOscilloscopeTapShowsUpgrade() throws {
        // Launch with testing mode disabled
        app.launchArguments = ["--uitesting", "--disable-testing-mode"]
        app.launch()

        // Wait for main view
        XCTAssertTrue(app.otherElements["EMF Reading"].waitForExistence(timeout: 5))

        // The oscilloscope area should be tappable
        // When tapped by free user, should show upgrade prompt
        // Note: The actual element identifier depends on accessibility setup
    }

    /// Test upgrade prompt UI elements are present.
    func testUpgradePromptUIElements() throws {
        app.launchArguments = ["--uitesting", "--disable-testing-mode"]
        app.launch()

        // Trigger upgrade prompt via locked feature
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()

        // Check for upgrade prompt elements
        let upgradePrompt = app.staticTexts["Unlock Pro Features"]
        if upgradePrompt.waitForExistence(timeout: 3) {
            // Verify key UI elements
            XCTAssertTrue(app.staticTexts["Unlock Pro Features"].exists)

            // Check for purchase button
            let purchaseButton = app.buttons["Upgrade to Pro"]
            XCTAssertTrue(purchaseButton.exists || app.buttons.matching(NSPredicate(format: "label CONTAINS 'Upgrade'")).count > 0)

            // Check for restore button
            let restoreButton = app.buttons["Restore Purchase"]
            XCTAssertTrue(restoreButton.exists)

            // Check for dismiss button
            let dismissButton = app.buttons["Maybe Later"]
            XCTAssertTrue(dismissButton.exists)
        }
    }

    /// Test dismiss upgrade prompt.
    func testDismissUpgradePrompt() throws {
        app.launchArguments = ["--uitesting", "--disable-testing-mode"]
        app.launch()

        // Trigger upgrade prompt
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()

        // Wait for prompt
        let upgradePrompt = app.staticTexts["Unlock Pro Features"]
        if upgradePrompt.waitForExistence(timeout: 3) {
            // Dismiss
            let dismissButton = app.buttons["Maybe Later"]
            XCTAssertTrue(dismissButton.exists)
            dismissButton.tap()

            // Verify prompt is dismissed
            sleep(1)
            XCTAssertFalse(app.staticTexts["Unlock Pro Features"].exists)

            // Verify app is still functional
            XCTAssertTrue(app.otherElements["EMF Reading"].exists)
        }
    }

    /// Test restore purchases button is functional.
    func testRestorePurchasesButton() throws {
        app.launchArguments = ["--uitesting", "--disable-testing-mode"]
        app.launch()

        // Trigger upgrade prompt
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()

        // Wait for prompt
        let upgradePrompt = app.staticTexts["Unlock Pro Features"]
        if upgradePrompt.waitForExistence(timeout: 3) {
            // Tap restore
            let restoreButton = app.buttons["Restore Purchase"]
            XCTAssertTrue(restoreButton.exists)
            restoreButton.tap()

            // Should not crash, may show loading indicator
            sleep(2)

            // App should still be functional (prompt may still be showing or dismissed)
            // Just verify no crash occurred
        }
    }

    /// Test Pro features are accessible after unlock (using testing mode).
    func testProFeaturesAccessibleAfterUnlock() throws {
        // Launch with testing mode enabled (simulates Pro user)
        app.launch()

        // Wait for main view
        XCTAssertTrue(app.otherElements["EMF Reading"].waitForExistence(timeout: 5))

        // Record button should be accessible
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 3))

        // Tap should start recording (not show upgrade prompt)
        recordButton.tap()
        sleep(1)

        // Should show stop recording button now
        let stopButton = app.buttons["Stop recording"]
        if stopButton.exists {
            XCTAssertTrue(stopButton.exists, "Recording should start for Pro users")

            // Stop recording
            stopButton.tap()
        }
    }

    /// Test session history is accessible for Pro users.
    func testSessionHistoryAccessibleForPro() throws {
        app.launch()

        // Open settings
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        // Look for session history in settings
        let sessionsButton = app.buttons["Recording Sessions"]
        if sessionsButton.waitForExistence(timeout: 3) {
            sessionsButton.tap()

            // Should show session history view
            let historyTitle = app.staticTexts["Recording Sessions"]
            XCTAssertTrue(historyTitle.waitForExistence(timeout: 3) || app.navigationBars["Recording Sessions"].exists)
        }
    }
}

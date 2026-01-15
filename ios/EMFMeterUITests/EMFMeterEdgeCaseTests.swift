import XCTest

/// UI Tests for EMF Scope app covering error cases and edge scenarios.
/// These tests use launch arguments to simulate different magnetometer states.
final class EMFMeterEdgeCaseTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Sensor Unavailable Tests

    /// Test that the app shows sensor unavailable view when magnetometer is not available.
    func testSensorUnavailableView() throws {
        app.launchArguments = ["--uitesting", "--sensor-unavailable"]
        app.launch()

        // Should show sensor offline message
        let sensorOffline = app.staticTexts["SENSOR OFFLINE"]
        XCTAssertTrue(sensorOffline.waitForExistence(timeout: 5), "Should show sensor offline message")

        // Should show explanation
        let explanation = app.staticTexts["Magnetometer not available"]
        XCTAssertTrue(explanation.exists, "Should show magnetometer unavailable explanation")

        // Main controls should not be visible
        XCTAssertFalse(app.buttons["SOUND toggle"].exists, "Sound toggle should not be visible when sensor unavailable")
        XCTAssertFalse(app.buttons["Zero calibration button"].exists, "Zero button should not be visible when sensor unavailable")
    }

    /// Test accessibility of sensor unavailable view.
    func testSensorUnavailableAccessibility() throws {
        app.launchArguments = ["--uitesting", "--sensor-unavailable"]
        app.launch()

        // The sensor unavailable view should be accessible
        let sensorOfflineElement = app.otherElements.containing(.staticText, identifier: "SENSOR OFFLINE").firstMatch
        XCTAssertTrue(sensorOfflineElement.waitForExistence(timeout: 5))
    }

    // MARK: - Low Value Tests

    /// Test that the app handles very low EMF values (near zero).
    func testVeryLowValues() throws {
        app.launchArguments = ["--uitesting", "--mock-value-low"]
        app.launch()

        // EMF reading should exist
        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.waitForExistence(timeout: 5))

        // Value should be near zero
        let value = emfReading.value as? String ?? ""
        XCTAssertTrue(value.contains("0") || value.contains("1") || value.contains("2"),
                      "Low value reading should show near-zero value")

        // All controls should still work
        XCTAssertTrue(app.buttons["SOUND toggle"].exists)
        XCTAssertTrue(app.buttons["Zero calibration button"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    /// Test calibration at zero value.
    func testCalibrationAtZeroValue() throws {
        app.launchArguments = ["--uitesting", "--mock-value-low"]
        app.launch()

        let zeroButton = app.buttons["Zero calibration button"]
        XCTAssertTrue(zeroButton.waitForExistence(timeout: 5))

        // Calibrate at low value
        zeroButton.tap()
        sleep(1)

        // Should be calibrated
        let calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated")
    }

    // MARK: - High Value Tests

    /// Test that the app handles very high EMF values (near max).
    func testVeryHighValues() throws {
        app.launchArguments = ["--uitesting", "--mock-value-high"]
        app.launch()

        // EMF reading should exist
        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.waitForExistence(timeout: 5))

        // All controls should still work
        XCTAssertTrue(app.buttons["SOUND toggle"].exists)
        XCTAssertTrue(app.buttons["Zero calibration button"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    /// Test that high values don't break the meter display.
    func testHighValueMeterDisplay() throws {
        app.launchArguments = ["--uitesting", "--mock-value-high"]
        app.launch()

        // Wait for reading to stabilize
        sleep(2)

        // EMF reading should still be accessible
        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.exists)

        // Should be able to open settings
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))
    }

    /// Test calibration at high value.
    func testCalibrationAtHighValue() throws {
        app.launchArguments = ["--uitesting", "--mock-value-high"]
        app.launch()

        let zeroButton = app.buttons["Zero calibration button"]
        XCTAssertTrue(zeroButton.waitForExistence(timeout: 5))

        // Calibrate at high value
        zeroButton.tap()
        sleep(1)

        // Should be calibrated
        let calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated")
    }

    // MARK: - Fluctuating Value Tests

    /// Test that the app handles rapidly fluctuating values.
    func testFluctuatingValues() throws {
        app.launchArguments = ["--uitesting", "--mock-value-fluctuating"]
        app.launch()

        // EMF reading should exist
        let emfReading = app.otherElements["EMF Reading"]
        XCTAssertTrue(emfReading.waitForExistence(timeout: 5))

        // Wait and verify app remains stable
        sleep(3)

        // All controls should still be responsive
        let soundToggle = app.buttons["SOUND toggle"]
        XCTAssertTrue(soundToggle.exists)
        soundToggle.tap()
        sleep(1)

        // App should still be functional
        XCTAssertTrue(app.otherElements["EMF Reading"].exists)
    }

    // MARK: - Unit Conversion Edge Cases

    /// Test very small values in different units.
    func testSmallValuesInAllUnits() throws {
        app.launchArguments = ["--uitesting", "--mock-value-low"]
        app.launch()

        let units = [
            ("MicroTesla (µT)", "microtesla"),
            ("MilliGauss (mG)", "milligauss"),
            ("Gauss (G)", "gauss")
        ]

        for (unitLabel, unitName) in units {
            // Open settings
            app.buttons["Settings"].tap()
            XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

            // Select unit
            app.staticTexts[unitLabel].tap()

            // Close settings
            app.buttons["Done"].tap()
            sleep(1)

            // Verify reading is displayed
            let emfReading = app.otherElements["EMF Reading"]
            XCTAssertTrue(emfReading.exists, "EMF reading should exist for \(unitName)")

            let value = emfReading.value as? String ?? ""
            XCTAssertTrue(value.contains(unitName), "Reading should be in \(unitName)")
        }
    }

    /// Test very large values in different units.
    func testLargeValuesInAllUnits() throws {
        app.launchArguments = ["--uitesting", "--mock-value-high"]
        app.launch()

        let units = ["MicroTesla (µT)", "MilliGauss (mG)", "Gauss (G)"]

        for unitLabel in units {
            // Open settings
            app.buttons["Settings"].tap()
            XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))

            // Select unit
            app.staticTexts[unitLabel].tap()

            // Close settings
            app.buttons["Done"].tap()
            sleep(1)

            // Verify reading is displayed correctly (not showing overflow or errors)
            let emfReading = app.otherElements["EMF Reading"]
            XCTAssertTrue(emfReading.exists, "EMF reading should exist for \(unitLabel)")
        }
    }

    // MARK: - State Persistence Tests

    /// Test that calibration persists when value changes.
    func testCalibrationPersistsWithValueChange() throws {
        app.launchArguments = ["--uitesting", "--mock-value-medium"]
        app.launch()

        let zeroButton = app.buttons["Zero calibration button"]
        XCTAssertTrue(zeroButton.waitForExistence(timeout: 5))

        // Calibrate
        zeroButton.tap()
        sleep(1)

        // Verify calibrated
        var calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated")

        // Toggle sound (simulates user interaction while value might change)
        app.buttons["SOUND toggle"].tap()
        sleep(1)

        // Should still be calibrated
        calibrationValue = zeroButton.value as? String
        XCTAssertEqual(calibrationValue, "Calibrated")
    }

    // MARK: - Stress Tests

    /// Test rapid interactions don't crash the app.
    func testStressTestRapidInteractions() throws {
        app.launch()

        // Wait for app to load
        XCTAssertTrue(app.buttons["SOUND toggle"].waitForExistence(timeout: 5))

        // Perform rapid interactions
        for _ in 0..<20 {
            app.buttons["SOUND toggle"].tap()
            usleep(100000) // 0.1 second
        }

        // Quickly open and close settings multiple times
        for _ in 0..<5 {
            app.buttons["Settings"].tap()
            usleep(300000) // 0.3 second
            if app.buttons["Done"].exists {
                app.buttons["Done"].tap()
            }
            usleep(200000) // 0.2 second
        }

        // App should still be responsive
        sleep(1)
        XCTAssertTrue(app.otherElements["EMF Reading"].exists, "App should remain responsive after stress test")
    }

    /// Test app remains stable over extended period.
    func testExtendedUsage() throws {
        app.launch()

        // Wait for app to load
        XCTAssertTrue(app.otherElements["EMF Reading"].waitForExistence(timeout: 5))

        // Simulate extended usage (10 seconds)
        for i in 0..<10 {
            sleep(1)

            // Periodically interact with controls
            if i % 3 == 0 {
                app.buttons["SOUND toggle"].tap()
            }
            if i % 5 == 0 {
                app.buttons["Zero calibration button"].tap()
            }

            // Verify app is still responsive
            XCTAssertTrue(app.otherElements["EMF Reading"].exists, "App should remain responsive during extended usage")
        }
    }
}

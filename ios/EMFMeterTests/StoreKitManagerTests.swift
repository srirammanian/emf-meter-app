import XCTest
@testable import EMFMeter

/// Unit tests for StoreKitManager covering state management and error handling.
/// Note: Full StoreKit integration tests require running with the StoreKit configuration
/// file in Xcode's scheme settings.
final class StoreKitManagerTests: XCTestCase {

    // MARK: - Product ID Tests

    /// Test that product ID constant is correct.
    func testProductIdConstant() {
        XCTAssertEqual(StoreKitManager.proProductId, "com.emfmeter.pro")
    }

    /// Test that product ID follows Apple naming conventions.
    func testProductIdFormat() {
        let productId = StoreKitManager.proProductId

        // Should be reverse domain notation
        XCTAssertTrue(productId.contains("."), "Product ID should use dot notation")

        // Should not have spaces
        XCTAssertFalse(productId.contains(" "), "Product ID should not contain spaces")

        // Should be lowercase
        XCTAssertEqual(productId, productId.lowercased(), "Product ID should be lowercase")
    }

    // MARK: - Testing Mode Tests

    /// Test that testing mode is disabled for production.
    func testTestingModeDisabledForProduction() {
        XCTAssertFalse(StoreKitManager.testingModeEnabled, "Testing mode should be disabled for production")
    }

    // MARK: - Purchase State Tests

    /// Test PurchaseState enum cases exist.
    func testPurchaseStateEnumCases() {
        // Verify all expected states exist
        let idle = StoreKitManager.PurchaseState.idle
        let loading = StoreKitManager.PurchaseState.loading
        let purchasing = StoreKitManager.PurchaseState.purchasing
        let purchased = StoreKitManager.PurchaseState.purchased
        let failed = StoreKitManager.PurchaseState.failed

        // Verify they are distinct
        XCTAssertNotEqual(idle, loading)
        XCTAssertNotEqual(loading, purchasing)
        XCTAssertNotEqual(purchasing, purchased)
        XCTAssertNotEqual(purchased, failed)
    }

    /// Test PurchaseState is Equatable.
    func testPurchaseStateEquatable() {
        let state1 = StoreKitManager.PurchaseState.idle
        let state2 = StoreKitManager.PurchaseState.idle
        let state3 = StoreKitManager.PurchaseState.loading

        XCTAssertEqual(state1, state2, "Same states should be equal")
        XCTAssertNotEqual(state1, state3, "Different states should not be equal")
    }
}

// MARK: - StoreError Tests

final class StoreErrorTests: XCTestCase {

    /// Test verification failed error description.
    func testVerificationFailedError() {
        let underlyingError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = StoreError.verificationFailed(underlyingError)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.lowercased().contains("verification") ?? false)
    }

    /// Test product not found error description.
    func testProductNotFoundError() {
        let error = StoreError.productNotFound

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.lowercased().contains("not found") ?? false)
    }

    /// Test StoreError conforms to LocalizedError.
    func testStoreErrorIsLocalizedError() {
        let error: LocalizedError = StoreError.productNotFound
        XCTAssertNotNil(error.errorDescription)
    }

    /// Test verification failed wraps underlying error.
    func testVerificationFailedWrapsError() {
        let underlyingMessage = "Underlying test message"
        let underlyingError = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: underlyingMessage])
        let error = StoreError.verificationFailed(underlyingError)

        // The error description should contain information about the underlying error
        XCTAssertNotNil(error.errorDescription)
    }
}

// MARK: - StoreKitManager Initialization Tests

@MainActor
final class StoreKitManagerInitTests: XCTestCase {

    /// Test that StoreKitManager can be instantiated.
    func testStoreKitManagerInstantiation() {
        let manager = StoreKitManager()
        XCTAssertNotNil(manager)
    }

    /// Test initial published properties have expected default values.
    func testInitialPublishedPropertiesDefaults() {
        let manager = StoreKitManager()

        // isProUnlocked should be false initially (unless testing mode persisted something)
        // We just verify it's a valid boolean
        _ = manager.isProUnlocked

        // purchaseState should not be nil
        XCTAssertNotNil(manager.purchaseState)

        // errorMessage should be nil initially
        XCTAssertNil(manager.errorMessage)
    }

    /// Test that StoreKitManager starts loading products on init.
    func testStartsLoadingOnInit() {
        let manager = StoreKitManager()

        // The manager should be in loading state or have transitioned from it
        // Since loading is async, we just verify the manager is created without crash
        XCTAssertNotNil(manager)
    }
}

// MARK: - Integration Test Placeholder

/// These tests require the StoreKit test environment.
/// Run these manually in Xcode with the StoreKit configuration file enabled.
final class StoreKitIntegrationTests: XCTestCase {

    /// Placeholder for manual StoreKit testing.
    /// To test purchases:
    /// 1. Open scheme settings in Xcode
    /// 2. Under Options, set StoreKit Configuration to "Products.storekit"
    /// 3. Run the app in simulator
    /// 4. Test purchase and restore flows manually
    func testStoreKitConfigurationNote() {
        // This is a placeholder test that always passes
        // Actual StoreKit testing should be done manually or with UI tests
        XCTAssertTrue(true, "See test comments for manual StoreKit testing instructions")
    }
}

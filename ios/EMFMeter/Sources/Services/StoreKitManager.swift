import StoreKit
import SwiftUI

/// Handles in-app purchases using StoreKit 2.
@MainActor
class StoreKitManager: ObservableObject {
    // MARK: - Constants
    static let proProductId = "com.emfmeter.pro"

    // MARK: - Published State
    @Published private(set) var isProUnlocked: Bool = false
    @Published private(set) var proProduct: Product?
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var errorMessage: String?

    enum PurchaseState: Equatable {
        case idle
        case loading
        case purchasing
        case purchased
        case failed
    }

    // MARK: - Private
    private var updateListenerTask: Task<Void, Error>?

    /// Check if running on simulator
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: - Initialization

    init() {
        // Check for simulator Pro unlock
        #if targetEnvironment(simulator)
        if UserDefaults.standard.bool(forKey: "simulator_pro_unlocked") {
            isProUnlocked = true
        }
        #endif

        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public API

    /// Purchase the Pro upgrade.
    func purchase() async {
        // On simulator, unlock Pro directly for testing
        #if targetEnvironment(simulator)
        purchaseState = .purchasing
        // Brief delay to simulate purchase flow
        try? await Task.sleep(nanoseconds: 500_000_000)
        isProUnlocked = true
        purchaseState = .purchased
        // Persist for simulator session
        UserDefaults.standard.set(true, forKey: "simulator_pro_unlocked")
        return
        #endif

        guard let product = proProduct else {
            errorMessage = "Product not available"
            purchaseState = .failed
            return
        }

        purchaseState = .purchasing
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                isProUnlocked = true
                purchaseState = .purchased

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle
                errorMessage = "Purchase is pending approval"

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed
            errorMessage = error.localizedDescription
        }
    }

    /// Restore previous purchases.
    func restorePurchases() async {
        purchaseState = .loading
        errorMessage = nil

        // Sync with App Store
        do {
            try await AppStore.sync()
        } catch {
            // Sync failed but we can still check entitlements
        }

        await updatePurchaseStatus()
        purchaseState = .idle
    }

    /// Check if Pro is currently unlocked.
    func checkProStatus() async {
        await updatePurchaseStatus()
    }

    // MARK: - Private

    private func loadProducts() async {
        purchaseState = .loading

        do {
            let products = try await Product.products(for: [Self.proProductId])
            proProduct = products.first
            purchaseState = .idle
        } catch {
            print("Failed to load products: \(error)")
            purchaseState = .failed
            errorMessage = "Failed to load products"
        }
    }

    private func updatePurchaseStatus() async {
        // On simulator, check UserDefaults
        #if targetEnvironment(simulator)
        if UserDefaults.standard.bool(forKey: "simulator_pro_unlocked") {
            isProUnlocked = true
            return
        }
        #endif

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.proProductId {
                    isProUnlocked = true
                    return
                }
            }
        }
        isProUnlocked = false
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == StoreKitManager.proProductId {
                        await MainActor.run {
                            self?.isProUnlocked = true
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw StoreError.verificationFailed(error)
        case .verified(let item):
            return item
        }
    }
}

// MARK: - Errors

enum StoreError: LocalizedError {
    case verificationFailed(Error)
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed(let error):
            return "Purchase verification failed: \(error.localizedDescription)"
        case .productNotFound:
            return "Product not found"
        }
    }
}

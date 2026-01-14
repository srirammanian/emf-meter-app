import SwiftUI

@main
struct EMFMeterApp: App {
    @AppStorage("theme") private var theme: String = "system"

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch theme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}

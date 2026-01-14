import SwiftUI

/// App color palette
extension Color {
    // Primary Colors
    static let appPrimary = Color(hex: "8B4513")  // Saddle Brown
    static let appPrimaryVariant = Color(hex: "6B3410")

    // Light Theme
    static let backgroundLight = Color(hex: "F5F5DC")  // Beige
    static let surfaceLight = Color(hex: "FFFEF0")     // Cream
    static let onBackgroundLight = Color(hex: "333333")

    // Dark Theme
    static let backgroundDark = Color(hex: "1A1A1A")
    static let surfaceDark = Color(hex: "252525")
    static let onBackgroundDark = Color(hex: "E0E0E0")

    // Meter Colors - Light
    static let meterBezelLight = Color(hex: "8B8B7A")
    static let meterFaceLight = Color(hex: "FFFEF0")
    static let meterScaleLight = Color(hex: "333333")
    static let meterNeedleLight = Color(hex: "CC0000")
    static let meterPivotLight = Color(hex: "8B0000")

    // Meter Colors - Dark
    static let meterBezelDark = Color(hex: "2C2C2C")
    static let meterFaceDark = Color(hex: "252525")
    static let meterScaleDark = Color(hex: "E0E0E0")
    static let meterNeedleDark = Color(hex: "FF3333")
    static let meterPivotDark = Color(hex: "CC0000")

    // Vintage Meter Colors
    static let vintageBezel = Color(hex: "1A1A1A")
    static let vintageBezelHighlight = Color(hex: "3A3A3A")
    static let vintageFace = Color(hex: "F5F0E1")
    static let vintageFaceEdge = Color(hex: "E8E0C8")
    static let vintageArc = Color(hex: "5B8FA8")
    static let vintageArcDark = Color(hex: "4A7A8F")
    static let vintageScale = Color(hex: "333333")
    static let vintageNeedle = Color(hex: "1A1A1A")
    static let vintagePivot = Color(hex: "2A2A2A")
    static let vintageBrass = Color(hex: "B8860B")
    static let vintageBrassHighlight = Color(hex: "DAA520")
    static let vintageBrassShadow = Color(hex: "8B6914")
    static let vintageCasing = Color(hex: "A8A8A0")
    static let vintageCasingDark = Color(hex: "888880")

    // Digital Display
    static let digitalBackground = Color(hex: "1A3A1A")
    static let digitalBackgroundDark = Color(hex: "0A1A0A")
    static let digitalText = Color(hex: "00FF00")
    static let digitalSegmentOff = Color(hex: "0A200A")
    static let digitalBorder = Color(hex: "333333")

    // Accent
    static let accentLight = Color(hex: "8B4513")
    static let accentDark = Color(hex: "CD853F")
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Meter colors that adapt to color scheme
struct MeterColors {
    let bezel: Color
    let face: Color
    let scale: Color
    let needle: Color
    let pivot: Color
    let digitalBackground: Color
    let digitalText: Color
    let digitalSegmentOff: Color
    let digitalBorder: Color

    // Vintage colors
    let vintageBezel: Color
    let vintageBezelHighlight: Color
    let vintageFace: Color
    let vintageFaceEdge: Color
    let vintageArc: Color
    let vintageScale: Color
    let vintageNeedle: Color
    let vintagePivot: Color
    let vintageBrass: Color
    let vintageBrassHighlight: Color
    let vintageBrassShadow: Color
    let vintageCasing: Color
    let vintageCasingDark: Color

    static func colors(for colorScheme: ColorScheme) -> MeterColors {
        if colorScheme == .dark {
            return MeterColors(
                bezel: .meterBezelDark,
                face: .meterFaceDark,
                scale: .meterScaleDark,
                needle: .meterNeedleDark,
                pivot: .meterPivotDark,
                digitalBackground: .digitalBackgroundDark,
                digitalText: .digitalText,
                digitalSegmentOff: .digitalSegmentOff,
                digitalBorder: .digitalBorder,
                vintageBezel: .vintageBezel,
                vintageBezelHighlight: .vintageBezelHighlight,
                vintageFace: Color(hex: "3A3530"),
                vintageFaceEdge: Color(hex: "2A2520"),
                vintageArc: .vintageArcDark,
                vintageScale: Color(hex: "D0D0D0"),
                vintageNeedle: Color(hex: "E0E0E0"),
                vintagePivot: Color(hex: "4A4A4A"),
                vintageBrass: .vintageBrass,
                vintageBrassHighlight: .vintageBrassHighlight,
                vintageBrassShadow: .vintageBrassShadow,
                vintageCasing: Color(hex: "3A3A38"),
                vintageCasingDark: Color(hex: "2A2A28")
            )
        } else {
            return MeterColors(
                bezel: .meterBezelLight,
                face: .meterFaceLight,
                scale: .meterScaleLight,
                needle: .meterNeedleLight,
                pivot: .meterPivotLight,
                digitalBackground: .digitalBackground,
                digitalText: .digitalText,
                digitalSegmentOff: .digitalSegmentOff,
                digitalBorder: .digitalBorder,
                vintageBezel: .vintageBezel,
                vintageBezelHighlight: .vintageBezelHighlight,
                vintageFace: .vintageFace,
                vintageFaceEdge: .vintageFaceEdge,
                vintageArc: .vintageArc,
                vintageScale: .vintageScale,
                vintageNeedle: .vintageNeedle,
                vintagePivot: .vintagePivot,
                vintageBrass: .vintageBrass,
                vintageBrassHighlight: .vintageBrassHighlight,
                vintageBrassShadow: .vintageBrassShadow,
                vintageCasing: .vintageCasing,
                vintageCasingDark: .vintageCasingDark
            )
        }
    }
}

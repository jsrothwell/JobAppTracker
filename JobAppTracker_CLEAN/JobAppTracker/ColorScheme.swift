import SwiftUI

struct AppColors {
    // Primary Colors
    static let darkGrey = Color(hex: "1E212B")      // Background
    static let mediumGrey = Color(hex: "3A404F")    // Secondary UI
    static let lightGrey = Color(hex: "A0A5B4")     // Tertiary/Subtle
    
    // Accent
    static let professionalBlue = Color(hex: "007AFF")
    
    // Semantic Colors
    static let successGreen = Color(hex: "34C759")
    static let warningOrange = Color(hex: "FF9500")
    static let errorRed = Color(hex: "FF3B30")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Glass effect modifier
struct GlassEffect: ViewModifier {
    var opacity: Double = 0.1
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(opacity))
    }
}

extension View {
    func glassEffect(opacity: Double = 0.1) -> some View {
        modifier(GlassEffect(opacity: opacity))
    }
}

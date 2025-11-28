import SwiftUI

class UISettings: ObservableObject {
    @Published var temperature: Double {
        didSet {
            UserDefaults.standard.set(temperature, forKey: "uiTemperature")
        }
    }
    
    @Published var glassIntensity: Double {
        didSet {
            UserDefaults.standard.set(glassIntensity, forKey: "glassIntensity")
        }
    }
    
    init() {
        self.temperature = UserDefaults.standard.double(forKey: "uiTemperature")
        self.glassIntensity = UserDefaults.standard.double(forKey: "glassIntensity")
        
        // Default values if first launch
        if temperature == 0 {
            temperature = 0.5 // Neutral (blue-purple mix)
        }
        if glassIntensity == 0 {
            glassIntensity = 0.7 // Medium-high glass
        }
    }
    
    // Temperature-based colors
    var primaryGradientColors: [Color] {
        let coldColor = Color.blue
        let warmColor = Color.orange
        let neutralColor = Color.purple
        
        if temperature < 0.5 {
            // Cold to Neutral (0.0 - 0.5)
            let t = temperature * 2
            return [
                Color.blend(coldColor, neutralColor, t: t),
                Color.blend(coldColor.opacity(0.8), neutralColor.opacity(0.8), t: t)
            ]
        } else {
            // Neutral to Warm (0.5 - 1.0)
            let t = (temperature - 0.5) * 2
            return [
                Color.blend(neutralColor, warmColor, t: t),
                Color.blend(neutralColor.opacity(0.8), warmColor.opacity(0.8), t: t)
            ]
        }
    }
    
    var accentColor: Color {
        let coldColor = Color.blue
        let warmColor = Color.orange
        let neutralColor = Color.purple
        
        if temperature < 0.5 {
            let t = temperature * 2
            return Color.blend(coldColor, neutralColor, t: t)
        } else {
            let t = (temperature - 0.5) * 2
            return Color.blend(neutralColor, warmColor, t: t)
        }
    }
    
    var backgroundGradientColors: [Color] {
        if temperature < 0.33 {
            // Cold blue
            return [
                Color(red: 0.05, green: 0.1, blue: 0.2),
                Color(red: 0.1, green: 0.15, blue: 0.25),
                Color(red: 0.08, green: 0.12, blue: 0.22)
            ]
        } else if temperature < 0.66 {
            // Neutral purple
            return [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.15, green: 0.12, blue: 0.2),
                Color(red: 0.12, green: 0.1, blue: 0.18)
            ]
        } else {
            // Warm orange-red
            return [
                Color(red: 0.15, green: 0.08, blue: 0.1),
                Color(red: 0.2, green: 0.1, blue: 0.12),
                Color(red: 0.18, green: 0.09, blue: 0.11)
            ]
        }
    }
    
    // Glass material based on intensity
    var glassMaterial: Material {
        if glassIntensity < 0.33 {
            return .regular
        } else if glassIntensity < 0.66 {
            return .thin
        } else {
            return .ultraThin
        }
    }
    
    var glassOpacity: Double {
        return 0.3 + (glassIntensity * 0.4) // 0.3 to 0.7
    }
}

extension Color {
    static func blend(_ color1: Color, _ color2: Color, t: Double) -> Color {
        let t = max(0, min(1, t))
        
        let c1 = UIColor(color1)
        let c2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
    }
}

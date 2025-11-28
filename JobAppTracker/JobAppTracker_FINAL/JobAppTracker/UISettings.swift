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
        // Load saved values or use defaults
        let savedTemp = UserDefaults.standard.object(forKey: "uiTemperature") as? Double
        let savedGlass = UserDefaults.standard.object(forKey: "glassIntensity") as? Double
        
        self.temperature = savedTemp ?? 0.5
        self.glassIntensity = savedGlass ?? 0.7
    }
    
    // Simple temperature-based colors (no complex blending)
    var primaryGradientColors: [Color] {
        if temperature < 0.33 {
            // Cold - Blue
            return [Color.blue, Color.blue.opacity(0.7)]
        } else if temperature < 0.67 {
            // Neutral - Purple
            return [Color.purple, Color.purple.opacity(0.7)]
        } else {
            // Warm - Orange
            return [Color.orange, Color.orange.opacity(0.7)]
        }
    }
    
    var accentColor: Color {
        if temperature < 0.33 {
            return .blue
        } else if temperature < 0.67 {
            return .purple
        } else {
            return .orange
        }
    }
    
    var backgroundGradientColors: [Color] {
        if temperature < 0.33 {
            return [
                Color(red: 0.05, green: 0.1, blue: 0.2),
                Color(red: 0.02, green: 0.05, blue: 0.15)
            ]
        } else if temperature < 0.67 {
            return [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.05, green: 0.05, blue: 0.1)
            ]
        } else {
            return [
                Color(red: 0.15, green: 0.08, blue: 0.1),
                Color(red: 0.1, green: 0.05, blue: 0.08)
            ]
        }
    }
    
    var glassMaterial: Material {
        if glassIntensity < 0.33 {
            return .regular
        } else if glassIntensity < 0.67 {
            return .thin
        } else {
            return .ultraThin
        }
    }
    
    var glassOpacity: Double {
        return 0.3 + (glassIntensity * 0.4) // 0.3 to 0.7
    }
}

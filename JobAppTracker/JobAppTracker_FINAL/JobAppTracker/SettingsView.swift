import SwiftUI

struct SettingsView: View {
    @ObservedObject var uiSettings: UISettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background based on temperature
                LinearGradient(
                    colors: uiSettings.backgroundGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(uiSettings.glassMaterial)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .shadow(color: uiSettings.accentColor.opacity(0.3), radius: 20)
                            
                            Text("Appearance Settings")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Customize your interface")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 32)
                        
                        // Temperature Control
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "thermometer.medium")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("UI Temperature")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Adjust the color temperature from cool blue to warm orange")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 16) {
                                // Snowflake icon
                                ZStack {
                                    Circle()
                                        .fill(uiSettings.glassMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "snowflake")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                
                                // Slider
                                Slider(value: $uiSettings.temperature, in: 0...1)
                                    .tint(
                                        LinearGradient(
                                            colors: [.blue, .purple, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                // Sun icon
                                ZStack {
                                    Circle()
                                        .fill(uiSettings.glassMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "sun.max.fill")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            // Temperature indicator
                            HStack {
                                Spacer()
                                Text(temperatureLabel)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(uiSettings.accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(uiSettings.glassMaterial)
                                            .overlay(
                                                Capsule()
                                                    .stroke(uiSettings.accentColor.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(uiSettings.glassMaterial)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors.map { $0.opacity(0.1) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // Glass Intensity Control
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "circle.hexagongrid.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Glass Intensity")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Control the transparency and blur of glass elements")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 16) {
                                // Solid icon
                                ZStack {
                                    Circle()
                                        .fill(uiSettings.glassMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "square.fill")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                
                                // Slider
                                Slider(value: $uiSettings.glassIntensity, in: 0...1)
                                    .tint(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                // Glass icon
                                ZStack {
                                    Circle()
                                        .fill(uiSettings.glassMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "square.dotted")
                                        .font(.title3)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: uiSettings.primaryGradientColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            }
                            
                            // Glass intensity indicator
                            HStack {
                                Spacer()
                                Text(glassLabel)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(uiSettings.accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(uiSettings.glassMaterial)
                                            .overlay(
                                                Capsule()
                                                    .stroke(uiSettings.accentColor.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(uiSettings.glassMaterial)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: uiSettings.primaryGradientColors.map { $0.opacity(0.1) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 12) {
                                ForEach(0..<3) { i in
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(uiSettings.glassMaterial)
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Image(systemName: ["star.fill", "heart.fill", "bolt.fill"][i])
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: uiSettings.primaryGradientColors,
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .shadow(color: uiSettings.accentColor.opacity(0.3), radius: 10)
                                        
                                        Text("Sample")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(uiSettings.glassMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(uiSettings.glassMaterial)
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: uiSettings.primaryGradientColors.map { $0.opacity(0.4) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var temperatureLabel: String {
        if uiSettings.temperature < 0.33 {
            return "❄️ Cool Blue"
        } else if uiSettings.temperature < 0.66 {
            return "💜 Neutral Purple"
        } else {
            return "☀️ Warm Orange"
        }
    }
    
    private var glassLabel: String {
        if uiSettings.glassIntensity < 0.33 {
            return "Solid"
        } else if uiSettings.glassIntensity < 0.66 {
            return "Medium Glass"
        } else {
            return "Ultra Glass"
        }
    }
}

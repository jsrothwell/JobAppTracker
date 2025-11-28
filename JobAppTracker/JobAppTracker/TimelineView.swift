import SwiftUI

struct TimelineView: View {
    let job: Job
    
    var sortedHistory: [Job.StatusChange] {
        job.statusHistory.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header with glass effect
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Timeline")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(sortedHistory.count) status changes")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 32)
                
                // Timeline items with glass effect
                ForEach(Array(sortedHistory.enumerated()), id: \.element.id) { index, change in
                    GlassTimelineItemView(
                        statusChange: change,
                        isFirst: index == 0,
                        isLast: index == sortedHistory.count - 1
                    )
                }
                
                if sortedHistory.isEmpty {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .shadow(color: .blue.opacity(0.2), radius: 20)
                            
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("No timeline history yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GlassTimelineItemView: View {
    let statusChange: Job.StatusChange
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator with glow
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 24)
                }
                
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color(statusChange.status.color))
                        .frame(width: 32, height: 32)
                        .blur(radius: 8)
                        .opacity(0.6)
                    
                    // Glass circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 28, height: 28)
                    
                    // Inner color
                    Circle()
                        .fill(Color(statusChange.status.color))
                        .frame(width: 24, height: 24)
                    
                    // Icon
                    Image(systemName: statusChange.status.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: Color(statusChange.status.color).opacity(0.5), radius: 10, x: 0, y: 5)
                
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                }
            }
            .frame(width: 32)
            
            // Content with glass card
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(statusChange.status.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(statusChange.status.color),
                                        Color(statusChange.status.color).opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(statusChange.date, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(statusChange.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                }
                
                if !statusChange.notes.isEmpty {
                    Text(statusChange.notes)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(statusChange.status.color).opacity(0.08))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(statusChange.status.color).opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Days since this status
                if isFirst {
                    let days = Calendar.current.dateComponents([.day], from: statusChange.date, to: Date()).day ?? 0
                    if days > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text("\(days) day\(days == 1 ? "" : "s") in this status")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 4)
                    }
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(statusChange.status.color).opacity(0.05),
                                    Color(statusChange.status.color).opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.bottom, isLast ? 0 : 20)
        }
    }
}

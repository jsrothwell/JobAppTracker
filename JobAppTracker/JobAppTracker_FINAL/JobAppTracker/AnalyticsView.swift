import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var jobStore: JobStore
    @ObservedObject var uiSettings: UISettings
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(uiSettings.glassMaterial)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: uiSettings.primaryGradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: uiSettings.accentColor.opacity(0.2), radius: 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Analytics")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Insights into your job search")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Key Metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    SimpleMetricCard(
                        title: "Total Jobs",
                        value: "\(jobStore.jobs.count)",
                        icon: "briefcase.fill",
                        color: uiSettings.accentColor,
                        material: uiSettings.glassMaterial
                    )
                    
                    SimpleMetricCard(
                        title: "Active",
                        value: "\(activeCount)",
                        icon: "flame.fill",
                        color: .orange,
                        material: uiSettings.glassMaterial
                    )
                    
                    SimpleMetricCard(
                        title: "Success Rate",
                        value: "\(Int(successRate))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green,
                        material: uiSettings.glassMaterial
                    )
                    
                    SimpleMetricCard(
                        title: "Response",
                        value: "\(averageResponseDays)d",
                        icon: "clock.fill",
                        color: uiSettings.accentColor,
                        material: uiSettings.glassMaterial
                    )
                }
                .padding(.horizontal, 24)
                
                // Status Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status Breakdown")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    if jobStore.jobs.isEmpty {
                        EmptyAnalyticsState(
                            icon: "chart.pie.fill",
                            message: "No data yet - add your first job!",
                            material: uiSettings.glassMaterial,
                            gradientColors: uiSettings.primaryGradientColors
                        )
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Job.JobStatus.allCases, id: \.self) { status in
                                let count = jobStore.jobs.filter { $0.status == status }.count
                                if count > 0 {
                                    StatusRow(
                                        status: status,
                                        count: count,
                                        total: jobStore.jobs.count,
                                        material: uiSettings.glassMaterial
                                    )
                                }
                            }
                        }
                        .padding(20)
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
                                    colors: uiSettings.primaryGradientColors.map { $0.opacity(0.05) },
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
                .padding(.horizontal, 24)
                
                // Top Companies
                if !topCompanies.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Most Applied")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(topCompanies.prefix(5).enumerated()), id: \.offset) { index, item in
                                CompanyRow(
                                    rank: index + 1,
                                    company: item.company,
                                    count: item.count,
                                    gradientColors: uiSettings.primaryGradientColors,
                                    material: uiSettings.glassMaterial
                                )
                            }
                        }
                        .padding(20)
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(uiSettings.glassMaterial)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: uiSettings.primaryGradientColors.map { $0.opacity(0.05) },
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
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private var activeCount: Int {
        jobStore.jobs.filter { $0.status == .applied || $0.status == .interviewing }.count
    }
    
    private var successRate: Double {
        let total = jobStore.jobs.count
        guard total > 0 else { return 0 }
        let successful = jobStore.jobs.filter { $0.status == .offer || $0.status == .accepted }.count
        return (Double(successful) / Double(total)) * 100
    }
    
    private var averageResponseDays: Int {
        let jobs = jobStore.jobs.filter { $0.statusHistory.count > 1 }
        guard !jobs.isEmpty else { return 0 }
        
        let totalDays = jobs.compactMap { job -> Int? in
            guard let lastDate = job.statusHistory.last?.date else { return nil }
            let firstDate = job.statusHistory[0].date
            return Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day
        }.reduce(0, +)
        
        return totalDays / jobs.count
    }
    
    private var topCompanies: [(company: String, count: Int)] {
        let grouped = Dictionary(grouping: jobStore.jobs, by: { $0.company })
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

struct SimpleMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let material: Material
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(material)
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: color.opacity(0.3), radius: 10)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(material)
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.05))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

struct StatusRow: View {
    let status: Job.JobStatus
    let count: Int
    let total: Int
    let material: Material
    
    var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(count) / Double(total)) * 100)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(status.color))
                .frame(width: 12, height: 12)
            
            Text(status.rawValue)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(material)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct CompanyRow: View {
    let rank: Int
    let company: String
    let count: Int
    let gradientColors: [Color]
    let material: Material
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            Text(company)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(material)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct EmptyAnalyticsState: View {
    let icon: String
    let message: String
    let material: Material
    let gradientColors: [Color]
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(material)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

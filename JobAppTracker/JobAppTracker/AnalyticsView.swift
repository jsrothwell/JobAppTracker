import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var jobStore: JobStore
    @ObservedObject var uiSettings: UISettings
    
    var statusData: [StatusCount] {
        Job.JobStatus.allCases.map { status in
            StatusCount(
                status: status.rawValue,
                count: jobStore.jobs.filter { $0.status == status }.count,
                color: Color(status.color)
            )
        }
    }
    
    var applicationsByMonth: [MonthlyData] {
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let grouped = Dictionary(grouping: jobStore.jobs) { job in
            calendar.dateComponents([.year, .month], from: job.dateApplied)
        }
        
        return grouped.map { (components, jobs) in
            let date = calendar.date(from: components) ?? Date()
            return MonthlyData(
                month: monthFormatter.string(from: date),
                count: jobs.count,
                date: date
            )
        }.sorted { $0.date < $1.date }
    }
    
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
                    MetricCard(
                        title: "Total Jobs",
                        value: "\(jobStore.jobs.count)",
                        icon: "briefcase.fill",
                        color: uiSettings.accentColor,
                        uiSettings: uiSettings
                    )
                    
                    MetricCard(
                        title: "Active",
                        value: "\(jobStore.jobs.filter { $0.status == .applied || $0.status == .interviewing }.count)",
                        icon: "flame.fill",
                        color: .orange,
                        uiSettings: uiSettings
                    )
                    
                    MetricCard(
                        title: "Success Rate",
                        value: "\(Int(successRate))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green,
                        uiSettings: uiSettings
                    )
                    
                    MetricCard(
                        title: "Avg Response",
                        value: "\(averageResponseDays)d",
                        icon: "clock.fill",
                        color: uiSettings.accentColor,
                        uiSettings: uiSettings
                    )
                }
                .padding(.horizontal, 24)
                
                // Status Distribution Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status Distribution")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    if jobStore.jobs.isEmpty {
                        EmptyChartState(
                            icon: "chart.pie.fill",
                            message: "No data to visualize yet",
                            uiSettings: uiSettings
                        )
                    } else {
                        Chart(statusData) { item in
                            SectorMark(
                                angle: .value("Count", item.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(item.color.opacity(0.8))
                            .cornerRadius(4)
                        }
                        .frame(height: 250)
                        .padding(20)
                        .chartLegend(position: .bottom, spacing: 12)
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
                
                // Applications Over Time
                VStack(alignment: .leading, spacing: 16) {
                    Text("Applications Over Time")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    if applicationsByMonth.isEmpty {
                        EmptyChartState(
                            icon: "chart.line.uptrend.xyaxis",
                            message: "Track your progress over time",
                            uiSettings: uiSettings
                        )
                    } else {
                        Chart(applicationsByMonth) { item in
                            BarMark(
                                x: .value("Month", item.month),
                                y: .value("Applications", item.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: uiSettings.primaryGradientColors,
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(6)
                        }
                        .frame(height: 200)
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
                        Text("Most Applied Companies")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(topCompanies.prefix(5).enumerated()), id: \.element.company) { index, item in
                                CompanyRankRow(
                                    rank: index + 1,
                                    company: item.company,
                                    count: item.count,
                                    uiSettings: uiSettings
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
    
    private var successRate: Double {
        let total = jobStore.jobs.count
        guard total > 0 else { return 0 }
        let successful = jobStore.jobs.filter { $0.status == .offer || $0.status == .accepted }.count
        return (Double(successful) / Double(total)) * 100
    }
    
    private var averageResponseDays: Int {
        let jobs = jobStore.jobs.filter { !$0.statusHistory.isEmpty }
        guard !jobs.isEmpty else { return 0 }
        
        let totalDays = jobs.compactMap { job -> Int? in
            guard job.statusHistory.count > 1 else { return nil }
            let firstDate = job.statusHistory[0].date
            let lastDate = job.statusHistory.last!.date
            return Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day
        }.reduce(0, +)
        
        return jobs.isEmpty ? 0 : totalDays / jobs.count
    }
    
    private var topCompanies: [(company: String, count: Int)] {
        let grouped = Dictionary(grouping: jobStore.jobs, by: { $0.company })
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

struct StatusCount: Identifiable {
    let id = UUID()
    let status: String
    let count: Int
    let color: Color
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let count: Int
    let date: Date
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let uiSettings: UISettings
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(uiSettings.glassMaterial)
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
                    .fill(uiSettings.glassMaterial)
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

struct EmptyChartState: View {
    let icon: String
    let message: String
    let uiSettings: UISettings
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(uiSettings.glassMaterial)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: uiSettings.primaryGradientColors,
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

struct CompanyRankRow: View {
    let rank: Int
    let company: String
    let count: Int
    let uiSettings: UISettings
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: uiSettings.primaryGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            Text(company)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count) application\(count == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(uiSettings.glassMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

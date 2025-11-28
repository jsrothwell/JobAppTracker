import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var jobStore: JobStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Key Metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCard(
                        title: "Total",
                        value: "\(jobStore.jobs.count)",
                        systemImage: "briefcase.fill",
                        color: .blue
                    )
                    
                    MetricCard(
                        title: "Active",
                        value: "\(activeCount)",
                        systemImage: "paperplane.fill",
                        color: .orange
                    )
                    
                    MetricCard(
                        title: "Interviews",
                        value: "\(interviewCount)",
                        systemImage: "person.2.fill",
                        color: .purple
                    )
                    
                    MetricCard(
                        title: "Offers",
                        value: "\(offerCount)",
                        systemImage: "star.fill",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                if jobStore.jobs.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.bar",
                        description: Text("Add job applications to see analytics")
                    )
                    .frame(height: 300)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var activeCount: Int {
        jobStore.jobs.filter { $0.status == .applied || $0.status == .interviewing }.count
    }
    
    private var interviewCount: Int {
        jobStore.jobs.filter { $0.status == .interviewing }.count
    }
    
    private var offerCount: Int {
        jobStore.jobs.filter { $0.status == .offer || $0.status == .accepted }.count
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

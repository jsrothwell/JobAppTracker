import SwiftUI

struct KanbanView: View {
    let jobs: [Job]
    @Binding var viewMode: ViewMode
    @Binding var showingAddJob: Bool
    @State private var draggedJob: Job?
    
    let columns: [Job.JobStatus] = [.saved, .applied, .interviewing, .offer, .accepted, .rejected]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Kanban Board")
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Picker("View", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.professionalBlue)
                    }
                    .buttonStyle(.plain)
                    .help("Add New Application")
                }
            }
            .padding()
            .background(AppColors.mediumGrey.opacity(0.5))
            .glassEffect()
            
            Divider()
                .background(AppColors.mediumGrey)
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(columns, id: \.self) { status in
                        KanbanColumn(
                            status: status,
                            jobs: jobs.filter { $0.status == status }
                        )
                    }
                }
                .padding()
            }
        }
        .background(AppColors.darkGrey)
    }
}

struct KanbanColumn: View {
    let status: Job.JobStatus
    let jobs: [Job]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column header
            HStack {
                Text(status.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(jobs.count)")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(AppColors.lightGrey)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.mediumGrey)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(statusColor.opacity(0.2))
            .cornerRadius(8)
            
            // Cards
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(jobs) { job in
                        KanbanCard(job: job)
                    }
                    
                    if jobs.isEmpty {
                        Text("No applications")
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(AppColors.lightGrey.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }
                }
            }
            .frame(height: 500)
        }
        .frame(width: 280)
        .padding(12)
        .background(AppColors.mediumGrey.opacity(0.2))
        .glassEffect(opacity: 0.05)
        .cornerRadius(12)
    }
    
    var statusColor: Color {
        switch status {
        case .saved: return AppColors.lightGrey
        case .applied: return AppColors.professionalBlue
        case .interviewing: return AppColors.warningOrange
        case .offer, .accepted: return AppColors.successGreen
        case .rejected: return AppColors.errorRed
        case .withdrawn: return AppColors.lightGrey
        }
    }
}

struct KanbanCard: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.position)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(job.company)
                .font(.system(size: 13, design: .default))
                .foregroundColor(AppColors.lightGrey)
            
            Divider()
                .background(AppColors.mediumGrey)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(job.dateApplied, style: .date)
                }
                .font(.system(size: 11, design: .default))
                .foregroundColor(AppColors.lightGrey.opacity(0.8))
                
                Spacer()
                
                if !job.location.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(job.location)
                            .lineLimit(1)
                    }
                    .font(.system(size: 10, design: .default))
                    .foregroundColor(AppColors.lightGrey.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(AppColors.mediumGrey.opacity(0.6))
        .glassEffect(opacity: 0.1)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

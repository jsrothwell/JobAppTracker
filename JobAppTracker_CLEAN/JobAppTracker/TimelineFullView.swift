import SwiftUI

struct TimelineFullView: View {
    let jobs: [Job]
    @Binding var viewMode: ViewMode
    @Binding var showingAddJob: Bool
    
    var sortedJobs: [Job] {
        jobs.sorted { $0.dateApplied > $1.dateApplied }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Timeline")
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
            
            if sortedJobs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.lightGrey)
                    Text("No applications to display")
                        .font(.title3)
                        .foregroundColor(AppColors.lightGrey)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(sortedJobs) { job in
                            TimelineRow(job: job, isLast: job.id == sortedJobs.last?.id)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppColors.darkGrey)
    }
}

struct TimelineRow: View {
    let job: Job
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(AppColors.mediumGrey)
                        .frame(width: 2)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.position)
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Text(job.company)
                            .font(.system(size: 15, design: .default))
                            .foregroundColor(AppColors.lightGrey)
                    }
                    
                    Spacer()
                    
                    Text(job.status.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .cornerRadius(6)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(job.dateApplied, style: .date)
                    }
                    
                    if !job.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                            Text(job.location)
                        }
                    }
                }
                .font(.system(size: 13, design: .default))
                .foregroundColor(AppColors.lightGrey)
                
                if !job.notes.isEmpty {
                    Text(job.notes)
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(AppColors.lightGrey.opacity(0.8))
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.mediumGrey.opacity(0.3))
            .glassEffect(opacity: 0.05)
            .cornerRadius(12)
        }
        .padding(.bottom, isLast ? 0 : 20)
    }
    
    var statusColor: Color {
        switch job.status {
        case .saved: return AppColors.lightGrey
        case .applied: return AppColors.professionalBlue
        case .interviewing: return AppColors.warningOrange
        case .offer, .accepted: return AppColors.successGreen
        case .rejected: return AppColors.errorRed
        case .withdrawn: return AppColors.lightGrey
        }
    }
}

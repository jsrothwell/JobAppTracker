import SwiftUI

struct KanbanBoardView: View {
    @ObservedObject var jobStore: JobStore
    @Binding var viewMode: ViewMode
    @ObservedObject var uiSettings: UISettings
    @State private var draggedJob: Job?
    @State private var showingAddJob = false
    @State private var selectedJob: Job?
    
    let columns: [Job.JobStatus] = [.applied, .interviewing, .offer, .rejected, .accepted]
    
    func jobs(for status: Job.JobStatus) -> [Job] {
        jobStore.jobs.filter { $0.status == status }
            .sorted { $0.dateApplied > $1.dateApplied }
    }
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                colors: uiSettings.backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with glass effect
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Kanban Board")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Drag jobs to update their status")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    
                    // View mode picker
                    Picker("View", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                    .padding(.trailing, 12)
                    
                    Button(action: { showingAddJob = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Job")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.4),
                                                Color.purple.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                
                // Kanban columns
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(columns, id: \.self) { status in
                            GlassKanbanColumnView(
                                status: status,
                                jobs: jobs(for: status),
                                draggedJob: $draggedJob,
                                selectedJob: $selectedJob,
                                onDrop: { job in
                                    updateJobStatus(job, to: status)
                                }
                            )
                        }
                    }
                    .padding(24)
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            AddJobView(jobStore: jobStore)
        }
        .sheet(item: $selectedJob) { job in
            NavigationStack {
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.15),
                            Color(red: 0.15, green: 0.12, blue: 0.2),
                            Color(red: 0.12, green: 0.1, blue: 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Glass background overlay
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    GlassJobDetailView(job: job, jobStore: jobStore)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { selectedJob = nil }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Close")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.red.opacity(0.3),
                                                    Color.red.opacity(0.4)
                                                ],
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
                        .buttonStyle(.plain)
                        .keyboardShortcut(.cancelAction)
                    }
                }
            }
            .presentationBackground(.clear)
            .interactiveDismissDisabled(false)
        }
    }
    
    private func updateJobStatus(_ job: Job, to newStatus: Job.JobStatus) {
        var updatedJob = job
        if updatedJob.status != newStatus {
            updatedJob.updateStatus(to: newStatus, notes: "Status changed to \(newStatus.rawValue)")
            jobStore.updateJob(updatedJob)
        }
    }
}

struct GlassKanbanColumnView: View {
    let status: Job.JobStatus
    let jobs: [Job]
    @Binding var draggedJob: Job?
    @Binding var selectedJob: Job?
    let onDrop: (Job) -> Void
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Column header with glass effect
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(status.color))
                            .frame(width: 28, height: 28)
                            .blur(radius: 6)
                            .opacity(0.6)
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 24, height: 24)
                        Image(systemName: status.icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(status.color))
                    }
                    
                    Text(status.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(jobs.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                Capsule()
                                    .fill(Color(status.color).opacity(0.3))
                            }
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(status.color).opacity(0.5), lineWidth: 1)
                        )
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(status.color),
                                Color(status.color).opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(status.color).opacity(0.08))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(status.color).opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: Color(status.color).opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Cards
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(jobs) { job in
                        GlassKanbanCardView(job: job)
                            .onDrag {
                                self.draggedJob = job
                                return NSItemProvider(object: job.id.uuidString as NSString)
                            }
                            .onTapGesture {
                                selectedJob = job
                            }
                            .opacity(draggedJob?.id == job.id ? 0.5 : 1.0)
                            .scaleEffect(draggedJob?.id == job.id ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: draggedJob?.id == job.id)
                    }
                    
                    if jobs.isEmpty {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "tray")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(status.color), Color(status.color).opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            Text("No jobs")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 300)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                if isTargeted {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(status.color).opacity(0.15))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isTargeted
                        ? LinearGradient(
                            colors: [Color(status.color), Color(status.color).opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(colors: [.white.opacity(0.1)], startPoint: .top, endPoint: .bottom),
                    lineWidth: isTargeted ? 2 : 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
            guard let job = draggedJob else { return false }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                onDrop(job)
            }
            draggedJob = nil
            return true
        }
    }
}

struct GlassKanbanCardView: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(job.company)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                // Status indicator with glow
                ZStack {
                    Circle()
                        .fill(Color(job.status.color))
                        .frame(width: 12, height: 12)
                        .blur(radius: 4)
                        .opacity(0.8)
                    Circle()
                        .fill(Color(job.status.color))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Date and details with icons
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(job.dateApplied.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if !job.location.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(job.location)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                
                if !job.salary.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(job.salary)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(job.status.color).opacity(0.08),
                                Color(job.status.color).opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

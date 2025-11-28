import SwiftUI

enum ViewMode: String, CaseIterable {
    case list = "List"
    case timeline = "Timeline"
    case kanban = "Kanban"
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .timeline: return "clock"
        case .kanban: return "square.grid.2x2"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var jobStore: JobStore
    @State private var showingAddJob = false
    @State private var selectedJob: Job?
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    
    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return jobStore.jobs.sorted { $0.dateApplied > $1.dateApplied }
        }
        return jobStore.jobs.filter { job in
            job.company.localizedCaseInsensitiveContains(searchText) ||
            job.position.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.dateApplied > $1.dateApplied }
    }
    
    var body: some View {
        ZStack {
            AppColors.darkGrey.ignoresSafeArea()
            
            Group {
                switch viewMode {
                case .list:
                    ListView(
                        filteredJobs: filteredJobs,
                        selectedJob: $selectedJob,
                        searchText: $searchText,
                        showingAddJob: $showingAddJob,
                        viewMode: $viewMode
                    )
                case .timeline:
                    TimelineFullView(jobs: filteredJobs, viewMode: $viewMode, showingAddJob: $showingAddJob)
                case .kanban:
                    KanbanView(jobs: jobStore.jobs, viewMode: $viewMode, showingAddJob: $showingAddJob)
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            AddJobView(jobStore: jobStore)
        }
    }
}

struct ListView: View {
    let filteredJobs: [Job]
    @Binding var selectedJob: Job?
    @Binding var searchText: String
    @Binding var showingAddJob: Bool
    @Binding var viewMode: ViewMode
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Sidebar Header - clean, no thick borders
                VStack(alignment: .leading, spacing: 12) {
                    Text("Applications")
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                    
                    // View mode tabs
                    HStack(spacing: 0) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            ViewTabButton(
                                mode: mode,
                                isSelected: viewMode == mode,
                                action: { viewMode = mode }
                            )
                        }
                    }
                    .padding(3)
                    .background(AppColors.mediumGrey.opacity(0.5))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Search bar - integrated cleanly
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.lightGrey.opacity(0.7))
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .default))
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(AppColors.mediumGrey.opacity(0.4))
                .cornerRadius(6)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Subtle divider - no thick borders
                Divider()
                    .background(AppColors.lightGrey.opacity(0.1))
                
                // Job List
                if filteredJobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.lightGrey.opacity(0.4))
                        Text("No applications")
                            .font(.system(size: 14, design: .default))
                            .foregroundColor(AppColors.lightGrey.opacity(0.6))
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredJobs) { job in
                                JobListRow(job: job, isSelected: selectedJob?.id == job.id)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedJob = job
                                        }
                                    }
                                Divider()
                                    .background(AppColors.lightGrey.opacity(0.05))
                            }
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .background(AppColors.darkGrey)
            .navigationSplitViewColumnWidth(min: 260, ideal: 280, max: 320)
            
        } detail: {
            if let job = selectedJob {
                JobDetailPanel(job: job)
            } else {
                // Empty state - clean, representative
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 56, weight: .thin))
                        .foregroundColor(AppColors.lightGrey.opacity(0.3))
                    Text("Select an application")
                        .font(.system(size: 17, design: .default))
                        .foregroundColor(AppColors.lightGrey.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        AppColors.darkGrey
                        // Subtle glass depth for background
                        LinearGradient(
                            colors: [
                                AppColors.mediumGrey.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showingAddJob = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.professionalBlue)
                }
                .help("Add New Application")
            }
        }
    }
}

struct ViewTabButton: View {
    let mode: ViewMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 11))
                Text(mode.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .default))
            }
            .foregroundColor(isSelected ? .white : AppColors.lightGrey.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.professionalBlue : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct JobListRow: View {
    let job: Job
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(job.position)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(job.company)
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(AppColors.lightGrey.opacity(0.8))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(job.status.rawValue)
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundColor(statusColor)
                    
                    Text("•")
                        .font(.system(size: 8))
                        .foregroundColor(AppColors.lightGrey.opacity(0.4))
                    
                    Text(job.dateApplied, style: .date)
                        .font(.system(size: 10, design: .default))
                        .foregroundColor(AppColors.lightGrey.opacity(0.6))
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                if isSelected {
                    // Subtle glass effect for selected state
                    AppColors.mediumGrey.opacity(0.5)
                    LinearGradient(
                        colors: [
                            AppColors.professionalBlue.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            }
        )
        .contentShape(Rectangle())
    }
    
    var statusColor: Color {
        switch job.status {
        case .saved: return AppColors.lightGrey
        case .applied: return AppColors.professionalBlue
        case .interviewing: return AppColors.warningOrange
        case .offer, .accepted: return AppColors.successGreen
        case .rejected: return AppColors.errorRed
        case .withdrawn: return AppColors.lightGrey.opacity(0.6)
        }
    }
}

struct JobDetailPanel: View {
    let job: Job
    @EnvironmentObject var jobStore: JobStore
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Clean header - no bright white bar
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(job.position)
                            .font(.system(size: 24, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Text(job.company)
                            .font(.system(size: 16, design: .default))
                            .foregroundColor(AppColors.lightGrey)
                    }
                    
                    Spacer()
                    
                    // Status badge
                    Text(job.status.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor)
                        .cornerRadius(6)
                }
                
                // Metadata
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(job.dateApplied, style: .date)
                            .font(.system(size: 12, design: .default))
                    }
                    .foregroundColor(AppColors.lightGrey.opacity(0.8))
                    
                    if !job.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 11))
                            Text(job.location)
                                .font(.system(size: 12, design: .default))
                        }
                        .foregroundColor(AppColors.lightGrey.opacity(0.8))
                    }
                    
                    if !job.salary.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 11))
                            Text(job.salary)
                                .font(.system(size: 12, design: .default))
                        }
                        .foregroundColor(AppColors.lightGrey.opacity(0.8))
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    AppColors.mediumGrey.opacity(0.3)
                    // Subtle frosted glass effect
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            
            Divider()
                .background(AppColors.lightGrey.opacity(0.1))
            
            // Tab content
            TabView(selection: $selectedTab) {
                DetailsTab(job: job)
                    .tabItem {
                        Label("Details", systemImage: "info.circle")
                    }
                    .tag(0)
                
                TimelineView(job: job)
                    .tabItem {
                        Label("Timeline", systemImage: "clock")
                    }
                    .tag(1)
                
                AttachmentsView(job: job, jobStore: jobStore)
                    .tabItem {
                        Label("Attachments", systemImage: "paperclip")
                    }
                    .tag(2)
                
                RemindersView(job: job, jobStore: jobStore)
                    .tabItem {
                        Label("Reminders", systemImage: "bell")
                    }
                    .tag(3)
            }
            .background(AppColors.darkGrey)
        }
        .background(AppColors.darkGrey)
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

struct DetailsTab: View {
    let job: Job
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !job.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Text(job.notes)
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(AppColors.lightGrey)
                            .textSelection(.enabled)
                    }
                    .padding(16)
                    .background(AppColors.mediumGrey.opacity(0.2))
                    .cornerRadius(8)
                }
                
                if !job.contactEmail.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Link(job.contactEmail, destination: URL(string: "mailto:\(job.contactEmail)")!)
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(AppColors.professionalBlue)
                    }
                    .padding(16)
                    .background(AppColors.mediumGrey.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(AppColors.darkGrey)
    }
}

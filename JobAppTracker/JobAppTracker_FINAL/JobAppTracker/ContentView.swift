import SwiftUI

enum ViewMode: String, CaseIterable {
    case list = "List"
    case kanban = "Kanban"
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .kanban: return "square.grid.2x2"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var jobStore: JobStore
    @StateObject private var uiSettings = UISettings()
    @State private var showingAddJob = false
    @State private var selectedJob: Job?
    @State private var searchText = ""
    @State private var filterStatus: Job.JobStatus?
    @State private var viewMode: ViewMode = .list
    @State private var showingSettings = false
    @State private var showingAnalytics = false
    
    var filteredJobs: [Job] {
        var filtered = jobStore.jobs
        
        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { job in
                job.company.localizedCaseInsensitiveContains(searchText) ||
                job.position.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.dateApplied > $1.dateApplied }
    }
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on temperature
            LinearGradient(
                colors: uiSettings.backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Group {
                if viewMode == .kanban {
                    KanbanBoardView(jobStore: jobStore, viewMode: $viewMode, uiSettings: uiSettings)
                } else {
                    NavigationSplitView {
                        ZStack {
                            // Sidebar background with glass effect
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 0) {
                                // Header with glass morphism
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Job Applications")
                                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.white, .white.opacity(0.9)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                            Text("\(jobStore.jobs.count) total applications")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        Spacer()
                                        
                                        // Analytics button
                                        Button(action: { showingAnalytics = true }) {
                                            Image(systemName: "chart.bar.xaxis")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(
                                                    Circle()
                                                        .fill(uiSettings.glassMaterial)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .shadow(color: uiSettings.accentColor.opacity(0.3), radius: 8)
                                        
                                        // Settings button
                                        Button(action: { showingSettings = true }) {
                                            Image(systemName: "slider.horizontal.3")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(
                                                    Circle()
                                                        .fill(uiSettings.glassMaterial)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .shadow(color: uiSettings.accentColor.opacity(0.3), radius: 8)
                                        
                                        // View mode picker with glass effect
                                        Picker("View", selection: $viewMode) {
                                            ForEach(ViewMode.allCases, id: \.self) { mode in
                                                Label(mode.rawValue, systemImage: mode.icon)
                                                    .tag(mode)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        .frame(width: 180)
                                    }
                                    
                                    // Add button with glass effect
                                    Button(action: { showingAddJob = true }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add New Job")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.ultraThinMaterial)
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.blue.opacity(0.3),
                                                                Color.blue.opacity(0.5)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            }
                                        )
                                        .foregroundColor(.white)
                                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(20)
                                
                                // Search with glass morphism
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white.opacity(0.5))
                                            .font(.system(size: 16, weight: .medium))
                                        TextField("Search jobs...", text: $searchText)
                                            .textFieldStyle(.plain)
                                            .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                                    
                                    // Filter chips with glass effect
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            GlassFilterChip(title: "All", isSelected: filterStatus == nil) {
                                                filterStatus = nil
                                            }
                                            ForEach(Job.JobStatus.allCases, id: \.self) { status in
                                                GlassFilterChip(
                                                    title: status.rawValue,
                                                    isSelected: filterStatus == status,
                                                    color: Color(status.color)
                                                ) {
                                                    filterStatus = status
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                                
                                // Stats with glass cards
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        GlassStatCard(title: "Total", value: "\(jobStore.jobs.count)", color: .blue)
                                        GlassStatCard(title: "Active", value: "\(jobStore.jobs.filter { $0.status == .applied || $0.status == .interviewing }.count)", color: .orange)
                                        GlassStatCard(title: "Offers", value: "\(jobStore.jobs.filter { $0.status == .offer }.count)", color: .green)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.bottom, 16)
                                
                                // Job List with glass cards
                                if filteredJobs.isEmpty {
                                    VStack(spacing: 20) {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .frame(width: 100, height: 100)
                                                .shadow(color: .blue.opacity(0.2), radius: 20)
                                            
                                            Image(systemName: "briefcase.fill")
                                                .font(.system(size: 40))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.blue, .purple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                        
                                        VStack(spacing: 8) {
                                            Text(searchText.isEmpty && filterStatus == nil ? "No jobs yet" : "No jobs found")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            if searchText.isEmpty && filterStatus == nil {
                                                Text("Click the button above to add your first application")
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 40)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    ScrollView {
                                        LazyVStack(spacing: 12) {
                                            ForEach(filteredJobs) { job in
                                                GlassJobRowView(job: job)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                            selectedJob = job
                                                        }
                                                    }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 20)
                                    }
                                }
                            }
                        }
                    } detail: {
                        if let job = selectedJob {
                            GlassJobDetailView(job: job, jobStore: jobStore)
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .ignoresSafeArea()
                                
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 100, height: 100)
                                            .shadow(color: .blue.opacity(0.2), radius: 20)
                                        
                                        Image(systemName: "sidebar.left")
                                            .font(.system(size: 40))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    
                                    Text("Select a job to view details")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddJob) {
                        AddJobView(jobStore: jobStore)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showingSettings) {
            SettingsView(uiSettings: uiSettings)
        }
        .sheet(isPresented: $showingAnalytics) {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: uiSettings.backgroundGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    AnalyticsView(jobStore: jobStore, uiSettings: uiSettings)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingAnalytics = false
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Glass UI Components

struct GlassFilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            color.opacity(0.3),
                                            color.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .opacity(0.5)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color.opacity(0.5) : .white.opacity(0.1), lineWidth: 1)
                )
                .foregroundColor(.white)
                .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct GlassStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 100, height: 90)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct GlassJobRowView: View {
    let job: Job
    
    var body: some View {
        HStack(spacing: 16) {
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
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Reminder badges
                    if !job.overdueReminders.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.badge.fill")
                                .font(.caption2)
                            Text("\(job.overdueReminders.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                    } else if !job.pendingReminders.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text("\(job.pendingReminders.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                        )
                    }
                    
                    // Attachment badge
                    if !job.attachments.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "paperclip")
                                .font(.caption2)
                            Text("\(job.attachments.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                
                Text(job.company)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(job.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(job.status.color), Color(job.status.color).opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color(job.status.color).opacity(0.3), lineWidth: 1)
                            )
                    )
                
                Text(job.dateApplied, style: .date)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
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
                                Color(job.status.color).opacity(0.05),
                                Color(job.status.color).opacity(0.02)
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
    }
}

struct GlassJobDetailView: View {
    let job: Job
    @ObservedObject var jobStore: JobStore
    @State private var selectedTab: DetailTab = .details
    
    enum DetailTab: String, CaseIterable {
        case details = "Details"
        case timeline = "Timeline"
        case attachments = "Attachments"
        case reminders = "Reminders"
        
        var icon: String {
            switch self {
            case .details: return "info.circle.fill"
            case .timeline: return "clock.fill"
            case .attachments: return "paperclip.circle.fill"
            case .reminders: return "bell.badge.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab selector with glass effect - 2 rows for 4 tabs
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        GlassTabButton(
                            title: DetailTab.details.rawValue,
                            icon: DetailTab.details.icon,
                            isSelected: selectedTab == .details
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = .details
                            }
                        }
                        
                        GlassTabButton(
                            title: DetailTab.timeline.rawValue,
                            icon: DetailTab.timeline.icon,
                            isSelected: selectedTab == .timeline
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = .timeline
                            }
                        }
                    }
                    
                    HStack(spacing: 8) {
                        GlassTabButton(
                            title: DetailTab.attachments.rawValue,
                            icon: DetailTab.attachments.icon,
                            isSelected: selectedTab == .attachments,
                            badge: job.attachments.count
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = .attachments
                            }
                        }
                        
                        GlassTabButton(
                            title: DetailTab.reminders.rawValue,
                            icon: DetailTab.reminders.icon,
                            isSelected: selectedTab == .reminders,
                            badge: job.pendingReminders.count + job.overdueReminders.count,
                            badgeColor: job.overdueReminders.isEmpty ? nil : .red
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = .reminders
                            }
                        }
                    }
                }
                .padding(20)
                
                // Content
                switch selectedTab {
                case .details:
                    JobDetailView(job: job, jobStore: jobStore)
                case .timeline:
                    TimelineView(job: job)
                case .attachments:
                    AttachmentsView(job: job, jobStore: jobStore)
                case .reminders:
                    RemindersView(job: job, jobStore: jobStore)
                }
            }
        }
    }
}

struct GlassTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var badge: Int = 0
    var badgeColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(badgeColor ?? .blue)
                        )
                }
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.3),
                                        Color.purple.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .white.opacity(0.2) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

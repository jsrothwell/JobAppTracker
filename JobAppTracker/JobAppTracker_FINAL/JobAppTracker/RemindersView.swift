import SwiftUI

struct RemindersView: View {
    let job: Job
    @ObservedObject var jobStore: JobStore
    @State private var showingAddReminder = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: .orange.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reminders")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(job.reminders.count) reminder\(job.reminders.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 8)
                
                // Add reminder button
                Button(action: { showingAddReminder = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Reminder")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.3),
                                            Color.red.opacity(0.3)
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
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                
                // Overdue reminders
                if !job.overdueReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Overdue")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        ForEach(job.overdueReminders) { reminder in
                            GlassReminderRow(
                                reminder: reminder,
                                isOverdue: true,
                                onToggle: { toggleReminder(reminder) },
                                onDelete: { deleteReminder(reminder) }
                            )
                        }
                    }
                }
                
                // Pending reminders
                if !job.pendingReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Upcoming")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        ForEach(job.pendingReminders) { reminder in
                            GlassReminderRow(
                                reminder: reminder,
                                isOverdue: false,
                                onToggle: { toggleReminder(reminder) },
                                onDelete: { deleteReminder(reminder) }
                            )
                        }
                    }
                }
                
                // Completed reminders
                let completedReminders = job.reminders.filter { $0.isCompleted }
                if !completedReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Completed")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        ForEach(completedReminders) { reminder in
                            GlassReminderRow(
                                reminder: reminder,
                                isOverdue: false,
                                onToggle: { toggleReminder(reminder) },
                                onDelete: { deleteReminder(reminder) }
                            )
                        }
                    }
                }
                
                // Empty state
                if job.reminders.isEmpty {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .shadow(color: .orange.opacity(0.2), radius: 20)
                            
                            Image(systemName: "bell.badge.plus")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("No reminders yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Set reminders for follow-ups and interviews")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(job: job, jobStore: jobStore)
        }
    }
    
    private func toggleReminder(_ reminder: Job.Reminder) {
        var updatedReminder = reminder
        updatedReminder.isCompleted.toggle()
        
        var updatedJob = job
        updatedJob.updateReminder(updatedReminder)
        jobStore.updateJob(updatedJob)
    }
    
    private func deleteReminder(_ reminder: Job.Reminder) {
        var updatedJob = job
        updatedJob.removeReminder(reminder)
        jobStore.updateJob(updatedJob)
    }
}

struct GlassReminderRow: View {
    let reminder: Job.Reminder
    let isOverdue: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 28, height: 28)
                    
                    if reminder.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    } else {
                        Circle()
                            .stroke(isOverdue ? Color.red : Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: reminder.type.icon)
                        .font(.caption)
                        .foregroundColor(Color(reminder.type.color))
                    
                    Text(reminder.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(reminder.isCompleted ? .white.opacity(0.5) : .white)
                        .strikethrough(reminder.isCompleted)
                }
                
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(reminder.date, style: .date)
                            .font(.caption)
                    }
                    .foregroundColor(isOverdue ? .red : .white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(reminder.date, style: .time)
                            .font(.caption)
                    }
                    .foregroundColor(isOverdue ? .red : .white.opacity(0.5))
                    
                    if isOverdue && !reminder.isCompleted {
                        Text("OVERDUE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.3))
                            )
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
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
                                isOverdue ? Color.red.opacity(0.1) : Color(reminder.type.color).opacity(0.05),
                                isOverdue ? Color.red.opacity(0.05) : Color(reminder.type.color).opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isOverdue ? Color.red.opacity(0.3) : .white.opacity(0.1), lineWidth: isOverdue ? 1.5 : 1)
        )
        .shadow(color: isOverdue ? Color.red.opacity(0.2) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    let job: Job
    @ObservedObject var jobStore: JobStore
    
    @State private var title = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var type: Job.Reminder.ReminderType = .followUp
    
    var body: some View {
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            TextField("e.g., Follow up with recruiter", text: $title)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            Picker("Type", selection: $type) {
                                ForEach(Job.Reminder.ReminderType.allCases, id: \.self) { type in
                                    Label(type.rawValue, systemImage: type.icon).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date & Time")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            DatePicker("", selection: $date)
                                .datePickerStyle(.graphical)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (Optional)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            TextEditor(text: $note)
                                .foregroundColor(.white)
                                .frame(height: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReminder() }
                        .foregroundColor(.blue)
                        .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveReminder() {
        let reminder = Job.Reminder(
            title: title,
            note: note,
            date: date,
            isCompleted: false,
            type: type
        )
        
        var updatedJob = job
        updatedJob.addReminder(reminder)
        jobStore.updateJob(updatedJob)
        dismiss()
    }
}

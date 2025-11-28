import SwiftUI

struct EditJobView: View {
    @Environment(\.dismiss) var dismiss
    let job: Job
    @ObservedObject var jobStore: JobStore
    
    @State private var company: String
    @State private var position: String
    @State private var status: Job.JobStatus
    @State private var dateApplied: Date
    @State private var notes: String
    @State private var contactEmail: String
    @State private var salary: String
    @State private var location: String
    @State private var statusChangeNotes: String = ""
    
    private var hasStatusChanged: Bool {
        status != job.status
    }
    
    init(job: Job, jobStore: JobStore) {
        self.job = job
        self.jobStore = jobStore
        _company = State(initialValue: job.company)
        _position = State(initialValue: job.position)
        _status = State(initialValue: job.status)
        _dateApplied = State(initialValue: job.dateApplied)
        _notes = State(initialValue: job.notes)
        _contactEmail = State(initialValue: job.contactEmail)
        _salary = State(initialValue: job.salary)
        _location = State(initialValue: job.location)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Job Information") {
                    TextField("Company", text: $company)
                    TextField("Position", text: $position)
                    TextField("Location", text: $location)
                    TextField("Salary Range", text: $salary)
                }
                
                Section("Application Details") {
                    Picker("Status", selection: $status) {
                        ForEach(Job.JobStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    if hasStatusChanged {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Status Change Note")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Add a note about this status change...", text: $statusChangeNotes)
                        }
                    }
                    
                    DatePicker("Date Applied", selection: $dateApplied, displayedComponents: .date)
                    TextField("Contact Email", text: $contactEmail)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(role: .destructive, action: deleteJob) {
                        Label("Delete Job", systemImage: "trash")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Job")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJob()
                    }
                    .disabled(company.isEmpty || position.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    private func saveJob() {
        var updatedJob = job
        updatedJob.company = company
        updatedJob.position = position
        updatedJob.dateApplied = dateApplied
        updatedJob.notes = notes
        updatedJob.contactEmail = contactEmail
        updatedJob.salary = salary
        updatedJob.location = location
        
        // Handle status change with timeline
        if updatedJob.status != status {
            let changeNote = statusChangeNotes.isEmpty 
                ? "Status changed to \(status.rawValue)" 
                : statusChangeNotes
            updatedJob.updateStatus(to: status, notes: changeNote)
        }
        
        jobStore.updateJob(updatedJob)
        dismiss()
    }
    
    private func deleteJob() {
        jobStore.deleteJob(job)
        dismiss()
    }
}

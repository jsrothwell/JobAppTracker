import SwiftUI

struct AddJobView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var jobStore: JobStore
    
    @State private var company = ""
    @State private var position = ""
    @State private var status: Job.JobStatus = .applied
    @State private var dateApplied = Date()
    @State private var notes = ""
    @State private var contactEmail = ""
    @State private var salary = ""
    @State private var location = ""
    
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
                    DatePicker("Date Applied", selection: $dateApplied, displayedComponents: .date)
                    TextField("Contact Email", text: $contactEmail)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add New Job")
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
        .frame(width: 500, height: 550)
    }
    
    private func saveJob() {
        let newJob = Job(
            company: company,
            position: position,
            status: status,
            dateApplied: dateApplied,
            notes: notes,
            contactEmail: contactEmail,
            salary: salary,
            location: location
        )
        jobStore.addJob(newJob)
        dismiss()
    }
}

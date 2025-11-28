import Foundation

struct Job: Identifiable, Codable {
    var id = UUID()
    var company: String
    var position: String
    var status: JobStatus
    var dateApplied: Date
    var notes: String
    var contactEmail: String
    var salary: String
    var location: String
    var statusHistory: [StatusChange] = []
    var attachments: [Attachment] = []
    var reminders: [Reminder] = []
    var tags: [String] = []
    
    struct Attachment: Identifiable, Codable {
        var id = UUID()
        var name: String
        var fileURL: URL
        var type: AttachmentType
        var dateAdded: Date
        
        enum AttachmentType: String, Codable {
            case resume = "Resume"
            case coverLetter = "Cover Letter"
            case jobDescription = "Job Description"
            case offer = "Offer Letter"
            case other = "Other"
            
            var icon: String {
                switch self {
                case .resume: return "doc.text.fill"
                case .coverLetter: return "envelope.fill"
                case .jobDescription: return "doc.plaintext.fill"
                case .offer: return "doc.richtext.fill"
                case .other: return "doc.fill"
                }
            }
            
            var color: String {
                switch self {
                case .resume: return "blue"
                case .coverLetter: return "purple"
                case .jobDescription: return "orange"
                case .offer: return "green"
                case .other: return "gray"
                }
            }
        }
    }
    
    struct Reminder: Identifiable, Codable {
        var id = UUID()
        var title: String
        var note: String
        var date: Date
        var isCompleted: Bool
        var type: ReminderType
        
        enum ReminderType: String, Codable, CaseIterable {
            case followUp = "Follow Up"
            case interview = "Interview"
            case deadline = "Deadline"
            case phoneCall = "Phone Call"
            case thankYou = "Thank You Note"
            case other = "Other"
            
            var icon: String {
                switch self {
                case .followUp: return "arrow.turn.up.right"
                case .interview: return "person.2.fill"
                case .deadline: return "clock.badge.exclamationmark"
                case .phoneCall: return "phone.fill"
                case .thankYou: return "envelope.badge.fill"
                case .other: return "bell.fill"
                }
            }
            
            var color: String {
                switch self {
                case .followUp: return "blue"
                case .interview: return "orange"
                case .deadline: return "red"
                case .phoneCall: return "green"
                case .thankYou: return "purple"
                case .other: return "gray"
                }
            }
        }
        
        var isOverdue: Bool {
            !isCompleted && date < Date()
        }
        
        var isPending: Bool {
            !isCompleted && date >= Date()
        }
    }
    
    struct StatusChange: Identifiable, Codable {
        var id = UUID()
        var status: JobStatus
        var date: Date
        var notes: String
        
        init(status: JobStatus, date: Date = Date(), notes: String = "") {
            self.status = status
            self.date = date
            self.notes = notes
        }
    }
    
    enum JobStatus: String, Codable, CaseIterable {
        case applied = "Applied"
        case interviewing = "Interviewing"
        case offer = "Offer"
        case rejected = "Rejected"
        case accepted = "Accepted"
        
        var color: String {
            switch self {
            case .applied: return "blue"
            case .interviewing: return "orange"
            case .offer: return "green"
            case .rejected: return "red"
            case .accepted: return "purple"
            }
        }
        
        var icon: String {
            switch self {
            case .applied: return "paperplane.fill"
            case .interviewing: return "person.2.fill"
            case .offer: return "star.fill"
            case .rejected: return "xmark.circle.fill"
            case .accepted: return "checkmark.seal.fill"
            }
        }
    }
    
    mutating func updateStatus(to newStatus: JobStatus, notes: String = "") {
        self.status = newStatus
        self.statusHistory.append(StatusChange(status: newStatus, date: Date(), notes: notes))
    }
    
    mutating func addAttachment(_ attachment: Attachment) {
        self.attachments.append(attachment)
    }
    
    mutating func removeAttachment(_ attachment: Attachment) {
        self.attachments.removeAll { $0.id == attachment.id }
    }
    
    mutating func addReminder(_ reminder: Reminder) {
        self.reminders.append(reminder)
    }
    
    mutating func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        }
    }
    
    mutating func removeReminder(_ reminder: Reminder) {
        self.reminders.removeAll { $0.id == reminder.id }
    }
    
    mutating func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
        }
    }
    
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    var pendingReminders: [Reminder] {
        reminders.filter { $0.isPending }.sorted { $0.date < $1.date }
    }
    
    var overdueReminders: [Reminder] {
        reminders.filter { $0.isOverdue }.sorted { $0.date < $1.date }
    }
    
    init(company: String, position: String, status: JobStatus, dateApplied: Date, notes: String, contactEmail: String, salary: String, location: String) {
        self.company = company
        self.position = position
        self.status = status
        self.dateApplied = dateApplied
        self.notes = notes
        self.contactEmail = contactEmail
        self.salary = salary
        self.location = location
        self.statusHistory = [StatusChange(status: status, date: dateApplied, notes: "Application submitted")]
        self.attachments = []
        self.reminders = []
        self.tags = []
    }
}

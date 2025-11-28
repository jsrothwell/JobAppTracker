import SwiftUI
import UniformTypeIdentifiers

struct AttachmentsView: View {
    let job: Job
    @ObservedObject var jobStore: JobStore
    @State private var showingFilePicker = false
    @State private var selectedAttachmentType: Job.Attachment.AttachmentType = .resume
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "paperclip.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Attachments")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(job.attachments.count) document\(job.attachments.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 8)
                
                // Add attachment button
                Button(action: { showingFilePicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Document")
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
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.3)
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
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                
                // Attachments list
                if job.attachments.isEmpty {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .shadow(color: .blue.opacity(0.2), radius: 20)
                            
                            Image(systemName: "doc.badge.plus")
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
                            Text("No attachments yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Add resumes, cover letters, or job descriptions")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(job.attachments) { attachment in
                            GlassAttachmentRow(attachment: attachment) {
                                openAttachment(attachment)
                            } onDelete: {
                                deleteAttachment(attachment)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf, .plainText, .rtf, .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Show picker for attachment type
            let attachment = Job.Attachment(
                name: url.lastPathComponent,
                fileURL: url,
                type: selectedAttachmentType,
                dateAdded: Date()
            )
            
            var updatedJob = job
            updatedJob.addAttachment(attachment)
            jobStore.updateJob(updatedJob)
            
        case .failure(let error):
            print("Error selecting file: \(error.localizedDescription)")
        }
    }
    
    private func openAttachment(_ attachment: Job.Attachment) {
        NSWorkspace.shared.open(attachment.fileURL)
    }
    
    private func deleteAttachment(_ attachment: Job.Attachment) {
        var updatedJob = job
        updatedJob.removeAttachment(attachment)
        jobStore.updateJob(updatedJob)
    }
}

struct GlassAttachmentRow: View {
    let attachment: Job.Attachment
    let onOpen: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with glass effect
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 48, height: 48)
                
                Image(systemName: attachment.type.icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(attachment.type.color),
                                Color(attachment.type.color).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: Color(attachment.type.color).opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(attachment.type.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(attachment.type.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color(attachment.type.color).opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Text(attachment.dateAdded, style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onOpen) {
                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
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
                                Color(attachment.type.color).opacity(0.05),
                                Color(attachment.type.color).opacity(0.02)
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

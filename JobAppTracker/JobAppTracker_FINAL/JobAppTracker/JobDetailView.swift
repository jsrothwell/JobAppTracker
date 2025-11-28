import SwiftUI

struct JobDetailView: View {
    let job: Job
    @ObservedObject var jobStore: JobStore
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with glass effect
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(job.position)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(job.company)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Button(action: { isEditing = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle.fill")
                            Text("Edit")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
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
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                
                // Status Badge with glass effect
                HStack {
                    ZStack {
                        Capsule()
                            .fill(.ultraThinMaterial)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(job.status.color).opacity(0.4),
                                        Color(job.status.color).opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .overlay(
                        Capsule()
                            .stroke(Color(job.status.color).opacity(0.5), lineWidth: 1.5)
                    )
                    .frame(height: 40)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: job.status.icon)
                            Text(job.status.rawValue)
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    )
                    .shadow(color: Color(job.status.color).opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Details Grid with glass cards
                VStack(spacing: 16) {
                    GlassDetailRow(icon: "calendar", title: "Date Applied", value: job.dateApplied.formatted(date: .long, time: .omitted))
                    
                    if !job.location.isEmpty {
                        GlassDetailRow(icon: "mappin.circle", title: "Location", value: job.location)
                    }
                    
                    if !job.salary.isEmpty {
                        GlassDetailRow(icon: "dollarsign.circle", title: "Salary Range", value: job.salary)
                    }
                    
                    if !job.contactEmail.isEmpty {
                        GlassDetailRow(icon: "envelope.circle", title: "Contact Email", value: job.contactEmail)
                    }
                }
                
                if !job.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Notes")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text(job.notes)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.05))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isEditing) {
            EditJobView(job: job, jobStore: jobStore)
        }
    }
}

struct GlassDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.03),
                                Color.white.opacity(0.01)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

import Foundation
import SwiftUI

class JobStore: ObservableObject {
    @Published var jobs: [Job] = [] {
        didSet {
            saveJobs()
        }
    }
    
    private let jobsKey = "savedJobs"
    
    init() {
        loadJobs()
    }
    
    func addJob(_ job: Job) {
        jobs.append(job)
    }
    
    func updateJob(_ job: Job) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index] = job
        }
    }
    
    func deleteJob(_ job: Job) {
        jobs.removeAll { $0.id == job.id }
    }
    
    func deleteJobs(at offsets: IndexSet) {
        jobs.remove(atOffsets: offsets)
    }
    
    private func saveJobs() {
        if let encoded = try? JSONEncoder().encode(jobs) {
            UserDefaults.standard.set(encoded, forKey: jobsKey)
        }
    }
    
    private func loadJobs() {
        guard let data = UserDefaults.standard.data(forKey: jobsKey) else {
            jobs = []
            return
        }
        
        do {
            jobs = try JSONDecoder().decode([Job].self, from: data)
        } catch {
            print("Failed to decode jobs: \(error)")
            jobs = []
            // Clear corrupted data
            UserDefaults.standard.removeObject(forKey: jobsKey)
        }
    }
}

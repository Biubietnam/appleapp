import Foundation
import SwiftUI
import Combine
struct Medication: Codable, Identifiable {
    let id = UUID()
    let tube: String
    let type: String
    let amount: Int
    let timeToTake: [Schedule]
    
    enum CodingKeys: String, CodingKey {
        case tube, type, amount
        case timeToTake = "time_to_take"
    }
}

struct Schedule: Codable, Identifiable {
    let id = UUID()
    let time: String
    let dosage: String
    
    enum CodingKeys: String, CodingKey {
        case time, dosage
    }
}

public class MedicationManager: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var manualMedications: [Medication] = []
    
    func clearData() {
        medications.removeAll()
        manualMedications.removeAll()
    }
    
    func addManualMedication(_ medication: Medication) {
        // Remove existing medication for same tube
        manualMedications.removeAll { $0.tube == medication.tube }
        manualMedications.append(medication)
        medications = manualMedications
    }
    
    func removeManualMedication(at index: Int) {
        guard index < manualMedications.count else { return }
        manualMedications.remove(at: index)
        medications = manualMedications
    }
}

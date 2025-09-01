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
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var medicationsFileURL: URL {
        documentsDirectory.appendingPathComponent("medications.json")
    }
    
    init() {
        loadMedications()
    }
    
    func clearData() {
        medications.removeAll()
        manualMedications.removeAll()
        saveMedications()
    }
    
    func addManualMedication(_ medication: Medication) {
        // Remove existing medication for same tube
        manualMedications.removeAll { $0.tube == medication.tube }
        manualMedications.append(medication)
        medications = manualMedications
        saveMedications()
    }
    
    func removeManualMedication(at index: Int) {
        guard index < manualMedications.count else { return }
        manualMedications.remove(at: index)
        medications = manualMedications
        saveMedications()
    }
    
    func saveMedications() {
        do {
            let data = try JSONEncoder().encode(manualMedications)
            try data.write(to: medicationsFileURL)
            print("Medications saved successfully")
        } catch {
            print("Failed to save medications: \(error)")
        }
    }
    
    func loadMedications() {
        do {
            let data = try Data(contentsOf: medicationsFileURL)
            manualMedications = try JSONDecoder().decode([Medication].self, from: data)
            medications = manualMedications
            print("Medications loaded successfully: \(manualMedications.count) items")
        } catch {
            print("Failed to load medications: \(error)")
            // Initialize with empty array if file doesn't exist
            manualMedications = []
            medications = []
        }
    }
    
    func addMedicationsFromQRData(_ qrDataLines: [String]) {
        print("💊 [PARSER DEBUG] Starting to parse QR data with \(qrDataLines.count) raw QR codes")
        
        var allLines: [String] = []
        
        for (index, qrData) in qrDataLines.enumerated() {
            print("💊 [PARSER DEBUG] Processing QR code \(index + 1): '\(qrData)'")
            let lines = qrData.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            print("💊 [PARSER DEBUG] QR code \(index + 1) split into \(lines.count) medication lines")
            allLines.append(contentsOf: lines)
        }
        
        print("💊 [PARSER DEBUG] Total medication lines to process: \(allLines.count)")
        
        var newMedications: [Medication] = []
        var tubeCounter = 1
        
        for (index, line) in allLines.enumerated() {
            print("💊 [PARSER DEBUG] Processing medication line \(index + 1): '\(line)'")
            
            if let medication = parseMedicationFromQRLine(line, tubeNumber: tubeCounter) {
                print("💊 [PARSER DEBUG] ✅ Successfully parsed medication: \(medication.type)")
                newMedications.append(medication)
                tubeCounter += 1
            } else {
                print("💊 [PARSER DEBUG] ❌ Failed to parse line \(index + 1)")
            }
        }
        
        print("💊 [PARSER DEBUG] Parsed \(newMedications.count) valid medications out of \(allLines.count) lines")
        
        // Add all parsed medications
        for medication in newMedications {
            addManualMedication(medication)
        }
    }
    
    private	 func parseMedicationFromQRLine(_ line: String, tubeNumber: Int? = nil) -> Medication? {
        print("💊 [PARSER DEBUG] Parsing line: '\(line)'")
        
        // Clean the input line
        let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        print("💊 [PARSER DEBUG] Cleaned line: '\(cleanLine)'")
        
        guard !cleanLine.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ Empty line after cleaning")
            return nil
        }
        
        let components = cleanLine.components(separatedBy: "|")
        print("💊 [PARSER DEBUG] Split into \(components.count) components: \(components)")
        
        // Allow 3 components (Name|Amount|Time) with default dosage, or 4+ component formats
        guard components.count >= 3 else {
            print("💊 [PARSER DEBUG] ❌ Invalid QR format: Must have minimum format Name|Amount|Time or Name|Amount|Time|Dosage, got \(components.count) components")
            print("💊 [PARSER DEBUG] Expected format: Name|Amount|Time1|Dosage1|Time2|Dosage2... (dosage optional)")
            return nil
        }
        
        // Parse name and amount
        let name = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        print("💊 [PARSER DEBUG] Medication name: '\(name)'")
        
        guard !name.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ Invalid QR format: Empty medication name")
            return nil
        }
        
        let amountString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        print("💊 [PARSER DEBUG] Amount string: '\(amountString)'")
        
        guard let amount = Int(amountString) else {
            print("💊 [PARSER DEBUG] ❌ Invalid QR format: Invalid amount '\(amountString)'")
            return nil
        }
        
        print("💊 [PARSER DEBUG] Parsed amount: \(amount)")
        
        var schedules: [Schedule] = []
        
        if components.count == 3 {
            // Format: Name|Amount|Time (dosage defaults to "1 tablet")
            let timeString = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
            print("💊 [PARSER DEBUG] Processing single time with default dosage: '\(timeString)'")
            
            if isValidTimeFormat(timeString) {
                let schedule = Schedule(time: timeString, dosage: "1 tablet")
                schedules.append(schedule)
                print("💊 [PARSER DEBUG] ✅ Added schedule with default dosage: \(timeString) - 1 tablet")
            } else {
                print("💊 [PARSER DEBUG] ❌ Invalid time format: '\(timeString)'")
                return nil
            }
        } else {
            // Format: Name|Amount|Time1|Dosage1|Time2|Dosage2...
            let timeDosagePairs = components.count - 2
            print("💊 [PARSER DEBUG] Time/dosage components count: \(timeDosagePairs)")
            
            guard timeDosagePairs % 2 == 0 else {
                print("💊 [PARSER DEBUG] ❌ Invalid QR format: Time/Dosage pairs must be complete (even number after Name|Amount)")
                print("💊 [PARSER DEBUG] Got \(timeDosagePairs) time/dosage components, need even number")
                return nil
            }
            
            // Parse time/dosage pairs starting from index 2
            var index = 2
            while index + 1 < components.count {
                let timeString = components[index].trimmingCharacters(in: .whitespacesAndNewlines)
                let dosageString = components[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("💊 [PARSER DEBUG] Processing time/dosage pair: '\(timeString)'/'\(dosageString)'")
                
                // Validate time format (should be HH:MM)
                if isValidTimeFormat(timeString) && !dosageString.isEmpty {
                    let schedule = Schedule(time: timeString, dosage: dosageString)
                    schedules.append(schedule)
                    print("💊 [PARSER DEBUG] ✅ Added schedule: \(timeString) - \(dosageString)")
                } else {
                    print("💊 [PARSER DEBUG] ❌ Invalid time/dosage pair: '\(timeString)'/'\(dosageString)'")
                    print("💊 [PARSER DEBUG] Time format valid: \(isValidTimeFormat(timeString)), Dosage not empty: \(!dosageString.isEmpty)")
                    return nil
                }
                
                index += 2
            }
        }
        
        guard !schedules.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ Invalid QR format: No valid time/dosage pairs found")
            return nil
        }
        
        // Generate tube identifier
        let tubeId = tubeNumber ?? schedules.count
        print("💊 [PARSER DEBUG] Assigned tube ID: \(tubeId)")
        
        let medication = Medication(
            tube: "Tube \(tubeId)",
            type: name,
            amount: amount,
            timeToTake: schedules
        )
        
        print("💊 [PARSER DEBUG] ✅ Successfully created medication: \(medication.type) with \(schedules.count) schedules")
        
        return medication
    }
    
    private func isValidTimeFormat(_ timeString: String) -> Bool {
        let timePattern = "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$"
        let regex = try? NSRegularExpression(pattern: timePattern)
        let range = NSRange(location: 0, length: timeString.utf16.count)
        return regex?.firstMatch(in: timeString, options: [], range: range) != nil
    }
    
    public func validateQRData(_ qrDataLines: [String]) -> (valid: [String], invalid: [String]) {
        var validLines: [String] = []
        var invalidLines: [String] = []
        
        for line in qrDataLines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if parseMedicationFromQRLine(cleanLine) != nil {
                validLines.append(cleanLine)
            } else {
                invalidLines.append(cleanLine)
            }
        }
        
        return (valid: validLines, invalid: invalidLines)
    }
    
    public func getQRParsingStats(_ qrDataLines: [String]) -> (totalLines: Int, validMedications: Int, invalidLines: Int) {
        let validation = validateQRData(qrDataLines)
        return (
            totalLines: qrDataLines.count,
            validMedications: validation.valid.count,
            invalidLines: validation.invalid.count
        )
    }
}

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
    
    private func parseMedicationFromQRLine(_ line: String, tubeNumber: Int? = nil) -> Medication? {
        print("💊 [PARSER DEBUG] Parsing line: '\(line)'")

        // Normalize + trim
        var tokens = line
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "|", omittingEmptySubsequences: false) // keep empties so we can handle trailing '|'
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        // Drop trailing empties (e.g., "...|")
        while let last = tokens.last, last.isEmpty { tokens.removeLast() }

        print("💊 [PARSER DEBUG] Split into \(tokens.count) components: \(tokens)")

        // Require minimum: Name|Amount|time1|dosage1
        guard tokens.count >= 4 else {
            print("💊 [PARSER DEBUG] ❌ Invalid: need Name|Amount|time1|dosage1 (got \(tokens.count))")
            return nil
        }

        // Name + amount
        let name = tokens[0]
        guard !name.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ Empty medication name")
            return nil
        }

        guard let amount = Int(tokens[1]) else {
            print("💊 [PARSER DEBUG] ❌ Amount must be integer: '\(tokens[1])'")
            return nil
        }

        // time1 + dosage1 required
        let time1 = tokens[2]
        let dosage1 = tokens[3]
        guard isValidTimeFormat(time1), !dosage1.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ Invalid first pair time/dosage: '\(time1)'/'\(dosage1)'")
            return nil
        }

        var schedules: [Schedule] = [Schedule(time: time1, dosage: dosage1)]

        // Subsequent: timeN required, dosageN optional (defaults to dosage1)
        var i = 4
        while i < tokens.count {
            let t = tokens[i]
            if !isValidTimeFormat(t) {
                print("💊 [PARSER DEBUG] ❌ Expected time at position \(i): '\(t)'")
                return nil
            }

            var d = dosage1
            if i + 1 < tokens.count, !tokens[i + 1].isEmpty {
                d = tokens[i + 1]
                i += 2
            } else {
                // no dosage provided -> use dosage1
                i += 1
            }

            schedules.append(Schedule(time: t, dosage: d))
            print("💊 [PARSER DEBUG] ✅ Added schedule: \(t) - \(d)")
        }

        guard !schedules.isEmpty else {
            print("💊 [PARSER DEBUG] ❌ No schedules parsed")
            return nil
        }

        let tubeId = tubeNumber ?? schedules.count
        let medication = Medication(
            tube: "Tube \(tubeId)",
            type: name,
            amount: amount,
            timeToTake: schedules
        )
        print("💊 [PARSER DEBUG] ✅ Medication \(name) with \(schedules.count) schedules")
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

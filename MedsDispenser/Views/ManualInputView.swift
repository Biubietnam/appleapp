import SwiftUI
import Combine
struct ManualInputView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var selectedTube = "tube1"
    @State private var medicationType = ""
    @State private var amount = ""
    @State private var schedules: [Schedule] = []
    @State private var newScheduleTime = ""
    @State private var newScheduleDosage = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let tubes = ["tube1", "tube2", "tube3", "tube4", "tube5", "tube6"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Medication Details
            medicationDetailsSection
            
            // Schedule Section
            scheduleSection
            
            // Controls
            controlsSection
            
            // Manual Medications List
            medicationsListSection
        }
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var medicationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("💊 Medication Details")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                Text("🏺 Tube:")
                    .frame(width: 80, alignment: .leading)
                Picker("Tube", selection: $selectedTube) {
                    ForEach(tubes, id: \.self) { tube in
                        Text(tube).tag(tube)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
            }
            
            HStack {
                Text("💊 Type:")
                    .frame(width: 80, alignment: .leading)
                TextField("Medication name", text: $medicationType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                Text("📦 Amount:")
                    .frame(width: 80, alignment: .leading)
                TextField("0", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                Text("tablets")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("⏰ Dosage Schedule")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // Add Schedule
            HStack {
                TextField("HH:MM", text: $newScheduleTime)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                
                TextField("1 tablet", text: $newScheduleDosage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("➕") {
                    addSchedule()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            // Schedule List
            if !schedules.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                        HStack {
                            Text("🕐 \(schedule.time)")
                                .font(.caption)
                            Text("💊 \(schedule.dosage)")
                                .font(.caption)
                            Spacer()
                            Button("🗑️") {
                                schedules.remove(at: index)
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
    
    private var controlsSection: some View {
        HStack {
            Button("💾 Save Medication") {
                saveMedication()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            Button("🧹 Clear Form") {
                clearForm()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var medicationsListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📋 Added Medications")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if medicationManager.manualMedications.isEmpty {
                Text("No medications added yet")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding()
            } else {
                ForEach(Array(medicationManager.manualMedications.enumerated()), id: \.element.id) { index, medication in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("🏺 \(medication.tube)")
                                .fontWeight(.semibold)
                            Text("💊 \(medication.type)")
                            Spacer()
                            Text("📦 \(medication.amount) tablets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button("🗑️") {
                                medicationManager.removeManualMedication(at: index)
                            }
                            .foregroundColor(.red)
                        }
                        
                        Text("⏰ " + medication.timeToTake.map { "\($0.time) (\($0.dosage))" }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
    
    private func addSchedule() {
        guard !newScheduleTime.isEmpty && !newScheduleDosage.isEmpty else {
            showAlert("Please enter both time and dosage")
            return
        }
        
        // Validate time format
        let timeComponents = newScheduleTime.split(separator: ":")
        guard timeComponents.count == 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]),
              hour >= 0 && hour <= 23,
              minute >= 0 && minute <= 59 else {
            showAlert("Please enter time in HH:MM format (24-hour)")
            return
        }
        
        let schedule = Schedule(time: newScheduleTime, dosage: newScheduleDosage)
        schedules.append(schedule)
        
        newScheduleTime = ""
        newScheduleDosage = ""
    }
    
    private func saveMedication() {
        guard !medicationType.isEmpty && !amount.isEmpty else {
            showAlert("Please fill in all medication details")
            return
        }
        
        guard !schedules.isEmpty else {
            showAlert("Please add at least one dosage schedule")
            return
        }
        
        guard let amountInt = Int(amount), amountInt > 0 else {
            showAlert("Please enter a valid positive number for amount")
            return
        }
        
        let medication = Medication(
            tube: selectedTube,
            type: medicationType,
            amount: amountInt,
            timeToTake: schedules
        )
        
        medicationManager.addManualMedication(medication)
        clearForm()
    }
    
    private func clearForm() {
        selectedTube = "tube1"
        medicationType = ""
        amount = ""
        schedules.removeAll()
        newScheduleTime = ""
        newScheduleDosage = ""
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

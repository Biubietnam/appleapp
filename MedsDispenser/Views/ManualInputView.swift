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
        VStack(spacing: 20) {
            // Medication Details Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "pills.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Medication Details")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 12) {
                    // Tube Selection
                    HStack(spacing: 12) {
                        Image(systemName: "testtube.2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Tube:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 60, alignment: .leading)
                        
                        Picker("Tube", selection: $selectedTube) {
                            ForEach(tubes, id: \.self) { tube in
                                HStack {
                                    Image(systemName: "testtube.2")
                                    Text(tube.capitalized)
                                }.tag(tube)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Medication Type
                    HStack(spacing: 12) {
                        Image(systemName: "cross.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Type:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 60, alignment: .leading)
                        
                        TextField("Enter medication name", text: $medicationType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Amount
                    HStack(spacing: 12) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Amount:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 60, alignment: .leading)
                        
                        TextField("0", text: $amount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                        
                        Text("tablets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Schedule Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Dosage Schedule")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                // Add Schedule Input
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        TextField("HH:MM", text: $newScheduleTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        TextField("Enter dosage (e.g., 1 tablet)", text: $newScheduleDosage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                        
                        Button(action: addSchedule) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Schedule List
                    if !schedules.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                                HStack(spacing: 12) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                        .frame(width: 16)
                                    
                                    Text(schedule.time)
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Image(systemName: "pills")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                        .frame(width: 16)
                                    
                                    Text(schedule.dosage)
                                        .font(.system(size: 14))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button(action: {
                                        schedules.remove(at: index)
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: saveMedication) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Medication")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: clearForm) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Clear Form")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
            
            // Medications List Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "list.clipboard.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Added Medications")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if medicationManager.manualMedications.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        Text("No medications added yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(medicationManager.manualMedications.enumerated()), id: \.element.id) { index, medication in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "testtube.2")
                                        .foregroundColor(.purple)
                                    Text(medication.tube.capitalized)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "cross.circle")
                                        .foregroundColor(.red)
                                    Text(medication.type)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "number.circle")
                                        .foregroundColor(.green)
                                    Text("\(medication.amount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        medicationManager.removeManualMedication(at: index)
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text(medication.timeToTake.map { "\($0.time) (\($0.dosage))" }.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
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

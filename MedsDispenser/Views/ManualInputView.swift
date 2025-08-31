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
    @State private var showingDosageChart = false
    
    let tubes = ["tube1", "tube2", "tube3", "tube4", "tube5", "tube6"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Medication Details Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "pills.fill")
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
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Tube:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 60, alignment: .leading)
                        
                        Picker("Tube", selection: $selectedTube) {
                            ForEach(tubes, id: \.self) { tube in
                                HStack {
                                    Image(systemName: "testtube.2")
                                        .foregroundColor(.green)
                                    Text(tube.capitalized)
                                }.tag(tube)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Medication Type
                    HStack(spacing: 12) {
                        Image(systemName: "cross.fill")
                            .font(.system(size: 16))
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
                        Image(systemName: "number")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Amount:")
                            .font(.system(size: 11))
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
            
            // Schedule Card with Pie Chart
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("Dosage Schedule")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingDosageChart.toggle()
                    }) {
                        Image(systemName: "chart.pie.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                if showingDosageChart {
                    DosageTimeChart(
                        onTimeSelected: { time in
                            newScheduleTime = time
                            showingDosageChart = false
                        },
                        onManualInput: {
                            showingDosageChart = false
                        },
                        showingDosageChart: $showingDosageChart
                    )
                    .transition(.opacity.combined(with: .scale))
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
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Schedule List
                    if !schedules.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                                HStack(spacing: 12) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
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
                                        Image(systemName: "trash.fill")
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
            
            HStack(spacing: 12) {
                Button(action: saveMedication) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Save Medication")
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: clearForm) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.primary)
                        Text("Clear Form")
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
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
                        Image(systemName: "shippingbox")
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
                                        .foregroundColor(.green)
                                    Text(medication.tube.capitalized)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "cross.fill")
                                        .foregroundColor(.red)
                                    Text(medication.type)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "number")
                                        .foregroundColor(.orange)
                                    Text("\(medication.amount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        medicationManager.removeManualMedication(at: index)
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.blue)
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
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingDosageChart)
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

struct DosageTimeChart: View {
    let onTimeSelected: (String) -> Void
    let onManualInput: () -> Void
    @Binding var showingDosageChart: Bool
    
    let timeSlots = [
        ("Morning", "08:00", Color.orange),
        ("Afternoon", "12:00", Color.blue),
        ("Evening", "15:00", Color.green),
        ("Night", "21:00", Color.purple)
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onManualInput()
                }
            
            VStack(spacing: 24) {
                Text("Select Dosage Time")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Beautiful large pie chart
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 280, height: 280)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    
                    // Pie segments
                    ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, slot in
                        Button(action: {
                            onTimeSelected(slot.1)
                        }) {
                            PieSlice(
                                startAngle: .degrees(Double(index) * 90 - 45),
                                endAngle: .degrees(Double(index + 1) * 90 - 45),
                                color: slot.2
                            )
                            .frame(width: 260, height: 260)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: getTimeIcon(for: slot.0))
                                        .font(.title)
                                        .foregroundColor(.white)
                                    Text(slot.0)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text(slot.1)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .offset(
                                    x: cos((Double(index) * 90) * .pi / 180) * 80,
                                    y: sin((Double(index) * 90) * .pi / 180) * 80
                                )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Center circle
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .overlay(
                            Image(systemName: "clock.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        )
                }
                
                Button(action: onManualInput) {
                    HStack(spacing: 8) {
                        Image(systemName: "keyboard")
                            .foregroundColor(.white)
                        Text("Manual Time Input")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                    }
                    .frame(width: 210, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
            .scaleEffect(showingDosageChart ? 1.0 : 0.8)
            .opacity(showingDosageChart ? 1.0 : 0.0)
        }
    }
    
    private func getTimeIcon(for period: String) -> String {
        switch period {
        case "Morning": return "sunrise.fill"
        case "Afternoon": return "sun.max.fill"
        case "Evening": return "sunset.fill"
        case "Night": return "moon.fill"
        default: return "clock.fill"
        }
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
            .overlay(
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius = min(geometry.size.width, geometry.size.height) / 2
                    
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .stroke(Color.white, lineWidth: 2)
            )
        }
    }
}
	

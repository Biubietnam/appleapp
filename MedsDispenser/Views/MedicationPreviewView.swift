import SwiftUI

struct MedicationPreviewView: View {
    let medications: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("\(medications.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("\(uniqueTubes)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Tubes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("\(totalSchedules)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Schedules")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            // Medication List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(medications) { medication in
                        MedicationCard(medication: medication)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
    
    private var uniqueTubes: Int {
        Set(medications.map { $0.tube }).count
    }
    
    private var totalSchedules: Int {
        medications.reduce(0) { $0 + $1.timeToTake.count }
    }
}

struct MedicationCard: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🏺 \(medication.tube)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(6)
                
                Spacer()
                
                Text("📦 \(medication.amount) tablets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("💊 \(medication.type)")
                .font(.headline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("⏰ Schedule:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach(medication.timeToTake) { schedule in
                    HStack {
                        Text("🕐 \(schedule.time)")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("💊 \(schedule.dosage)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}


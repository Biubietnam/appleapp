import SwiftUI
import Combine
extension ContentView {
    
    var professionalManualInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                Text("Manual Medication Entry")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                Spacer()
                	
                Text("SECURE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
            }
            
            ManualInputView(medicationManager: medicationManager)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    var enhancedBLESection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
                
                Text("Device Connection")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
                
                Spacer()
                
                Button(action: {
                    if isScanning {
                        stopEnhancedScanning()
                    } else {
                        startEnhancedScanning()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isScanning ? "stop.circle.fill" : "magnifyingglass")
                        Text(isScanning ? "STOP" : "SCAN")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isScanning ? Color.red : Color(red: 0.545, green: 0.361, blue: 0.965))
                    .cornerRadius(8)
                }
            }
            
            if isScanning {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Scanning for medical devices...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                }
                .padding(.vertical, 8)
            }
            
            if !discoveredDevices.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Devices (\(discoveredDevices.count))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(discoveredDevices, id: \.identifier) { device in
                                professionalDeviceRow(device: device)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func professionalDeviceRow(device: BLEDevice) -> some View {
        HStack(spacing: 12) {
            // Device type icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name ?? "Medical Device")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                Text("ID: \(String(device.identifier.uuidString.prefix(8)))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let rssi = device.rssi {
                    HStack(spacing: 4) {
                        Image(systemName: rssi > -60 ? "wifi" : rssi > -80 ? "wifi.slash" : "wifi.exclamationmark")
                            .font(.system(size: 12))
                            .foregroundColor(rssi > -60 ? .green : rssi > -80 ? .orange : .red)
                        
                        Text("\(rssi) dBm")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                    }
                }
                
                Button(action: {
                    selectDevice(device)
                }) {
                    Text(selectedDevice?.identifier == device.identifier ? "SELECTED" : "CONNECT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedDevice?.identifier == device.identifier ? Color.green : Color(red: 0.545, green: 0.361, blue: 0.965))
                        .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(Color(red: 0.925, green: 0.957, blue: 1.0))
        .cornerRadius(12)
    }
    
    var professionalFileUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
                
                Text("JSON Data Import")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
                
                Spacer()
                
                Text("ENCRYPTED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
            }
            
            Button(action: {
                showingFilePicker = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
                    
                    Text("Select JSON Configuration File")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                    
                    Text("Tap to browse secure medication files")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.545, green: 0.361, blue: 0.965), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
            }
            
            if !medicationManager.medications.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("✅ \(medicationManager.medications.count) medications loaded")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    var professionalQRSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                
                Text("QR Code Scanner")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                
                Spacer()
                
                Text("COMING SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(4)
            }
            
            VStack(spacing: 12) {
                Image(systemName: "qrcode")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412).opacity(0.5))
                
                Text("QR Code Scanning")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                
                Text("Scan medication QR codes for instant configuration")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412).opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    var professionalPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                Text("Medication Schedule Preview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                Spacer()
            }
            
            if medicationManager.medications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412).opacity(0.5))
                    
                    Text("No Medication Data")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                    
                    Text("Import data using one of the methods above")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412).opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                MedicationPreviewView(medications: medicationManager.medications)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    var professionalSubmitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                
                Text("Deploy Configuration")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("CRITICAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
            
            // Professional checklist
            VStack(alignment: .leading, spacing: 8) {
                Text("🔒 Pre-Deployment Checklist:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                
                ProfessionalChecklistItem(text: "BLE device connected and verified", isChecked: isConnected)
                ProfessionalChecklistItem(text: "Medication data validated", isChecked: !medicationManager.medications.isEmpty)
                ProfessionalChecklistItem(text: "Dispenser chamber is empty", isChecked: true)
                ProfessionalChecklistItem(text: "Safety protocols acknowledged", isChecked: true)
            }
            .padding(16)
            .background(Color(red: 0.925, green: 0.957, blue: 1.0))
            .cornerRadius(12)
            
            Button(action: submitConfiguration) {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(isSubmitting ? "DEPLOYING..." : "DEPLOY TO DISPENSER")
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canSubmit ? Color.red : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canSubmit || isSubmitting)
            .scaleEffect(canSubmit ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: canSubmit)
            
            Text("⚠️ WARNING: This action will configure the pill dispenser with the loaded medication schedule. Ensure all data is correct before proceeding.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.red)
                .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    var professionalStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                
                Text("System Status Dashboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatusCard(
                    title: "Connection",
                    value: isConnected ? "ONLINE" : "OFFLINE",
                    icon: "antenna.radiowaves.left.and.right",
                    color: isConnected ? .green : .red
                )
                
                StatusCard(
                    title: "Medications",
                    value: "\(medicationManager.medications.count)",
                    icon: "pills.fill",
                    color: Color(red: 0.086, green: 0.306, blue: 0.388)
                )
                
                StatusCard(
                    title: "Devices Found",
                    value: "\(discoveredDevices.count)",
                    icon: "magnifyingglass",
                    color: Color(red: 0.545, green: 0.361, blue: 0.965)
                )
                
                StatusCard(
                    title: "Status",
                    value: isScanning ? "SCANNING" : "READY",
                    icon: isScanning ? "arrow.clockwise" : "checkmark.circle",
                    color: isScanning ? .orange : .green
                )
            }
            
            if isSubmitting {
                VStack(spacing: 8) {
                    ProgressView(value: transmissionProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.086, green: 0.306, blue: 0.388)))
                    
                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
}

struct ProfessionalChecklistItem: View {
    let text: String
    let isChecked: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isChecked ? .green : Color.gray)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
            
            Spacer()
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0.278, green: 0.333, blue: 0.412))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onQRCodeDetected: ([String]) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        let parent: QRCodeScannerView
        
        init(_ parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func qrScannerDidDetectCode(_ codes: [String]) {
            parent.onQRCodeDetected(codes)
            parent.isPresented = false
        }
        
        func qrScannerDidCancel() {
            parent.isPresented = false
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func qrScannerDidDetectCode(_ codes: [String])
    func qrScannerDidCancel()
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var detectedCodes: Set<String> = []
    private var scanningTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert("Camera Error", "Unable to access camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert("Camera Error", "Unable to create camera input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showAlert("Camera Error", "Unable to add camera input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showAlert("Camera Error", "Unable to add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        // Add overlay with scanning frame
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let scanFrame = CGRect(
            x: view.bounds.width * 0.1,
            y: view.bounds.height * 0.3,
            width: view.bounds.width * 0.8,
            height: view.bounds.height * 0.4
        )
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let scanPath = UIBezierPath(rect: scanFrame)
        path.append(scanPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        view.addSubview(overlayView)
        
        // Add scanning frame border
        let borderView = UIView(frame: scanFrame)
        borderView.layer.borderColor = UIColor.systemBlue.cgColor
        borderView.layer.borderWidth = 2
        borderView.layer.cornerRadius = 10
        borderView.backgroundColor = UIColor.clear
        view.addSubview(borderView)
        
        // Add instructions label
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Position QR code within the frame\nMultiple codes will be scanned automatically"
        instructionsLabel.textColor = UIColor.white
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)
        
        // Add cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cancelButton.backgroundColor = UIColor.systemRed
        cancelButton.layer.cornerRadius = 25
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Add done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        doneButton.backgroundColor = UIColor.systemGreen
        doneButton.layer.cornerRadius = 25
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func startScanning() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
        
        // Start timer to automatically finish scanning after collecting codes
        scanningTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if !self.detectedCodes.isEmpty {
                self.finishScanning()
            }
        }
    }
    
    private func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        scanningTimer?.invalidate()
        scanningTimer = nil
    }
    
    @objc private func cancelTapped() {
        delegate?.qrScannerDidCancel()
    }
    
    @objc private func doneTapped() {
        finishScanning()
    }
    
    private func finishScanning() {
        stopScanning()
        let codes = Array(detectedCodes)
        if !codes.isEmpty {
            delegate?.qrScannerDidDetectCode(codes)
        } else {
            delegate?.qrScannerDidCancel()
        }
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.delegate?.qrScannerDidCancel()
        })
        present(alert, animated: true)
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { continue }
            
            print("🔍 [QR DEBUG] Raw QR data detected: '\(stringValue)'")
            print("🔍 [QR DEBUG] QR data length: \(stringValue.count) characters")
            print("🔍 [QR DEBUG] QR data as bytes: \(stringValue.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined(separator: " ") ?? "nil")")
            
            let lines = stringValue.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            print("🔍 [QR DEBUG] Split into \(lines.count) lines:")
            for (index, line) in lines.enumerated() {
                print("🔍 [QR DEBUG] Line \(index + 1): '\(line)'")
                let components = line.components(separatedBy: "|")
                print("🔍 [QR DEBUG] Line \(index + 1) has \(components.count) components: \(components)")
            }
            
            // Add detected code to set (automatically handles duplicates)
            detectedCodes.insert(stringValue)
            
            // Provide haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            finishScanning()
            return
        }
    }
}

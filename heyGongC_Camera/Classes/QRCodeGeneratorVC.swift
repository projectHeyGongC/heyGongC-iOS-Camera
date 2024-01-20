//
//  QRCodeGeneratorVC.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SwiftyUserDefaults
import AVFoundation
import CoreImage.CIFilterBuiltins

class QRCodeGeneratorVC: UIViewController {
    
    @IBOutlet weak var imgViewQRCode: UIImageView!
    
    
    let session = AVCaptureSession()
    let output: AVCaptureOutput = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.landscapeRight.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
        
        checkCameraPermission()
        
        view.layer.addSublayer(previewLayer)
        imgViewQRCode.image = generatorQRCode()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
     override var shouldAutorotate: Bool {
            return true
    }
    
    private func generatorQRCode() -> UIImage?{
        let qrData = "https://github.com/Yeji-Jang1210"
        filter.setValue(qrData.data(using: .utf8), forKey: "inputMessage")
        
        guard let qrCodeImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 5, y: 5)
        let scaledCIImage = qrCodeImage.transformed(by: transform)
        
        guard let qrCodeCGImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        return UIImage(cgImage: qrCodeCGImage)
        
    }
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case.notDetermined:
            print("notDetermined")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async{
                    self?.setupCamera()
                }
            }
        case.denied:
            print("denied")
            break
        case .restricted:
            print("restricted")
            break
        case .authorized:
            print("authorized")
            setupCamera()
        @unknown default:
            break
        }
    }
    
    private func setupCamera(){
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                let output = AVCaptureMetadataOutput()
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                print("session start")
                session.startRunning()
            } catch {
                print("error")
            }
        }
        
        
        
    }
}


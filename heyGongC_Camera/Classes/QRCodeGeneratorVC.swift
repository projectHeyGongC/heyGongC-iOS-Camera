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
import RxCocoa
import SwiftyUserDefaults
import AVFoundation
import CoreImage.CIFilterBuiltins

class QRCodeGeneratorVC: UIViewController {
    
    @IBOutlet weak var viewQRCode: UIView!
    @IBOutlet weak var imgViewQRCode: UIImageView!
    
    // MARK: - properties
    private var viewModel = QRCodeGeneratorVM()
    
    private let session = AVCaptureSession()
    private let output: AVCaptureOutput = AVCaptureVideoDataOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    // 소리감지 프로퍼티
    private var recorder: AVAudioRecorder!
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private var isTappedViewQRCode: Bool = false
    
    // MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lockOrientation(.landscape)
        view.layer.addSublayer(previewLayer)
        checkCameraPermission()
        bindAction()
        
        let tapGesture = UITapGestureRecognizer()
        viewQRCode.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapView))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .background).async{
            self.session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session.stopRunning()
    }
    
    private func bindAction(){
        viewModel.successAddDevice
            .bind {
                //self.viewQRCode.isHidden = $0
                self.viewModel.recordingSubject.onNext($0)
            }
            .disposed(by: viewModel.bag)
    }
    
    @objc func didTapView(){
        isTappedViewQRCode.toggle()
        print("isTappedViewQRCode:\(isTappedViewQRCode)")
        viewModel.successAddDevice.accept(isTappedViewQRCode)
    }
    
    private func generatorQRCodeImage() -> UIImage?{
        
        filter.setValue(viewModel.generateQRCodeData(), forKey: "inputMessage")
        guard let qrCodeImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 5, y: 5)
        let scaledCIImage = qrCodeImage.transformed(by: transform)
        
        guard let qrCodeCGImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        return UIImage(cgImage: qrCodeCGImage)
        
    }
    
    // MARK: - Camera Setting Methods
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
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                previewLayer.connection?.videoOrientation = .landscapeRight
                
                print("session start")
                
                DispatchQueue.global(qos: .background).async{
                    self.session.startRunning()
                }
                
                imgViewQRCode.image = generatorQRCodeImage()
                view.bringSubviewToFront(viewQRCode)
                
            } catch {
                print("error")
            }
        }
    }
}

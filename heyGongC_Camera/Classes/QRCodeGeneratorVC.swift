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
    
    
    // MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lockOrientation(.landscape)
        view.layer.addSublayer(previewLayer)
        checkCameraPermission()
        bindAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){ [weak self] in
            guard let self else { return }
            viewModel.successAddDevice.accept(true)
        }
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
                self.viewQRCode.isHidden = $0
                
                //오디오 감지 시작? 만약에 오디오 권한이 꺼져있다면 recorder도 비활성화 시켜야함?
                self.viewModel.recorder.startRecording()
            }
            .disposed(by: viewModel.bag)
        
        viewModel.soundDataRelay
            .subscribe(onNext: { soundValues in
                    // soundValues 배열에 있는 값 중 400을 초과하는 값이 있는지 확인하고 출력
                    if soundValues.contains(where: { $0 > 400 }) {
                        print("소리 감지")
                    }
                })
            .disposed(by: viewModel.bag)
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


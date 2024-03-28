//
//  CameraVM.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import UIKit
import AVFoundation

class CameraVM {
    
    private var timer: Timer?
    private var soundData: [Double] = []
    private var recorder: SoundAnalyzer!
    private var camera: Camera!
    private let context = CIContext()
    
    var bag = DisposeBag()
    var errorHandler = BehaviorRelay<GCError?>(value: nil)
    
    var successPaired = PublishRelay<Bool>()
    var successGenerateQRImage = PublishSubject<UIImage?>()
    var hiddenQRCode = PublishRelay<Bool>()
    var showAlert: Signal<Void>?
    var soundDataRelay = PublishRelay<Double>()
    var recordingSubject = PublishSubject<Bool>()
    
    init(){
        self.camera = Camera()
        self.recorder = SoundAnalyzer()
        
        bind()
    }
    
    deinit {
        bag = DisposeBag()
    }
    
    private func bind(){
        successPaired
            .bind { [weak self] in
                guard let self else { return }
                
                if $0 {
                    hiddenQRCode.accept($0)
                } else {
                    getQRImage()
                }
                
                //self.viewModel.recordingSubject.onNext($0)
            }
            .disposed(by: bag)
        
        recordingSubject
            .bind { [weak self] in
                guard let self else { return }
                if $0 {
                    startRecordingCycle()
                } else {
                    stopRecordingCycle()
                }
            }
            .disposed(by: bag)
        
        //큰 소리만 소리 데이터에 추가
        soundDataRelay
            .filter{ $0 > 0.003 }
            .subscribe{ [weak self] sound in
                guard let self else { return }
                
                print("🔊 큰 소리 감지: \(String(format: "%.2f", sound))")
                
                soundData.append(sound)
                
            }
            .disposed(by: bag)
        
        recorder.onRecordingProcessed = { averageTopTenPercent in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                print("Processed Value: \(averageTopTenPercent)") // Diagnostic log
                soundDataRelay.accept(averageTopTenPercent)
            }
        }
    }
    
    public func checkDevicePaired(){
        CameraAPI.shared.networking(cameraService: .inquireStatus, type: CameraPairedResponse.self)
            .subscribe(with: self, onSuccess: { owner, networkResult in
                switch networkResult {
                case .success(let response):
                    guard let result = response?.isPaired else {
                        self.errorHandler.accept(GCError.errorDecoding)
                        return
                    }
                    self.successPaired.accept(result)
                case .error(let error):
                    self.errorHandler.accept(error)
                }
            }, onFailure: { owner, error in
                print(" checkDevicePaired - error")
            })
            .disposed(by: bag)
    }
    
    public func getQRImage(){
        
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(generateQRCodeData(), forKey: "inputMessage")

        guard let qrCodeImage = filter.outputImage else {
            successGenerateQRImage.onNext(nil)
            return
        }
        
        let transform = CGAffineTransform(scaleX: 5, y: 5)
        let scaledCIImage = qrCodeImage.transformed(by: transform)
        
        guard let qrCodeCGImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else {
            successGenerateQRImage.onNext(nil)
            return
        }
        
        successGenerateQRImage.onNext(UIImage(cgImage: qrCodeCGImage))
        
    }
    
    private func generateQRCodeData()-> Data? {
        // qr데이터 형식 : "HeygongC_${deviceId}"
        /// jyj 20240320 메인 앱 qr 유효성검사  방법 수정 필요
        let qrStr = "HeyGongC_\(Util.shared.uuid)"
        print("qrStr: \(qrStr)")
        guard let qrData = qrStr.data(using: .utf8) else { return nil }
        
        return qrData
    }
}

//소리 감지 관련
extension CameraVM {
    
    private func startRecordingCycle() {
        startRecording()
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
            self?.startRecording()
        }
    }
    
    private func startRecording() {
        recorder.startRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.recorder.stopRecording()
        }
    }
    
    private func stopRecordingCycle() {
        timer?.invalidate()
        timer = nil
        recorder.stopRecording()
    }
}

//카메라 관련
extension CameraVM {
    
    public var cameraLayer: AVCaptureVideoPreviewLayer {
        return camera.cameraLayer
    }
    
    public func startCamera(){
        camera.start()
    }
    
    public func stopCamera(){
        camera.stop()
    }
    
    public func setCameraFrame(frame: CGRect){
        camera.setCameraFrame(frame: frame)
    }
}

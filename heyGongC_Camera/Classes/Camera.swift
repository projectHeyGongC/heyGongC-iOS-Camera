//
//  Camera.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/14/24.
//

import Foundation
import AVFoundation
import RxSwift

class Camera {
    private let session = AVCaptureSession()
    private let output: AVCaptureOutput = AVCaptureVideoDataOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    var cameraLayer: AVCaptureVideoPreviewLayer {
        return previewLayer
    }
    
    init(){
        checkCameraPermission()
    }
    
    // MARK: - Camera Setting Methods
    func setCameraFrame(frame: CGRect){
        previewLayer.frame = frame
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
            } catch {
                print("error")
            }
        }
    }
    
    public func start(){
        self.session.startRunning()
    }
    
    public func stop(){
        session.stopRunning()
    }
    
}

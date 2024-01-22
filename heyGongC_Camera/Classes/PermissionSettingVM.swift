//
//  PermissionSettingVM.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

class PermissionSettingVM {
    
    private let disposeBag = DisposeBag()
    
    let cameraPermissionRelay = BehaviorRelay<Bool>(value: false)
    let audioPermissionRelay = BehaviorRelay<Bool>(value: false)
    
    init(){
        checkCameraPermission()
        checkAudioPermission()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                self.cameraPermissionRelay.accept(granted)
            }
        case .denied, .restricted:
            cameraPermissionRelay.accept(false)
        case .authorized:
            cameraPermissionRelay.accept(true)
        @unknown default:
            break
        }
    }
    
    func checkAudioPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                guard let self = self else { return }
                self.audioPermissionRelay.accept(granted)
            }
        case .denied, .restricted:
            audioPermissionRelay.accept(false)
        case .authorized:
            audioPermissionRelay.accept(true)
        @unknown default:
            break
        }
    }
}

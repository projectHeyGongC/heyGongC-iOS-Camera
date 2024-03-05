//
//  InitialSettingViewModel.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/5/24.
//

import Foundation
import RxSwift
import RxRelay
import SwiftyUserDefaults
import AVFoundation

class InitialSettingViewModel {
    
    let bag = DisposeBag()
    private var errorHandler = BehaviorRelay<GCError?>(value: nil)
    let isValidAccessTokenRelay = PublishRelay<Bool>()
    let checkAllPermsiionsRelay = PublishRelay<Bool>()
    
    init(){
        isValidAccessToken()
    }
    
    func checkAllPermissions(){
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            checkAllPermsiionsRelay.accept(true)
        } else {
            checkAllPermsiionsRelay.accept(false)
        }
        
    }
    
    func isValidAccessToken(){
        DeviceAPI.shared.networking()
            .subscribe(with: self, onSuccess: { owner, networkResult in
                switch networkResult {
                case .success(let data):
                    guard let data = data else {
                        self.isValidAccessTokenRelay.accept(false)
                        return
                    }
                    Defaults.ACCESS_TOKEN = data
                    print("isValidAccessToken is True")
                    self.isValidAccessTokenRelay.accept(true)
                case .error(let error):
                    self.errorHandler.accept(error)
                }
            }, onFailure: { owner, error in
                print("isValidAccessToken - error")
            })
            .disposed(by: bag)
    }
}

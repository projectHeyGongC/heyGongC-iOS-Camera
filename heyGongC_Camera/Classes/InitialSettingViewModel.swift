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
    var errorHandler = BehaviorRelay<GCError?>(value: nil)
    let isValidAccessTokenRelay = PublishRelay<Bool>()
    let checkAllPermissionsSubject = PublishSubject<Bool>()
    
    func checkAllPermissions(completion: @escaping ((Bool) -> ())){
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            completion(true)
        } else {
            completion(false)
        }
        
    }
    
    func isValidAccessToken(){
        let param = CameraParam.RequestSubscribeData()
        CameraAPI.shared.networking(cameraService: .subscribe(param: param), type: CameraSubscribeResponse.self)
            .subscribe(with: self, onSuccess: { owner, networkResult in
                switch networkResult {
                case .success(let data):
                    guard let data = data else {
                        self.isValidAccessTokenRelay.accept(false)
                        return
                    }
                    UserDefaults.standard.set(data.accessToken, forKey: UserDefaultsKey.accessToken.rawValue)
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

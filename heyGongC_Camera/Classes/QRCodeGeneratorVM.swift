//
//  QRCodeGeneratorVM.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

class QRCodeGeneratorVM {
    
    //QR코드 기기 UUID
    private var qrData: String?
    var successAddDevice = BehaviorRelay<Bool>(value: false)
    var soundDataRelay = PublishRelay<[Double]>()
    var bag = DisposeBag()
    var recorder: SoundRecorder = SoundRecorder()
    var isRecording: Bool = false
    var soundData: [Double] = []
    var timer: Timer?
    
    func startDetecting() {
        isRecording = true
        // 여기에 녹음 시작 관련 로직 추가
        recorder.startRecording()
        
        // 예제에서는 단순화를 위해 Timer를 사용하여 임의의 사운드 데이터를 생성
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.isRecording {
                self.soundData.append(Double.random(in: 0..<500))
                self.soundDataRelay.accept(self.soundData)
            }
        }
    }
    
    func stopDetecting() {
        isRecording = false
        recorder.stopRecording()
        // 녹음 중지 관련 로직 추가
    }
    
//    public func setTimer(){
//        timer = Timer(timeInterval: 5, repeats: true){ [weak self] _ in
//            guard let self else { return }
//            recorder.startRecording()
//        }
//        
//        guard let timer = timer else { return }
//        RunLoop.current.add(timer, forMode: .default)
//        
//        timer.fire()
//        print("timer fire")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [weak self] in
//            guard let self else { return }
//            
//            recorder.stopRecording()
//            timer.invalidate()
//        }
//    }
    
    public func generateQRCodeData()-> Data? {
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)
        
        if device.responds(to: selector){
            let modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
            qrData = Util.getUUID() + " \(modelName)"
            return qrData?.data(using: .utf8)
        }
            return nil
    }
}

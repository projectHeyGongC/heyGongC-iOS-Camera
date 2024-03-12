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
    
    //QR코드형식 - ("UUID Model명")
    private var qrData: String?
    private var timer: Timer?
    private var soundData: [Double] = []
    private var recorder: SoundAnalyzer = SoundAnalyzer()
    
    var bag = DisposeBag()
    
    var successAddDevice = PublishRelay<Bool>()
    var soundDataRelay = PublishRelay<Double>()
    var recordingSubject = PublishSubject<Bool>()
    
    init(){
        recorder.onRecordingProcessed = { averageTopTenPercent in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                print("Processed Value: \(averageTopTenPercent)") // Diagnostic log
                soundDataRelay.accept(averageTopTenPercent)
            }
        }
        
        bind()
    }
    
    private func bind(){
        recordingSubject
            .subscribe{ [weak self] in
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
                
            }.disposed(by: bag)
    }
    
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

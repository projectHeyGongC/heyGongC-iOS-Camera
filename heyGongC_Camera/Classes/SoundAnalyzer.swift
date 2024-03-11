//
//  SoundAnalyzer.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/9/24.
//

import Foundation
import AVFoundation
import RxSwift

class SoundAnalyzer {
    enum Status {
        // 녹음 시작
        case Recording
        // 녹음 멈춤
        case Paused
        // 녹음 중지
        case Stopped
        // 분석?
        case Analyzing
    }
    
    var audioEngine: AVAudioEngine!
    var audioInputNode: AVAudioInputNode!
    
    //아마 이 값은 모니터링에서 설정하는 소리 민감도에 따라 변경될 가능성이 있음.
    let minDb: Float = -80
    var status = Status.Stopped
    var timer: Timer?
    private let bag = DisposeBag()
    
    init(){
        setAudioSession()
        setAudioEngine()
    }
    
    deinit {
        stopRecording()
        print("deinit Recorder")
    }
    
    private func setAudioSession(){
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.record)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("error - setAudioSession")
        }
    }
    
    private func setAudioEngine(){
        audioEngine = AVAudioEngine()
        
        audioInputNode = audioEngine.inputNode
        let inputFormat = audioInputNode.outputFormat(forBus: 0)
        
        audioEngine.prepare()
    }
    
    public func setAnalyzer(){
        timer = Timer(timeInterval: 5, repeats: true){ [weak self] _ in
            guard let self else { return }
            startAudioEngine()
        }
        
        guard let timer = timer else { return }
        RunLoop.current.add(timer, forMode: .default)
        
        timer.fire()
        print("timer fire")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [weak self] in
            guard let self else { return }
            
            stopRecording()
            timer.invalidate()
        }
    }
    
    @objc private func startAudioEngine(){
        // 입력 노드에서 오디오 데이터를 받기 위해 노드 설정
        let format = audioInputNode.inputFormat(forBus: 0)
        audioInputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
            self.analyzeAudioBuffer(buffer)
        }
        
        do {
            try audioEngine.start()
            status = .Recording
            print("audioEngine start")
            
        } catch {
            print("error - startRecording")
        }
    }

    private func stopRecording(){
        print("Recording Stopped")
        audioEngine.stop()
        audioInputNode.removeTap(onBus: 0)
        status = .Stopped
    }
    
    private func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let floatData = buffer.floatChannelData else { return }
        let channelDataValue = floatData.pointee
        
        let channelDataValueArray = stride(from: 0, through: Int(buffer.frameLength), by: buffer.stride)
            .map{ channelDataValue[$0]}
        
        let rms = sqrt(channelDataValueArray.map{
            return $0 * $0
        }
            .reduce(0, +) / Float(buffer.frameLength))
        
        //RMS를 데시벨로 변환
        let avgPower = 20 * log10(rms)
        print("AveragePower: \(avgPower)")
        
        let meterLevel = self.scaledPower(power: avgPower)
        if meterLevel >= 0.7 {
            print("큰 소리 감지: \(meterLevel)")
        }
    }
    
    //여기서 들어가는 power은 averagePower이다.
    private func scaledPower(power: Float) -> Float {
        //iOS는 -160~0의 dBFS를 사용 -160은 무음에 가깝다. 0은 최대전력.
        
        //power이 유효값인지 확인
        guard power.isFinite else {
            return 0.0
        }
        
        //<---- 코드 수정 필요
        
        //minDb는 다이나믹 레인지이다.
        //다이나믹 레인지는 시스템 에서 신호가 가장 큰 경우의 신호 대 잡음비
        if power < minDb {
            //averagePower가 minDb보다 작은 경우
            return 0.0
        } else if power >= 1.0 {
            //최대 전력에 도달하는 경우
            return 1.0
        } else {
            //0.0과 1.0 사이의 스케일링된 값을 계산
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
        
        //------>
    }
}

//
//  SoundAnalyzer.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/9/24.
//

import Foundation
import AVFoundation
import RxSwift
import RxRelay

class SoundAnalyzer {

    private let audioEngine = AVAudioEngine()
    private var buffer: [Float] = []
    private var recordingFormat: AVAudioFormat!
    var onRecordingProcessed: ((Double) -> Void)?
    
    private let bag = DisposeBag()
    
    init() {
        setupAudioSession()
    }
    
    deinit {
        stopRecording()
        print("deinit Recorder")
    }
    
    func setupAudioSession(){
        guard let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false) else { return }
        self.recordingFormat = recordingFormat
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
            return
        }
    }
    
    func startRecording() {
        
        let inputNode = audioEngine.inputNode
        
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            guard let self = self else { return }
        
            // Convert the audio buffer to an array of Float values
            let bufferPointer = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            self.buffer.append(contentsOf: Array(bufferPointer))
        }
        
        do {
            print("startRecording")
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
            return
        }
    }
    
    
    public func stopRecording(){
        print("Recording Stopped")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        processRecordingData()
        buffer.removeAll()
    }
    
    private func processRecordingData() {
        //let processor = PCMDataProcessor()
        let topAvg = PCMDataProcessor.calculateAverageOfTopTenPercent(from: buffer)
        DispatchQueue.main.async {
            self.onRecordingProcessed?(topAvg)
        }
    }
}

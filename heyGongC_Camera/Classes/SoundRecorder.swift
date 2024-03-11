import Foundation
import AVFoundation

class SoundRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingData = [Float]()
    private var isRecording = false
    
    // Audio recording settings
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 48000,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false
    ] as [String: Any]
    
    func startRecording() {
        // Ensure the user has granted microphone access
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            guard granted else { return }
            self.setupRecorder()
            self.audioRecorder?.record()
            print("start Recording")
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        print("stop Recording")
        isRecording = false
        // Process the recording data here if needed
    }
    
    private func setupRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print("Failed to initialize the audio recorder: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

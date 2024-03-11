import Foundation

class PCMDataProcessor {
    private var pcmData: [Float]
    
    init(pcmData: [Float] = []) {
        self.pcmData = pcmData
    }
    
    func calculateAverageOfTopTenPercent() -> Double {
        if pcmData.isEmpty { return 0.0 }
        
        let sortedData = pcmData.sorted() // 데이터 정렬
        let topTenPercentIndex = Int(Double(sortedData.count) * 0.9) // 상위 10%의 시작 인덱스 계산
        let topTenPercentValues = Array(sortedData[topTenPercentIndex..<sortedData.count]) // 상위 10% 데이터 선택
        
        // 상위 10%의 평균값 계산
        return topTenPercentValues.reduce(0.0){ $0 + Double($1) } / Double(topTenPercentValues.count)
    }
}

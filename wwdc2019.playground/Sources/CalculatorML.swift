import Foundation
import Vision
import UIKit

public class CalculatorML {
    public var calcModelDelegate: CalculatorMLDelegate?
    
    public init(delegate: CalculatorMLDelegate) {
        self.calcModelDelegate = delegate
    }
    
    public init() {}
    
    public func setupML(isMac: Bool) -> VNCoreMLModel? { // TODO: remove isMac before submitting
        var path: URL?
        
        if isMac {
            guard let macPath = Bundle.main.path(forResource: "ImageClassifier", ofType: "mlmodelc") else {
                print("MLModel not found")
                return nil
            }
            path = URL(fileURLWithPath: macPath)
        } else {
            guard let iosPath = Bundle.main.path(forResource: "ImageClassifier", ofType: "mlmodel") else {
                print("MLModel not found")
                return nil
            }
            let modelUrl = URL(fileURLWithPath: iosPath)
            guard let compiledUrl = try? MLModel.compileModel(at: modelUrl) else {
                print("Couldn't compile MLModel")
                return nil
            }
            path = compiledUrl
        }
        
        guard let checkedPath = path else {
            print("Path mustn't be nil")
            return nil
        }
        guard let checkedMlModel = try? MLModel(contentsOf: checkedPath) else {
            print("Could not load compiled model")
            return nil
        }
        guard let model = try? VNCoreMLModel(for: checkedMlModel) else {
            print("Could not init VNCoreMLModel")
            return nil
        }
        return model
    }
    
    public func handleRequest(request: VNRequest, error: Error?) {
        if error != nil {
            print("Error: \(String(describing: error))")
            return
        }
        if error != nil {
            
            print("Error: \(String(describing: error))")
        }
        guard let results = request.results as? [VNClassificationObservation],
            let _ = results.first else {
                print("No results found")
                return
        }
        if let first = results.first {
            let second = results[1]
            guard let confidencePercentage = Int(exactly: round(first.confidence*100)) else {
                print("Could not get confidencePercentage")
                return
            }
            
            if confidencePercentage < 60 {
                self.showConfirmationAlert(option1: first, option2: second)
            } else {
                self.calcModelDelegate?.displayClassificationResult(result: first)
            }
        }
    }
    
    private func showConfirmationAlert(option1: VNClassificationObservation, option2: VNClassificationObservation) {
        let alert = UIAlertController(title: "I'm not sure...", message: "What number did you draw?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: option1.identifier, style: .default, handler: { _ in
            self.calcModelDelegate?.displayClassificationResult(result: option1)
        }))
        alert.addAction(UIAlertAction(title: option2.identifier, style: .default, handler: { _ in
            self.calcModelDelegate?.displayClassificationResult(result: option2)
        }))
        
        self.calcModelDelegate?.presentAlert(alert: alert)
    }
}

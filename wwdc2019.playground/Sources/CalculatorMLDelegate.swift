import Foundation
import UIKit
import Vision

public protocol CalculatorMLDelegate {
    func displayClassificationResult(result: VNClassificationObservation)
    func presentAlert(alert: UIAlertController)
}

import Foundation
import UIKit

public class CalculatorResultField: UITextField {
    
    convenience public init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    public func highlightLetter(index: Int) {
        guard let fullText = self.text else {
            print("No text set for label")
            return
        }
        if index >= fullText.count-1 {
            print("Index out of bounds in \(#function) on \(#line)")
            return
        }
        let range = NSRange(location: index, length: 1)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.backgroundColor, value: Constants.accentColor, range: range) // use variable accentColor
        self.attributedText = attribute
    }
    
    public func printOperatorToTextField(mathOperator: MathOperator, currentResult: String?) {
        if self.text == nil {
            self.text = "0/\(mathOperator.rawValue)"
        } else {
            if MathOperator.isOperator(c: self.text!.last!) {
                self.text!.removeLast()
            }
            if let checkedCurrentResult = currentResult {
                self.text = "\(checkedCurrentResult)\(mathOperator.rawValue)"
            } else {
                self.text! += mathOperator.rawValue
            }
        }
    }
    
    // else text gets selected when clicked
    public override var canBecomeFirstResponder: Bool {
        return false
    }
    
    private func setupUI() {
        self.textColor = UIColor.black
        self.backgroundColor = UIColor.white
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 30.0)
        self.isUserInteractionEnabled = true
    }
}

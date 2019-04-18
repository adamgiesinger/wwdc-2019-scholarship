import Foundation
import UIKit

public class OperatorButton : UIButton {
    public var mathOperator: MathOperator?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        self.titleLabel?.font = .systemFont(ofSize: 20.0)
        self.setTitleColor(.white, for: .normal)
        
        self.setBackgroundColor(color: Constants.accentColor, for: .normal)
        self.setBackgroundColor(color: Constants.accentColorDarker, for: .highlighted)
        self.setBackgroundColor(color: Constants.accentColorGrayed, for: .disabled)
    }
    
    private func setBackgroundColor(color: UIColor, for forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if UIGraphicsGetCurrentContext() == nil {
            print("Could not get context")
            return
        }
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}

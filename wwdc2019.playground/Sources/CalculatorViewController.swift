import UIKit
import Vision


public class CalculatorViewController: UIViewController, CanvasViewDelegate, CalculatorMLDelegate {
    
    //MARK: Class variables
    // UI
    let resultLabel = CalculatorResultField()
    let clearBtn = UIButton(type: .system)
    let drawingCanvas = CanvasView()
    
    let tutorialViewCanvas = UIView()
    let tutorialTextCanvas = UILabel()
    let startText = UILabel()
    let tutorialViewBorderCanvas = CAShapeLayer()
    
    let tutorialViewBorderResult = CAShapeLayer()
    let tutorialViewResult = UIView()
    let tutorialTextResult = UILabel()
    let tutorialInfoTextResult = UILabel()
    
    var tutorialBtn = UIButton()
    var operatorButtons: [OperatorButton] = []
    var operatorsCollectionView = OperatorCollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: UICollectionViewFlowLayout(), reuseIdentifier: "cell")
    let calcML = CalculatorML()
    var isMac = false
    var model: VNCoreMLModel?
    var currentResult: String? = nil
    var isShowingResult = false
    var showedResultTutorial = false
    var startTutorialShown = false
    
    
    
    //MARK: Constructors
    convenience public init() {
        self.init(isMac: false)
    }
    
    public init(isMac: Bool) {
        self.isMac = isMac
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: UIViewController overrides
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.model = calcML.setupML(isMac: self.isMac)
    
        self.drawingCanvas.canvasViewDelegate = self
        self.calcML.calcModelDelegate = self
        self.operatorsCollectionView.delegate = self
        self.operatorsCollectionView.dataSource = self
        
        self.operatorsCollectionView.backgroundColor = Constants.wwdcColorDark
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        let collectionWidth: CGFloat = viewWidth*0.2
        let canvasWidth = viewWidth-collectionWidth
        let canvasHeight = viewHeight-Constants.resultLabelHeight
        var operatorBtnRect = CGRect.zero
        if collectionWidth*0.5 > 30 {
            operatorBtnRect = CGRect(x: 0,
                                         y: 0,
                                         width: collectionWidth*0.5-0.5,
                                         height: collectionWidth*0.5-1)
        } else {
            operatorBtnRect = CGRect(x: 0,
                                         y: 0,
                                         width: collectionWidth,
                                         height: collectionWidth)
        }
        
        
        self.operatorsCollectionView.frame = CGRect(x: viewWidth-collectionWidth,
                                                    y: 0,
                                                    width: collectionWidth,
                                                    height: canvasHeight)
        
        self.drawingCanvas.frame = CGRect(x: 0,
                                          y: 0,
                                          width: canvasWidth,
                                          height: canvasHeight)
        
        self.resultLabel.frame = CGRect(x: 0,
                                        y: canvasHeight,
                                        width: viewWidth,
                                        height: Constants.resultLabelHeight)
        
        self.tutorialViewCanvas.frame = CGRect(x: 13,
                                               y: 13,
                                               width: canvasWidth-26,
                                               height: canvasHeight-26)
        
        self.tutorialViewBorderCanvas.path = UIBezierPath(roundedRect: self.tutorialViewCanvas.bounds, cornerRadius: 8).cgPath
        self.tutorialViewBorderCanvas.frame = self.drawingCanvas.bounds
        
        self.tutorialTextCanvas.frame.origin = CGPoint(x: 35,
                                               y: 3)
        self.tutorialTextCanvas.sizeToFit()
        
        self.tutorialInfoTextResult.frame.origin = CGPoint(x: 35,
                                                   y: canvasHeight+3)
        self.tutorialInfoTextResult.sizeToFit()
        
        self.startText.frame = CGRect(x: 0,
                                      y: 0,
                                      width: canvasWidth,
                                      height: canvasHeight)
        
        
        
        self.tutorialViewResult.frame = CGRect(x: 13,
                                               y: canvasHeight+13,
                                               width: resultLabel.bounds.width-26,
                                               height: resultLabel.bounds.height-26)
        
        self.tutorialViewBorderResult.path = UIBezierPath(roundedRect: self.tutorialViewResult.bounds, cornerRadius: 8).cgPath
        self.tutorialViewBorderResult.frame = self.resultLabel.bounds
        
        self.tutorialTextResult.frame = CGRect(x: resultLabel.bounds.width*0.85,
                                               y: canvasHeight+resultLabel.bounds.height*0.5 - 12, // vertically center in resultLabel
                                               width: 30,
                                               height: 24)
        
        self.tutorialBtn.frame = CGRect(x: 2, y: 2, width: 27, height: 27)
        self.tutorialBtn.layer.cornerRadius = 0.5*self.tutorialBtn.bounds.height
        

        
        for singleOperatorButton in self.operatorButtons {
            singleOperatorButton.frame = operatorBtnRect
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = operatorBtnRect.size
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        self.operatorsCollectionView.collectionViewLayout = layout
    }
    
    //MARK: private
    private func setupOperatorButtons() {
        for mathOperator in MathOperator.allCases {
            let btn = OperatorButton(type: .custom)
            btn.setTitle(mathOperator.rawValue, for: .normal)
            
            btn.mathOperator = mathOperator
            var selector = #selector(operatorClicked)
            if mathOperator == .clear {
                selector = #selector(clearCanvas)
            }
            btn.addTarget(self, action: selector, for: .touchUpInside)
            btn.isEnabled = false
            self.operatorButtons.append(btn)
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        
        self.setupOperatorButtons()
        
        self.resultLabel.text = "0"

        self.resultLabel.backgroundColor = Constants.wwdcColorDark
        self.resultLabel.textColor = .white
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleLabelGesture))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleLabelGesture))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        self.resultLabel.addGestureRecognizer(swipeLeft)
        self.resultLabel.addGestureRecognizer(swipeRight)
        
        let startTap = UITapGestureRecognizer(target: self, action: #selector(handleStartTap))
        self.tutorialViewCanvas.addGestureRecognizer(startTap)
        
        self.tutorialViewBorderCanvas.strokeColor = UIColor.white.cgColor
        self.tutorialViewBorderCanvas.fillColor = nil
        self.tutorialViewBorderCanvas.lineDashPattern = [4, 4]
        self.tutorialViewBorderCanvas.lineWidth = 2
        self.tutorialViewCanvas.layer.addSublayer(self.tutorialViewBorderCanvas)
        
        
        
        let resultTutorialTap = UITapGestureRecognizer(target: self, action: #selector(handleResultTutorialTap))
        self.tutorialViewResult.addGestureRecognizer(resultTutorialTap)
        
        self.tutorialViewBorderResult.strokeColor = UIColor.white.cgColor
        self.tutorialViewBorderResult.fillColor = nil
        self.tutorialViewBorderResult.lineDashPattern = [4, 4]
        self.tutorialViewBorderResult.lineWidth = 2
        self.tutorialViewResult.layer.addSublayer(self.tutorialViewBorderResult)
        
        self.tutorialTextCanvas.text = " Draw a number here ✍ "
        self.tutorialTextCanvas.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.tutorialTextCanvas.textColor = .white
        self.tutorialTextCanvas.backgroundColor = Constants.wwdcColorLight
        
        self.tutorialInfoTextResult.text = " Swipe to delete ⌫ "
        self.tutorialInfoTextResult.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.tutorialInfoTextResult.textColor = .white
        self.tutorialInfoTextResult.backgroundColor = Constants.wwdcColorDark
        
        self.tutorialTextResult.text = "👆"
        self.tutorialTextResult.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.tutorialTextResult.textColor = .white
        self.tutorialTextResult.backgroundColor = Constants.wwdcColorDark
        
        let swipeLeftTutorial = UISwipeGestureRecognizer(target: self, action: #selector(handleLabelGestureTutorial))
        let swipeRightTutorial = UISwipeGestureRecognizer(target: self, action: #selector(handleLabelGestureTutorial))
        swipeLeftTutorial.direction = .left
        swipeRightTutorial.direction = .right
        self.tutorialViewResult.addGestureRecognizer(swipeLeftTutorial)
        self.tutorialViewResult.addGestureRecognizer(swipeRightTutorial)
        
        self.startText.text = "Tap to get started"
        self.startText.font = UIFont.systemFont(ofSize: 15)
        self.startText.textColor = .white
        self.startText.textAlignment = .center
        self.startText.layer.opacity = 1
        self.fadeInOut(view: self.startText, durationIn: 0.8, delayIn: 0, durationOut: 0.8, delayOut: 0.3)
        
        self.tutorialBtn.setTitle("?", for: .normal)
        self.tutorialBtn.titleLabel!.font = .systemFont(ofSize: 17)
        self.tutorialBtn.setTitleColor(Constants.systemBlue, for: .normal)
        self.tutorialBtn.backgroundColor = .white
        self.tutorialBtn.layer.borderColor = UIColor.gray.cgColor
        self.tutorialBtn.layer.borderWidth = 1
        self.tutorialBtn.addTarget(self, action: #selector(showTutorial), for: .touchUpInside)
        
        self.view.addSubview(self.clearBtn)
        self.view.addSubview(self.drawingCanvas)
        self.view.addSubview(self.operatorsCollectionView)
        self.view.addSubview(self.tutorialViewCanvas)
        self.view.addSubview(self.tutorialTextCanvas)
        self.view.addSubview(self.resultLabel)
        self.view.addSubview(self.tutorialViewResult)
        self.view.addSubview(self.tutorialTextResult)
        self.view.addSubview(self.tutorialInfoTextResult)
        self.view.addSubview(self.startText)
        self.view.addSubview(self.tutorialBtn)
        
        self.tutorialViewResult.isHidden = true
        self.tutorialViewBorderResult.isHidden = true
        self.tutorialTextResult.isHidden = true
        self.tutorialInfoTextResult.isHidden = true
        self.tutorialBtn.isHidden = true
    }
    
    @objc private func handleStartTap() {
        if self.startTutorialShown {
            self.hideResultLabelTutorial()
        }
        self.tutorialViewCanvas.isHidden = true
        self.tutorialTextCanvas.isHidden = true
        self.startText.isHidden = true
        self.tutorialBtn.isHidden = false
        
        for singleOperatorButton in self.operatorButtons {
            singleOperatorButton.isEnabled = true
        }
        self.startTutorialShown = true
    }
    
    @objc private func handleResultTutorialTap() {
        self.hideResultLabelTutorial()
    }
    
    @objc private func showTutorial() {
        self.clearCanvas()
        self.tutorialViewCanvas.isHidden = false
        self.tutorialTextCanvas.isHidden = false
        self.tutorialViewResult.isHidden = false
        self.tutorialTextResult.isHidden = false
        self.tutorialViewBorderResult.isHidden = false
        self.tutorialInfoTextResult.isHidden = false
        self.startText.isHidden = false
        self.tutorialBtn.isHidden = true
        
        self.startText.text = "Tap to continue"
//        self.fadeInOut(view: self.startText, durationIn: 0.8, delayIn: 0, durationOut: 0.8, delayOut: 0.3)
        
        self.animateResultLabelLeft()
    }
    
    private func getFormattedLabel() -> String? {
        var isAfterDot = false
        if self.isShowingResult {
            self.resultLabel.text?.removeLast()
            return nil
        }
        guard let labelText = self.resultLabel.text else {
            print("Label text is nil")
            return nil
        }
        self.isShowingResult = true
        var formattedText: NSMutableString = ""
        for i in 0..<labelText.count-1 { // removing =, else NSExpression doesn't work
            let currentChar = String(labelText[labelText.index(labelText.startIndex, offsetBy: i)])
            formattedText.append(currentChar)
            if currentChar == "." {
                isAfterDot = true
            }
            if i < labelText.count-2 {
                if MathOperator.isOperator(c: labelText[labelText.index(labelText.startIndex, offsetBy: i+1)]) {
                    if !isAfterDot {
                        formattedText.append(".0")
                    } else {
                        isAfterDot = false
                    }
                }
            }
        }
        formattedText.append(".0")
        print(formattedText)
        
        formattedText = NSMutableString(string: formattedText.replacingOccurrences(of: "×", with: "*"))
        formattedText = NSMutableString(string: formattedText.replacingOccurrences(of: "÷", with: "/"))
        return (formattedText as String)
    }
    
    private func getResultFromString(calcString: String) -> Double? {
        let expression = NSExpression(format: calcString, argumentArray: [])
        if let result = expression.expressionValue(with: nil, context: nil) as? Double {
            print("Final result: \(result)")
            return result
        }
        return nil
    }
    
    private func displayCalcResult(calcResult: Double) {
        guard let oldLabelText = self.resultLabel.text else {
            print("Label text is nil")
            return 
        }
        self.resultLabel.text = oldLabelText + String(format: "%.2f", calcResult)
        currentResult = String(format: "%.2f", calcResult)
    }
    
    @objc private func handleLabelGestureTutorial() {
        hideResultLabelTutorial()
        handleLabelGesture()
    }
    
    @objc private func handleLabelGesture() {
        guard let resultLabelText = resultLabel.text else {
            return
        }
        if resultLabelText.count <= 1 {
            resultLabel.text = "0"
        } else {
            if resultLabelText.last == "=" {
                currentResult = nil
            }
            resultLabel.text!.removeLast()
        }
    }
    
    @objc private func clearCanvas() {
        self.drawingCanvas.clearCanvas()
    }
    
    
    @objc private func operatorClicked(sender: Any) {
        guard let button = sender as? OperatorButton else {
            print("Sender is no OperatorButton")
            return
        }
        
        guard let mathOperator = button.mathOperator else {
            print("Math operator not set for button")
            return
        }
        
        self.clearCanvas()
    
        self.resultLabel.printOperatorToTextField(mathOperator: mathOperator, currentResult: self.currentResult)
        self.currentResult = nil
        
        if mathOperator == MathOperator.equals && !displayResultFromLabel() {
            print("Could not calculate")
        }
        
    }
    
    private func displayResultFromLabel() -> Bool {
        guard let formattedLabel = self.getFormattedLabel() else {
            print("Couldn't get formatted label")
            return false
        }
        guard let calcResult = self.getResultFromString(calcString: formattedLabel) else {
            print("Could not get result from string")
            return false
        }
        self.displayCalcResult(calcResult: calcResult)
        return true
    }
    
    private func displayResult(result: VNClassificationObservation) {
        DispatchQueue.main.async {
            print("I'm \(result.confidence*100)% sure that this is a \(result.identifier)")
            guard var labelText = self.resultLabel.text else {
                print("Label text is nil")
                return
            }
            if labelText == "0" {
                labelText = ""
            }
            
            if self.currentResult != nil {
                labelText = "" // clear labelText to only display the new number instead of appending it to the old label
            }
            self.currentResult = nil
            self.resultLabel.text = labelText + result.identifier
            self.isShowingResult = false
            if !self.showedResultTutorial {
                self.showResultLabelTutorial()
                self.showedResultTutorial = true
            }
        }
    }
    
    private func fadeInOut(view: UIView, duration: TimeInterval, delay: TimeInterval) {
        fadeInOut(view: view, durationIn: duration, delayIn: delay, durationOut: duration, delayOut: delay)
    }
    
    private func fadeInOut(view: UIView, durationIn: TimeInterval, delayIn: TimeInterval, durationOut: TimeInterval, delayOut: TimeInterval) {
        view.fadeOut(duration: durationOut, delay: delayOut) { (result1) in
            view.fadeIn(duration: durationIn, delay: delayIn, completion: { (result1) in
                self.fadeInOut(view: view, durationIn: durationIn, delayIn: delayIn, durationOut: durationOut, delayOut: delayOut)
            })
        }
    }
    
    private func showResultLabelTutorial() {
        self.tutorialViewResult.isHidden = false
        self.tutorialViewBorderResult.isHidden = false
        self.tutorialTextResult.isHidden = false
        self.animateResultLabelLeft()
        self.tutorialInfoTextResult.isHidden = false
    }
    
    
    private func hideResultLabelTutorial() {
        self.tutorialViewResult.isHidden = true
        self.tutorialViewBorderResult.isHidden = true
        self.tutorialTextResult.isHidden = true
        self.tutorialInfoTextResult.isHidden = true
    }
    
    private func animateResultLabelLeft() {
        self.animateLabelLeft(delay: 0.1, completion: { success in
            print("Completed")
            self.tutorialTextResult.frame = CGRect(x: self.resultLabel.bounds.width*0.85,
                                                   y: self.view.bounds.height-Constants.resultLabelHeight+Constants.resultLabelHeight*0.5 - 12, // vertically center in resultLabel
                width: 30,
                height: 24)
            self.animateLabelLeft(delay: 0.5, completion: {success in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.hideResultLabelTutorial()
                }
            })
        })
    }
    
    private func animateLabelLeft(delay: TimeInterval, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: 2.3, delay: delay, options: .curveEaseInOut, animations: {
            self.tutorialTextResult.frame = CGRect(x: self.resultLabel.bounds.width*0.15,
                                                   y: self.view.bounds.height-Constants.resultLabelHeight+Constants.resultLabelHeight*0.5 - 12, // vertically center in resultLabel
                width: 30,
                height: 24)
        }, completion: completion)
    }
    
    //MARK: CanvasViewDelegate protocol
    public func imageChanged(image: UIImage) {
        DispatchQueue.global().async {
            guard let model = self.model else {
                print("Model must not be nil")
                return
            }
            
            let request = VNCoreMLRequest(model: model, completionHandler: self.calcML.handleRequest)
            guard let ciImage = CIImage(image: image) else {
                print("Could not convert UIImage to CIImage")
                return
            }
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK: CalculatorMLDelegate protocol
    public func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    public func displayClassificationResult(result: VNClassificationObservation) {
        self.displayResult(result: result)
    }
}

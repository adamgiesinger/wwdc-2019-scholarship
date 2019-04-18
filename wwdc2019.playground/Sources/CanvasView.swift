import UIKit

public class CanvasView: UIView {
    
    //MARK: Class vars
    var path = UIBezierPath()
    var fullPath = UIBezierPath()
    var allPathsForOneChar = UIBezierPath()
    var currentStartPosition: CGPoint?
    var fullPathLayers: [CAShapeLayer] = []
    var isDrawing = false
    var timers: [Timer] = []
    
    public var canvasViewDelegate: CanvasViewDelegate?
    
    //MARK: UIView Overrides
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        self.backgroundColor = Constants.wwdcColorLight
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            let touch = touches.first
            self.currentStartPosition = touch?.location(in: self)
            self.isDrawing = true
            
            self.path = UIBezierPath()
            
            guard let startPosition = self.currentStartPosition else {
                print("Staring Point must not be nil")
                return
            }
            
            self.path.move(to: startPosition)
            self.path.addLine(to: startPosition)
            self.fullPath.move(to: startPosition)
            self.fullPath.addLine(to: startPosition)
            
            self.currentStartPosition = startPosition
            self.drawShapeLayer(path: self.path, isFullPath: false, color: UIColor.white)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentStartPosition = self.currentStartPosition else {
            print("Starting Point must not be nil")
            return
        }
        guard let touchPoint = touches.first?.location(in: self) else {
            print("Touch Point must not be nil")
            return
        }
        
        self.path = UIBezierPath()
        
        self.path.move(to: currentStartPosition)
        self.path.addLine(to: touchPoint)
        self.fullPath.move(to: currentStartPosition)
        self.fullPath.addLine(to: touchPoint)
        
        self.currentStartPosition = touchPoint
        drawShapeLayer(path: self.path, isFullPath: false, color: UIColor.white)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDrawing = false
        
        for timer in self.timers {
            timer.invalidate()
        }
        
        self.allPathsForOneChar.append(fullPath)
        self.runTimer()
        
    }
    
    
    //MARK: Public
    public func clearCanvas() {
        self.path.removeAllPoints()
        self.fullPath.removeAllPoints()
        self.allPathsForOneChar.removeAllPoints()
        self.layer.sublayers = nil
        self.fullPathLayers = []
    }
    
    //MARK: Private
    private func runTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
            if !self.isDrawing {
                guard let image = self.asImage(from: self.allPathsForOneChar) else {
                    print("Could not get image")
                    return
                }
                
                self.allPathsForOneChar.removeAllPoints()
                
                guard let data = image.jpegData(compressionQuality: 1) else {
                    print("Could not get data")
                    return
                }
                
                guard let realImage = UIImage(data: data) else {
                    print("Could not get image")
                    return
                }
                
                self.canvasViewDelegate?.imageChanged(image: realImage)
                
                self.layer.sublayers = []
                for singleLayer in self.fullPathLayers {
                    self.layer.addSublayer(singleLayer)
                }
                self.drawShapeLayer(path: self.fullPath, isFullPath: true, color: Constants.accentColor)
                self.path.removeAllPoints()
                self.fullPath.removeAllPoints()
            }
        }
        self.timers.append(timer)
    }
    
    private func getPath() -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Default URL not found")
            return nil
        }
        var path = documentsDirectory.absoluteString
        let range = path.index(path.startIndex, offsetBy: 5)
        path = String(path[range...]) // remove "file://"
        return path
    }
    
    private func drawShapeLayer(path: UIBezierPath, isFullPath: Bool, color: UIColor) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 12
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        if isFullPath {
            fullPathLayers.append(shapeLayer)
        }
        
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
    }
    
    private func asImage(from path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        UIColor.black.setStroke()
        path.lineWidth = 12
        path.lineCapStyle = .round
        path.stroke()
        guard var image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Could not get image from context")
            return nil
        }
        UIGraphicsEndImageContext()
        
        let rect = CGRect(x: path.bounds.minX*2-path.lineWidth, y: path.bounds.minY*2-path.lineWidth, width: (path.bounds.width+path.lineWidth)*2, height: (path.bounds.height+path.lineWidth)*2)
        guard let croppedImage = image.cgImage?.cropping(to: rect) else {
            print("Could not convert UIImage to CGImage")
            return nil
        }
        image = UIImage(cgImage: croppedImage)
        return image
    }
}

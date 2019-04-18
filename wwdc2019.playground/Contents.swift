import PlaygroundSupport
import UIKit

let vc = CalculatorViewController(isMac: true)
vc.preferredContentSize = CGSize(width: 600, height: 400)
PlaygroundPage.current.liveView = vc

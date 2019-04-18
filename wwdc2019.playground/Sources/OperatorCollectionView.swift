import Foundation
import UIKit

public class OperatorCollectionView: UICollectionView {
    public var reuseIdentifier: String = ""
    public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, reuseIdentifier: String) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.reuseIdentifier = reuseIdentifier
        self.setupUI()
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
    }
}

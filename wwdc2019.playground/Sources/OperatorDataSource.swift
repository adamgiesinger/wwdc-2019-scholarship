import UIKit

extension CalculatorViewController: UICollectionViewDelegate {
    
}

extension CalculatorViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.operatorButtons.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let colView = collectionView as? OperatorCollectionView else {
            return UICollectionViewCell(frame: CGRect.zero)
        }
        let buttonCell =  colView.dequeueReusableCell(withReuseIdentifier: colView.reuseIdentifier, for: indexPath)
        let btn = self.operatorButtons[indexPath.row] // check index out of bounds
        buttonCell.addSubview(btn)
        return buttonCell
    }
    
}

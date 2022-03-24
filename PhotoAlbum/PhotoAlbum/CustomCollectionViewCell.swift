import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImageView()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func setImageView() {
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

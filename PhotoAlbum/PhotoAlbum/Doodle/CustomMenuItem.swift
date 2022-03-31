import Foundation
import UIKit

class CustomMenuItem: UIMenuItem {
    var indexPath: IndexPath?
    
    convenience init(title: String, action: Selector, indexPath: IndexPath? = nil) {
        self.init(title: title, action: action)
        self.indexPath = indexPath
    }
}

import UIKit

class DoodleViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var customImageDownloadManager: CustomImageDownloadManager = CustomImageDownloadManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customImageDownloadManager.parseDoodleData{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.collectionView.backgroundColor = .darkGray
        self.view.backgroundColor = .darkGray
        self.navigationItem.title = "Doodle"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissView))
        
        self.collectionView.register(CustomDoodleCollectionViewCell.self, forCellWithReuseIdentifier: "CustomDoodleCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(targetViewDidPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.isEnabled = true
        self.collectionView.addGestureRecognizer(longPress)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: false)
    }
    
    @objc func targetViewDidPress(_ gesture: UILongPressGestureRecognizer) {
        gesture.view?.becomeFirstResponder()
        
        guard let cell = gesture.view as? CustomDoodleCollectionViewCell else { return }
        
        let menuItem = CustomMenuItem(title: "save", action: #selector(saveDidTap(sender:)), cell: cell)
        UIMenuController.shared.menuItems = [menuItem]
        UIMenuController.shared.showMenu(from: cell.superview!, rect: cell.frame)
    }
    
    @objc func saveDidTap(sender: CustomMenuItem) {
        DispatchQueue.main.async {
            guard let cell = sender.cell else { return }
            guard let image = cell.imageView.image else { return }
            self.saveImage(image)
        }
    }
    
    func saveImage(_ image: UIImage) {
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension DoodleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.customImageDownloadManager.imageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomDoodleCollectionViewCell", for: indexPath) as! CustomDoodleCollectionViewCell
        let imageData = self.customImageDownloadManager.getImageData(index: indexPath.row)
        cell.imageView.image = UIImage(data: imageData)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(targetViewDidPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.isEnabled = true
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == NSSelectorFromString("saveImage")
    }
    
}

class CustomMenuItem: UIMenuItem {
    var cell: CustomDoodleCollectionViewCell?
    
    convenience init(title: String, action: Selector, cell: CustomDoodleCollectionViewCell? = nil) {
        self.init(title: title, action: action)
        
        self.cell = cell
    }
}



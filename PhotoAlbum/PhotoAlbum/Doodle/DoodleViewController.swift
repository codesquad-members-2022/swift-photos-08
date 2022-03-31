import UIKit

class DoodleViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var customImageDownloadManager: CustomImageDownloadManager = CustomImageDownloadManager()
    private var customMenuItem: CustomMenuItem = CustomMenuItem(title: "save", action: #selector(saveDidTap(sender:)))
    
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
    
    @objc func dismissView() {
        self.dismiss(animated: false)
    }
    
    @objc func targetViewDidPress(_ gesture: UILongPressGestureRecognizer) {
        guard let gestureView = gesture.view, let superView = gestureView.superview else { return }
        
        let point = gesture.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if indexPath != nil {
            gestureView.becomeFirstResponder()
            self.customMenuItem.indexPath = indexPath
            UIMenuController.shared.menuItems = [customMenuItem]
            UIMenuController.shared.showMenu(from: superView, rect: gestureView.frame)
        }
    }
    
    @objc func saveDidTap(sender: CustomMenuItem) {
            guard let indexPath = self.customMenuItem.indexPath else { return }
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? CustomDoodleCollectionViewCell else { return }
            guard let image = cell.imageView.image else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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



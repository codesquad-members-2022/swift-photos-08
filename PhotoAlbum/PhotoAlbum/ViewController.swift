import UIKit
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    private var customPhotoManager: CustomPhotoManager = CustomPhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNotificationCenter()
        
        self.collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.customPhotoManager.getAuthorization()
    }
    
    private func initializeNotificationCenter(){
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)), name: CustomPhotoManager.NotificationName.authorizationDeniedAlert, object: self.customPhotoManager)
    }
    
    @objc func presentAlert(_ notification: Notification) {
        guard let alertTitle = notification.userInfo?[CustomPhotoManager.UserInfoKey.alertTitle] as? String else { return }
        guard let alertMessage = notification.userInfo?[CustomPhotoManager.UserInfoKey.alertMessage] as? String else { return }
        guard let actionTitle = notification.userInfo?[CustomPhotoManager.UserInfoKey.actionTitle] as? String else { return }
        guard let settingActionHandler = notification.userInfo?[CustomPhotoManager.UserInfoKey.settingActionHandler] as? Bool else { return }
        
        let authAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let getAuthAction = UIAlertAction(title: actionTitle, style: .default, handler: !settingActionHandler ? nil : { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        
        authAlert.addAction(getAuthAction)
        DispatchQueue.main.async {
            self.present(authAlert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.customPhotoManager.getAssetCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        
        let manager = PHCachingImageManager()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        manager
            .requestImage(for: assets[indexPath.row], targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option, resultHandler: {(result, info) ->  Void in
                cell.imageView.image = result
            })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: 100)
    }
    
}

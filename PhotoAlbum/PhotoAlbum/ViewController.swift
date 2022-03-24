import UIKit
import Photos

class ViewController: UIViewController {
    
    var images: PHAssetCollection?
    var assets: [PHAsset] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        PHPhotoLibrary.shared().register(self)
        getAuthorization()
    }
    
    func getAuthorization() {
        if isAlbumAcessAuthorized() {
            fetchAssetCollection()
        } else if isAlbumAccessDenied() {
            async { self.setAuthAlertAction() }
        } else {
            PHPhotoLibrary.requestAuthorization() { (status) in
                self.getAuthorization()
            }
        }
    }
    
    func setAuthAlertAction() {
        let authAlert = UIAlertController(title: "사진 앨범 권한 요청", message: "사진첩 권한을 허용해야만 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
        
        let getAuthAction = UIAlertAction(title: "넵", style: .default, handler: { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        
        authAlert.addAction(getAuthAction)
        self.present(authAlert, animated: true, completion: nil)
    }

    func fetchAssetCollection() {
        PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
            self.images = collection
        }
        
        self.fetchAsset()
    }
    
    func isAlbumAcessAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited
    }
    
    func isAlbumAccessDenied() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .denied
    }
    
    func fetchAsset() {
        guard let images = self.images else {
            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
                PHAsset.fetchAssets(in: images, options: fetchOptions).enumerateObjects({ (asset, _, _) in
            self.assets.append(asset)
        })
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = self.images else { return 0 }
        
        return PHAsset.fetchAssets(in: images, options: nil).count
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

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        async {
            let alert = UIAlertController(title: "옵저버가 변화를 감지했습니다!", message: "아직 무슨 변화인지는 몰라요!", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: false, completion: nil)
        }
    }
}


import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate {
    
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
        
        if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited {
            PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
                self.images = collection
            }
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            print("Permission Denied")
        } else {
            PHPhotoLibrary.requestAuthorization() { (status) in
                switch status {
                case .authorized:
                    PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
                        self.images = collection
                    }
                    break
                default:
                    print("Permission Denied")
                }
            }
        }
        
        PHAsset.fetchAssets(in: self.images!, options: PHFetchOptions()).enumerateObjects({ (asset, _, _) in
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


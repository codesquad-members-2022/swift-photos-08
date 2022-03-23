import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate {
    
//    var images: [PHAssetCollection] = []
    var selectedCollection: PHAssetCollection?
    
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
            PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
//                self.images.append(collection)
                if collection.localizedTitle == "Recents" {
                    self.selectedCollection = collection
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            print("Permission Denied")
        } else {
            PHPhotoLibrary.requestAuthorization() { (status) in
                switch status {
                case .authorized:
                    PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
//                        self.images.append(collection)
                    }
                    break
                default:
                    print("Permission Denied")
                }
            }
        }
        
       

        
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = self.selectedCollection else {
            return 0
        }

        return PHAsset.fetchAssets(in: images, options: nil).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell

        var assets: [PHAsset] = []
        
//        images.forEach {
//            PHAsset.fetchAssets(in: $0, options: PHFetchOptions()).enumerateObjects({ (asset, _, _) in
//                assets.append(asset)
//            })
//        }
        
        PHAsset.fetchAssets(in: self.selectedCollection!, options: PHFetchOptions()).enumerateObjects({ (asset, _, _) in
            assets.append(asset)
        })
        
        assets.forEach {
            PHImageManager.default().requestImage(for: $0, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: PHImageRequestOptions(), resultHandler: {(result, info) ->  Void in
                cell.imageView.image = result
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: 100)
    }
    
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

    }
}

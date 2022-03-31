import Foundation
import Photos

class CustomPhotoManager: NSObject, PHPhotoLibraryChangeObserver{
    
    enum UserInfoKey: String{
        case authorizationDeniedAlert = "authorizationDeniedAlert"
        case alertTitle = "alertTitle"
        case alertMessage = "alertMessage"
        case actionTitle = "actionTitle"
        case settingActionHandler = "settingActionHandler"
    }
    
    struct NotificationName{
        static let  authorizationDeniedAlert = Notification.Name("authorizationDeniedAlert")
    }
    
    private let manager = PHCachingImageManager()
    private let option = PHImageRequestOptions()
    private var images: PHAssetCollection?
    private var assets: [PHAsset] = []
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override init(){
        super.init()
        PHPhotoLibrary.shared().register(self)
        self.option.isSynchronous = true
    }
    
    func getAssetCount()->Int{
        guard let images = self.images else { return 0 }
        return PHAsset.fetchAssets(in: images, options: nil).count
    }
    
    func getAuthorization() {
        if isAlbumAcessAuthorized() {
            fetchAssetCollection()
        } else if isAlbumAccessDenied() {
            self.setAuthAlertAction()
        } else {
            PHPhotoLibrary.requestAuthorization() { (status) in
                self.getAuthorization()
            }
        }
    }
    
    func fetchAssetCollection() {
        PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
            self.images = collection
        }
        self.assets = []
        self.fetchAsset()
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
    
    func requestImageData(index: Int)-> Data?{
        var imageData: Data?
        manager.requestImageDataAndOrientation(for: assets[index], options: option, resultHandler: {(data, _, _, _)-> Void in
            guard let data = data else { return }
            imageData = data
        })
        return imageData
    }
    
    func isAlbumAcessAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited
    }
    
    func isAlbumAccessDenied() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .denied
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        var userInfo: [UserInfoKey:Any] = [:]
        userInfo[UserInfoKey.alertTitle] = "옵저버가 변화를 감지했습니다!"
        userInfo[UserInfoKey.alertMessage] = "컬렉션뷰를 업데이트합니다."
        userInfo[UserInfoKey.actionTitle] = "OK!"
        userInfo[UserInfoKey.settingActionHandler] = false
        
        NotificationCenter.default.post(name: NotificationName.authorizationDeniedAlert, object: self, userInfo: userInfo)
    }
    
    func setAuthAlertAction() {
        var userInfo: [UserInfoKey:Any] = [:]
        userInfo[UserInfoKey.alertTitle] = "사진 앨범 권한 요청"
        userInfo[UserInfoKey.alertMessage] = "사진첩 권한을 허용해야만 기능을 사용하실 수 있습니다."
        userInfo[UserInfoKey.actionTitle] = "넵"
        userInfo[UserInfoKey.settingActionHandler] = true
        
        NotificationCenter.default.post(name: NotificationName.authorizationDeniedAlert, object: self, userInfo: userInfo)
    }
}

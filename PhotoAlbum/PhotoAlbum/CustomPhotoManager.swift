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
    
}

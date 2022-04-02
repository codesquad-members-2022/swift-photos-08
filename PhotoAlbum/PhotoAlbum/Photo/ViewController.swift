import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    private var customPhotoManager: CustomPhotoManager = CustomPhotoManager()
    private var doodleViewController: DoodleViewController?
    private let context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNotificationCenter()
        self.collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = true
        self.customPhotoManager.getAuthorization()
        self.doodleViewController = self.storyboard?.instantiateViewController(withIdentifier: "DoodleViewController") as? DoodleViewController
    }
    
    @IBAction func addButtonTouched(_ sender: UIBarButtonItem) {
        guard let doodleViewController = doodleViewController else { return }
        let doodleNavigationController = UINavigationController(rootViewController: doodleViewController)
        doodleNavigationController.modalPresentationStyle = .fullScreen
        self.present(doodleNavigationController, animated: false)
    }
    
    @IBAction func editButtonTouched(_ sender: UIBarButtonItem) {
        guard let selectedInedexPaths = self.collectionView.indexPathsForSelectedItems else { return }
        selectedInedexPaths.forEach {
            guard let cell = self.collectionView.cellForItem(at: $0) as? CustomCollectionViewCell else { return }
            guard let originalImage = cell.imageView.image else { return }
            guard let ciImage = CIImage(image: originalImage) else { return }
            guard let bloomImage = self.bloomFilter(ciImage) else { return }
            
            if let cgImage = self.context.createCGImage(bloomImage, from: bloomImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                let renderedData = uiImage.jpegData(compressionQuality: 1)
                self.customPhotoManager.requestModifyingImageData(index: $0.row, renderedData: renderedData)
            }
        }
    }
    
    func bloomFilter(_ input: CIImage) -> CIImage? {
        guard let bloomFilter = CIFilter(name: "CIBloom") else { return nil }
        bloomFilter.setValue(input, forKey: kCIInputImageKey)
        bloomFilter.setValue(1, forKey: kCIInputIntensityKey)
        bloomFilter.setValue(10, forKey: kCIInputRadiusKey)
        return bloomFilter.outputImage
    }
    
    private func initializeNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)), name: CustomPhotoManager.NotificationName.sendPresentingAlertSignal, object: self.customPhotoManager)
    }
    
    @objc func presentAlert(_ notification: Notification) {
        guard let alertTitle = notification.userInfo?[CustomPhotoManager.UserInfoKey.alertTitle] as? String else { return }
        guard let alertMessage = notification.userInfo?[CustomPhotoManager.UserInfoKey.alertMessage] as? String else { return }
        guard let actionTitle = notification.userInfo?[CustomPhotoManager.UserInfoKey.actionTitle] as? String else { return }
        guard let settingActionHandler = notification.userInfo?[CustomPhotoManager.UserInfoKey.settingActionHandler] as? Bool else { return }
        DispatchQueue.main.async {
            guard let doodleViewController = self.doodleViewController else { return }

            if doodleViewController.isViewLoaded  {
                self.customPhotoManager.setAssets()
                self.collectionView.reloadData()
                return
            }
            
            let authAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let getAuthAction = UIAlertAction(title: actionTitle, style: .default, handler: !settingActionHandler ? nil : { (UIAlertAction) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })

            authAlert.addAction(getAuthAction)

            self.present(authAlert, animated: true, completion: {
                self.customPhotoManager.setAssets()
                self.collectionView.reloadData()
            })
        }
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.customPhotoManager.getAssetCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.delegate = self
        if let imageData: Data = self.customPhotoManager.requestImageData(index: indexPath.row){
            cell.imageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if self.collectionView.allowsMultipleSelection {
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { return false }
            if !cell.isSelected {
                cell.isSelected = true
                cell.layer.borderWidth = 4
                cell.layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 10)
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if self.collectionView.allowsMultipleSelection {
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { return false }
            if cell.isSelected {
                cell.isSelected = false
                cell.layer.borderWidth = 0
                cell.layer.borderColor = .none
            }
        }
        return true
    }
        
}


extension ViewController: CustomCollectionViewCellDelegate {
    
    func determiningButtonValidationReqeusted() {
        if self.collectionView.indexPathsForSelectedItems?.count ?? 0 > 0 {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }
    
}

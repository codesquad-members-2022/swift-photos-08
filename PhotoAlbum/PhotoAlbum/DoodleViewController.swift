import UIKit

class DoodleViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var customImageDownloadManager: CustomImageDownloadManager = CustomImageDownloadManager()
    private var downloadedImage: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .darkGray
        self.navigationItem.title = "Doodle"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissView))
        
        DispatchQueue.main.async {
            DispatchQueue.global().sync {
                self.customImageDownloadManager.parsingDoodleData()
                self.downloadedImage = self.customImageDownloadManager.imageData.map { UIImage(data: $0) ?? UIImage() }
            }
            
            self.collectionView.register(CustomDoodleCollectionViewCell.self, forCellWithReuseIdentifier: "CustomDoodleCollectionViewCell")
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
        
    }
    
    @objc func dismissView() {
        self.dismiss(animated: false)
    }
}

extension DoodleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomDoodleCollectionViewCell", for: indexPath) as! CustomDoodleCollectionViewCell
        cell.imageView.image = downloadedImage[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: 50)
    }
    
}

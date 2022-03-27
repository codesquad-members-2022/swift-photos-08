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
    
    @objc func dismissView() {
        self.dismiss(animated: false)
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: 50)
    }
    
}

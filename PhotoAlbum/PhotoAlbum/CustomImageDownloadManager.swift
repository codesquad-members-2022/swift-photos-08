import Foundation

class CustomImageDownloadManager {
    private (set) var imageData: [Data] = []

    func parsingDoodleData() {
        guard let fileLocation = Bundle.main.url(forResource: "doodle", withExtension: "json") else { return }
        
        do {
            let data = try Data(contentsOf: fileLocation)
            let doodleList = try JSONDecoder().decode([Doodle].self, from: data)
            convertDoodleToImage(doodleList)
        } catch {
            print(error)
        }
    }
    
    private func convertDoodleToImage(_ list: [Doodle]) {
        list.forEach {
            let url = URL(string: $0.image)!
            if let data = try? Data(contentsOf: url) {
                imageData.append(data)
            }
        }
    }
}

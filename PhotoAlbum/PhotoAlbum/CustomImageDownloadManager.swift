import Foundation
import OSLog

enum ImageDownloadingError: Error{
    case gettingJSONDataError
    case parsingJSONDataError
    case downloadingImageDataError
}

class CustomImageDownloadManager {
    
    private (set) var imageData: [Data] = []
    private var logger: Logger = Logger()
    
    func parseDoodleData(){
        guard let fileLocation = Bundle.main.url(forResource: "doodle", withExtension: "json") else { return }
        do{
            let data = try getJSONData(fileLocation: fileLocation)
            let doodleList = try decodeJSONData(data: data)
            try convertDoodleToImage(doodleList)
        }catch ImageDownloadingError.gettingJSONDataError{
            logger.error("JSONDataDownloadingException")
        }catch ImageDownloadingError.parsingJSONDataError{
            logger.error("JSONDataParsingException ")
        }catch ImageDownloadingError.downloadingImageDataError{
            logger.error("ImageDataDownloadingException")
        }catch{
            logger.error("UnDesignatedException : \(error.localizedDescription)")
        }
        
    }
    
    private func getJSONData(fileLocation: URL) throws -> Data{
        do{
            let data = try Data(contentsOf: fileLocation)
            return data
        }catch{
            throw ImageDownloadingError.gettingJSONDataError
        }
    }
    
    private func decodeJSONData(data: Data) throws -> [Doodle]{
        do{
            let doodleList = try JSONDecoder().decode([Doodle].self, from: data)
            return doodleList
        }catch{
            throw ImageDownloadingError.parsingJSONDataError
        }
    }
    
    private func convertDoodleToImage(_ list: [Doodle]) throws {
        try list.forEach {

            let url = URL(string: $0.image)!
            guard let data = try? Data(contentsOf: url) else { throw ImageDownloadingError.downloadingImageDataError }
            imageData.append(data)
        }
    }
}


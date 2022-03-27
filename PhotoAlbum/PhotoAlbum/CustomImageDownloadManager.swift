import Foundation
import OSLog

enum ImageDownloadingError: Error{
    case gettingJSONDataError
    case parsingJSONDataError
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
        list.forEach {
            let url = URL(string: $0.image)!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            DispatchQueue.main.async {
                self.sendURLRequest(urlRequest: urlRequest)
            }
        }
    }
    
    private func sendURLRequest(urlRequest: URLRequest){
        URLSession.shared.dataTask(with: urlRequest){ data, response, error in
            guard error == nil else {
                self.logger.error("\(error.debugDescription)")
                return
            }
            guard let data = data else {
                self.logger.error("data not received")
                return
            }
            guard let response = response as? HTTPURLResponse else {
                self.logger.error("http response not received")
                return
            }
            
            if(response.statusCode >= 400){
                self.logger.debug("detected response with 404 status \nurl : \(urlRequest)")
            }else{
                self.imageData.append(data)
            }
        }.resume()
    }
}


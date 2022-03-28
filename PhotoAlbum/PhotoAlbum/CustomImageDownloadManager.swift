import Foundation
import OSLog

enum ImageDownloadingError: Error{
    case gettingJSONDataError
    case parsingJSONDataError
}

class CustomImageDownloadManager {
    
    private var imageData: [Data] = []
    var imageCount: Int{
        return imageData.count
    }
    private var completion: ()->Void = {}
    private var logger: Logger = Logger()
    private var responseCount: Int = 0
    
    func getImageData(index: Int)-> Data{
        return self.imageData[index]
    }
    
    func parseDoodleData(_ completion: @escaping ()->Void){
        guard let fileLocation = Bundle.main.url(forResource: "doodle", withExtension: "json") else { return }
        do{
            let data = try getJSONData(fileLocation: fileLocation)
            let doodleList = try decodeJSONData(data: data)
            try convertDoodleToImage(doodleList)
            self.completion = completion
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
        for index in 0..<list.count{
            let url = URL(string: list[index].image)!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            self.sendURLRequest(urlRequest: urlRequest, requestCount: list.count)
        }
    }
    
    private func sendURLRequest(urlRequest: URLRequest, requestCount: Int){
        URLSession.shared.dataTask(with: urlRequest){ data, response, error in
            self.responseCount += 1
            
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
            
            if (self.responseCount % 10 == 0) || (self.responseCount == requestCount) {
                self.completion()
            }
        }.resume()
    }
}


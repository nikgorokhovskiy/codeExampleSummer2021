
import Foundation

typealias JSONObject = [String: Any]

class APIManager {
    
    static let shared = { APIManager() }()
    
    static private var type: APIType = .development
    
    var baseURL: String = {
        switch type {
        case .development:
            return ""
        case .production:
            return ""
        }
    }()
    
}

extension APIManager {
    private enum APIType {
        case production
        case development
    }
}

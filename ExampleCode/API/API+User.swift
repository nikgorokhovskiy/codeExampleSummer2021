
import Foundation
import RxSwift
import RxAlamofire

protocol APIUserProtocol {
    func getProfile() -> Observable<JSONObject>
}

extension API {
    
    struct APIUser: APIUserProtocol {
        
        fileprivate enum Address: String, AddressType {
            case getOrUpdateProfile = ""
            case registerTokenFCM = ""
            
            var url: URL {
                return URL(string: APIManager.shared.baseURL.appending(rawValue))!
            }
        }
        
        func getProfile() -> Observable<JSONObject> {
            return API.request(Address.getOrUpdateProfile, method: .get)
        }
        
        func updateProfile(user: User) -> Observable<Void> {
            return API.request(Address.getOrUpdateProfile,
                               method: .patch,
                               parameters: [
                                "first_name" : user.firstName,
                                "last_name" : user.lastName,
                                "lang" : Locale.autoupdatingCurrent.languageCode ?? "ru"
                               ])
        }
        
        static func registerTokenFCM(token: String) -> Observable<Void> {
            return API.request(Address.registerTokenFCM,
                               method: .post,
                               parameters: [
                                "token" : token
                               ])
        }
    }
}

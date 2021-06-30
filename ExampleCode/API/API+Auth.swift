
import Foundation
import RxSwift
import RxAlamofire

protocol APIAuthProtocol {
    func authWithPhone(credentials: PhoneAuthCredentials) -> Observable<JSONObject>
}

extension API {
    
    struct Auth: APIAuthProtocol {
        
        fileprivate enum Address: String, AddressType {
            case firebaseSms = ""
            
            var url: URL {
                return URL(string: APIManager.shared.baseURL.appending(rawValue))!
            }
        }
        
        func authWithPhone(credentials: PhoneAuthCredentials) -> Observable<JSONObject> {
            return API.request(Address.firebaseSms,
                               method: .post,
                               parameters: [
                                "token" : credentials.token,
                                "phone" : credentials.phone
                               ])
        }
        
    }
}


import Foundation
import RxSwift
import Alamofire

struct API {
    
    // MARK: - API errors
    enum Errors: Error {
      case requestFailed
    }
    
    private enum Constants {
        static let headersJSON: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json"),
            HTTPHeader(name: "Accept", value: "application/json")
        ]
        static let headersHTTP: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/x-www-form-urlencoded"),
            HTTPHeader(name: "Accept", value: "application/json")
        ]
        static let headersMultipart: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "multipart/form-data"),
            HTTPHeader(name: "Accept", value: "application/json")
        ]
    }
    
    /// Handles request headers.
    private static func handle(headers: HTTPHeaders) -> HTTPHeaders {
        var handledHeaders = headers
        if let token = User.token {
            let authorization: HTTPHeader = HTTPHeader(name: "Authorization", value: "Token " + token)
            handledHeaders.add(authorization)
        }
        let locale: HTTPHeader = HTTPHeader(name: "Locale", value: Locale.current.identifier.components(separatedBy: "_").first ?? "en")
        handledHeaders.add(locale)
        return handledHeaders
    }
    
    static func request<T: Any>(_ address: AddressType, method: HTTPMethod, parameters: [String: Any] = [:]) -> Observable<T> {
        return Observable.create { observer in
            
            let encodingParameter: ParameterEncoding = method == .get ? URLEncoding.queryString : JSONEncoding.default
            
            let request = AF
                .request(address.url,
                                     method: method,
                                     parameters: parameters,
                                     encoding: encodingParameter,
                                     headers: handle(headers: Constants.headersJSON))
                .validate(statusCode: 200..<300)
            
            
            request.responseJSON { response in
                
                var errorHandler: ErrorHandler?
                if let error = ErrorHandler.error(response) {
                    errorHandler = error
                } else if let error = response.error {
                    errorHandler = ErrorHandler(error)
                }
                
                if let error = errorHandler, let statusCode = response.response?.statusCode, (statusCode < 200 || statusCode > 299) {
                    
                    if error.isCancelled { return }
                    
                    if error.isNotAuthorized {
                        User.token = nil
                        User.current = nil
                        let authViewModel = AuthViewModel(coordinator: SceneCoordinator.shared!)
                        let authScene = Scene.auth(authViewModel)
                        SceneCoordinator.shared?.transition(to: authScene, type: .root)
                        return
                    }
                    
                    observer.onError(error)
                    return
                }
                
                guard response.error == nil, let data = response.data,
                  let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? T) as T??), let result = json else {
                    observer.onCompleted()
                  return
                }
                
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

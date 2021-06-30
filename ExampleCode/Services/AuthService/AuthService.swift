

import Foundation
import RxSwift
import FirebaseAuth

/// Phone number wihout "+"
typealias PhoneAuthCredentials = (token: String, phone: String)
typealias Token = String

enum AuthError: Error {
    case signWithPhoneFailed
    case incorrectPhoneNumber
    case incorrectSmsCode
    case tokenError
}

class AuthService: NSObject, AuthServiceType {
    
    // MARK: - Private properties
    
    private static var verificationId: String?
    let authApi = API.Auth()
    
    // MARK: - Public methods
    
    func verifyPhoneNumber(phoneNumber: String) -> Observable<String> {
        return Observable.create { observer in
            if phoneNumber != "" {
                observer.onNext(phoneNumber)
                observer.onCompleted()
            } else {
                observer.onError(AuthError.incorrectPhoneNumber)
            }
            return Disposables.create()
        }
    }
    
    func sendSmsTo(phoneNumber: String) -> Observable<String> {
        return Observable.create { observer in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
                if error != nil {
                    observer.onError(error ?? AuthError.signWithPhoneFailed)
                } else if let verificationId = verificationId {
                    Auth.auth().languageCode = Locale.autoupdatingCurrent.languageCode
                    AuthService.verificationId = verificationId
                    observer.onNext(phoneNumber)
                    observer.onCompleted()
                } else {
                    observer.onError(AuthError.signWithPhoneFailed)
                }
            }
            return Disposables.create()
        }
    }
    
    func checkCodeAndGetToken(code: String, phoneNumber: String) -> Observable<PhoneAuthCredentials> {
        return Observable.create { observer in
            guard let verificationId = AuthService.verificationId else {
                fatalError("Could not find verificationId")
            }
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
            Auth.auth().signIn(with: credential) { _, error in
                if error != nil {
                    observer.onError(error ?? AuthError.incorrectSmsCode)
                } else {
                    let currentFirebaseUser = Auth.auth().currentUser
                    currentFirebaseUser?.getIDTokenForcingRefresh(true, completion: { idToken, error in
                        if error != nil, idToken != nil {
                            observer.onError(error ?? AuthError.incorrectSmsCode)
                        } else {
                            var phone = phoneNumber
                            if phoneNumber.first == "+" {
                                phone.removeFirst()
                            }
                            observer.onNext(PhoneAuthCredentials(token: idToken!, phone: phone))
                            observer.onCompleted()
                        }
                    })
                }
            }
            return Disposables.create()
        }
    }
    
    func authWithPhone(_ credentials: PhoneAuthCredentials) -> Observable<Token> {
        return authApi.authWithPhone(credentials: credentials)
            .flatMapLatest { json -> Observable<Token> in
                return Observable.create { observer in
                    if let token = json["token"] as? Token {
                        User.token = token
                        // Notification send device token to server
                        observer.onNext(token)
                        observer.onCompleted()
                    } else {
                        observer.onError(AuthError.tokenError)
                    }
                    return Disposables.create()
                }
            }
    }
    
}

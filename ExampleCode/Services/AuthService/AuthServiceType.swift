
import Foundation
import RxSwift

protocol AuthServiceType {
    func verifyPhoneNumber(phoneNumber: String) -> Observable<String>
    func sendSmsTo(phoneNumber: String) -> Observable<String>
    func checkCodeAndGetToken(code: String, phoneNumber: String) -> Observable<PhoneAuthCredentials>
    func authWithPhone(_ credentials: PhoneAuthCredentials) -> Observable<Token>
}


import Foundation
import RxSwift
import RxCocoa
import RxRelay
import Action

struct SmsCodeCheckViewModel {
    
    enum ViewState {
        case waitCode
        case checkCode
        case errorCode
        case authorized
    }
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let sceneCoordinator: SceneCoordinator
    private let authService: AuthService
    private let userService: UserService
    private let phoneNumber: String
    
    // MARK: - Input
    
    let code = BehaviorRelay<String>(value: "")
    
    func onResend() -> CocoaAction {
        return CocoaAction {
            state.onNext(.waitCode)
            return Observable.empty()
        }
    }
    
    // MARK: - Output
    
    let user = BehaviorRelay<User?>(value: nil)
    
    let state = BehaviorSubject<ViewState>(value: .waitCode)
    let timeToResent = BehaviorRelay<String>(value: "")
    let resendButtonIsEnabled = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Init
    
    init(coordinator: SceneCoordinator,
         authService: AuthService,
         userService: UserService,
         phoneNumber: String) {
        self.sceneCoordinator = coordinator
        self.authService = authService
        self.userService = userService
        self.phoneNumber = phoneNumber
        
        bindOutput()
    }
    
    // MARK: - Private methods
    
    private func bindOutput() {
      
        code
            .skip(while: { $0 == "" })
            .asObservable()
            .bind(onNext: chekCodeSession(code:))
            .disposed(by: disposeBag)
            
        state
            .subscribe(onNext: { $0 == .waitCode ? startTimer() : nil })
            .disposed(by: disposeBag)
    }
    
    private func startTimer() {
        
        let timeLeftSubj = BehaviorSubject<Int>(value: 10)
        
        Observable<Int>
            .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { seconds in
                if let value = try? timeLeftSubj.value() {
                    value != 0 ? timeLeftSubj.onNext(value - 1) : timeLeftSubj.onCompleted()
                }
            })
            .disposed(by: disposeBag)
        
        timeLeftSubj
            .asObservable()
            .subscribe(onNext: { $0 == 0 ? resendButtonIsEnabled.onNext(true) : resendButtonIsEnabled.onNext(false) })
            .disposed(by: disposeBag)
            
        timeLeftSubj
            .asObservable()
            .map { seconds in
                if seconds == 0 {
                    return R.string.localizable.resendCode()
                }
                return String(format: "(%02d:%02d)", ((seconds / 60) % 60),  seconds % 60)
            }
            .bind(to: timeToResent)
            .disposed(by: disposeBag)
    }
    
    func chekCodeSession(code: String) {
        state.onNext(.checkCode)
        Observable<String>.of(code)
            .flatMapLatest({ self.authService.checkCodeAndGetToken(code: $0, phoneNumber: self.phoneNumber) })
            .flatMapLatest({ self.authService.authWithPhone($0) })
            .flatMapLatest({ _ in self.userService.getUser() })
            .asSingle()
            .subscribe { user in
                self.state.onNext(.authorized)
                self.userService.saveUser(user: user)
                self.user.accept(user)
            } onFailure: { error in
                state.onNext(.errorCode)
                Alert.showError("Ошибочка при попытки проверить код и авторизрваться. Пожалуйста укажите код из SMS, если SMS не приходит проверьте правильность введенного номера телефона")
            }
            .disposed(by: disposeBag)
    }
    
}

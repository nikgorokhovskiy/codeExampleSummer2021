
import Foundation
import RxSwift
import RxCocoa
import RxRelay
import Action

struct AuthViewModel {
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let sceneCoordinator: SceneCoordinator
    private let authService: AuthService
    private let userService: UserService
    
    // MARK: - Intput
    
    private(set) var buttonTrigger = PublishSubject<Void>()
    private(set) var phoneNumberTextFieldText = PublishSubject<String>()
    
    func onRegister() -> CocoaAction {
        return CocoaAction {
            return self.hideWelcomeView()
        }
    }
    
    func onGoToAppStore() -> CocoaAction {
        return CocoaAction {
            // Mock data
            return Observable.empty()
        }
    }
    
    // MARK: - Output
    
    private(set) var welcomeViewIsHidden = BehaviorSubject<Bool>(value: false)
    private(set) var welcomeViewUIIsHidden = BehaviorSubject<Bool>(value: true)
    private(set) var needShowActivity = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Init
    
    init(coordinator: SceneCoordinator) {
        self.sceneCoordinator = coordinator
        self.authService = AuthService()
        self.userService = UserService()
        self.bindOutputs()
    }
    
    // MARK: - Private methods
    
    private func bindOutputs() {
        
        // mock observable
        Observable<Int>
            .interval(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { _ in
                self.checkUserAuthorizationAndFilledName(user: User.current)
            })
            .disposed(by: disposeBag)
        
        buttonTrigger.withLatestFrom(phoneNumberTextFieldText)
            .bind(onNext: phoneAuthSession(phoneNumber:))
            .disposed(by: disposeBag)
    }
    
    private func hideWelcomeView() -> Observable<Void> {
        welcomeViewIsHidden.onNext(true)
        return Observable.empty()
    }
    
    private func phoneAuthSession(phoneNumber: String) {
        self.needShowActivity.onNext(true)
        Observable<String>.of(phoneNumber)
            .flatMapLatest({ self.authService.verifyPhoneNumber(phoneNumber: $0) })
            .flatMapLatest({ self.authService.sendSmsTo(phoneNumber: $0) })
            .asSingle()
            .subscribe(
                onSuccess: self.toSmsCodeCheckScreen(with:),
                onFailure: self.showError(error:)
            )
            .disposed(by: disposeBag)
    }
    
    private func toSmsCodeCheckScreen(with phoneNumber: String) {
        self.needShowActivity.onNext(false)
        let viewModel = SmsCodeCheckViewModel(coordinator: self.sceneCoordinator, authService: self.authService, userService: self.userService, phoneNumber: phoneNumber)
        let smsCodeCheckScene = Scene.checkCode(viewModel)
        
        viewModel.user
            .asObservable()
            .filter({ $0 != nil })
            .take(1)
            .subscribe(onNext: { user in
                sceneCoordinator.pop(animated: true)
                    .subscribe({ _ in
                        self.checkUserAuthorizationAndFilledName(user: user)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        self.sceneCoordinator.transition(to: smsCodeCheckScene, type: .modal)
    }
    
    private func checkUserAuthorizationAndFilledName(user: User?) {
        guard User.isAuthorized, let user = user else {
            welcomeViewUIIsHidden.onNext(false)
            return
        }
        if user.firstName == "" {
            self.addUserName(user: user)
        } else {
            self.logIn()
        }
    }
    
    private func addUserName(user: User) {
        let viewModel = EnterNameViewModel(coordinator: sceneCoordinator, userService: userService, user: user)
        let scene = Scene.enterName(viewModel)
        sceneCoordinator.transition(to: scene, type: .modal)
    }
    
    private func logIn() {
        let primaryViewModel = PrimaryViewModel(coordinator: self.sceneCoordinator)
        let scene = Scene.primary(primaryViewModel)
        self.sceneCoordinator.transition(to: scene, type: .root)
    }
    
    private func showError(error: Error) {
        self.needShowActivity.onNext(false)
        if let error = error as? AuthError {
            switch error {
            case .incorrectPhoneNumber:
                print("incorrect phone number")
            case .signWithPhoneFailed:
                print("auth failed")
            default:
                print("unknown error")
            }
        } else {
            print(error.localizedDescription)
        }
    }
}

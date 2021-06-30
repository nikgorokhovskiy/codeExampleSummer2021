
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

class AuthViewController: UIViewController, BindableType {
    
    // MARK: - ViewModel
    var viewModel: AuthViewModel!
    
    // MARK: - Private properties
    
    private var numberTextField: UITextField!
    private var socialSignView: SocialSignView!
    private var welcomeView: WelcomeView!
    private var signInWithPhoneButton: UIButton!
    
    // MARK: - Override methods/Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addWelcomeView()
    }
    
    func bindViewModel() {
        
        viewModel.welcomeViewIsHidden
            .bind(to: welcomeView.rx.isHidden)
            .disposed(by: self.rx.disposeBag)
        
        viewModel.welcomeViewUIIsHidden
            .skip(1)
            .subscribe(onNext: { [weak self] result in
                self?.setWelcomeViewUIAlfa(to: !result)
            })
            .disposed(by: self.rx.disposeBag)
        
        viewModel.welcomeViewIsHidden
            .bind(to: welcomeView.rx.isHidden)
            .disposed(by: self.rx.disposeBag)
        
        welcomeView.registerButton.rx.action = viewModel.onRegister()
        
        welcomeView.appStoreButton.rx.action = viewModel.onGoToAppStore()
        
        numberTextField.rx.text.orEmpty
            .bind(to: viewModel.phoneNumberTextFieldText)
            .disposed(by: self.rx.disposeBag)
        
        signInWithPhoneButton.rx.tap
            .bind(to: viewModel.buttonTrigger)
            .disposed(by: self.rx.disposeBag)
        
        viewModel.needShowActivity
            .bind(onNext: { [weak self] in $0 ? self?.view.showActivity() : self?.view.hideActivity() })
            .disposed(by: self.rx.disposeBag)
            
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        
        view.theme.backgroundColor = themed({ $0.backgroundColor })
        
        // *** Create inputFieldStack ***
        
        let inputNumberStackView = UIStackView()
        inputNumberStackView.axis = .vertical
        inputNumberStackView.alignment = .fill
        inputNumberStackView.distribution = .fillProportionally
        inputNumberStackView.spacing = 20
        
        view.addSubview(inputNumberStackView)
        
        // *** Create typingYourNumber label ***
        
        let enterNumberLabel = UILabel()
        enterNumberLabel.text = R.string.localizable.enterPhoneNumber()
        enterNumberLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        enterNumberLabel.theme.textColor = themed({ $0.textColor })
        
        inputNumberStackView.addArrangedSubview(enterNumberLabel)
        
        // *** Create numberTextFiel ***
        
        numberTextField = UITextField()
        numberTextField.placeholder = " +7 000-000-00-00"
        numberTextField.borderStyle = .none
        numberTextField.layer.cornerRadius = 9
        numberTextField.theme.backgroundColor = themed({ $0.textFieldBackground })
        
        inputNumberStackView.addArrangedSubview(numberTextField)
        
        // *** Create sendCodeButton ***
        
        signInWithPhoneButton = UIButton()
        signInWithPhoneButton.layer.cornerRadius = 48 / 2
        signInWithPhoneButton.theme.backgroundColor = themed({ $0.mainButtonsColor })
        signInWithPhoneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        signInWithPhoneButton.setTitle(R.string.localizable.signPhoneButton(), for: .normal)
        
        view.addSubview(signInWithPhoneButton)
        
        // *** Create Social sign view Container ***
        
        socialSignView = SocialSignView()
        view.addSubview(socialSignView)
        socialSignView.setupView()
        
        // *** Create privacyPolicyDescriptionTextView ***
        
        let privacyPolicyDescriptionTextView = UITextView()
        privacyPolicyDescriptionTextView.text = R.string.localizable.privacyPolicyDescription()
        privacyPolicyDescriptionTextView.isScrollEnabled = false
        privacyPolicyDescriptionTextView.theme.textColor = themed({ $0.textLight })
        
        view.addSubview(privacyPolicyDescriptionTextView)
        
        // *** Autolayout ***
        
        inputNumberStackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.height.greaterThanOrEqualTo(40)
            maker.bottom.equalTo(view.snp.centerY)
        }
        
        numberTextField.snp.makeConstraints { maker in
            maker.height.equalTo(48)
        }
        
        socialSignView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
        
        signInWithPhoneButton.snp.makeConstraints { maker in
            maker.top.equalTo(inputNumberStackView.snp.bottom).offset(20)
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.height.equalTo(48)
        }
        
        privacyPolicyDescriptionTextView.snp.makeConstraints { maker in
            maker.top.equalTo(socialSignView.snp.bottom).offset(29)
            maker.bottom.equalToSuperview().offset(-55)
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.height.greaterThanOrEqualTo(40)
        }
        
        welcomeView = WelcomeView(frame: self.view.frame)
    }
    
    private func addWelcomeView() {
        self.welcomeView.titleLabel.alpha = 0
        self.welcomeView.subtitleLabel.alpha = 0
        self.welcomeView.appStoreButton.alpha = 0
        self.welcomeView.registerButton.alpha = 0
        self.welcomeView.registerButton.isEnabled = false
        self.welcomeView.appStoreButton.isEnabled = false
        view.addSubview(welcomeView)
    }
    
    private func setWelcomeViewUIAlfa(to result: Bool) {
        let value: CGFloat = result ? 1 : 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.welcomeView.titleLabel.alpha = value
            self?.welcomeView.subtitleLabel.alpha = value
            self?.welcomeView.appStoreButton.alpha = value
            self?.welcomeView.registerButton.alpha = value
        } completion: { [weak self] _ in
            self?.welcomeView.registerButton.isEnabled = result
            self?.welcomeView.appStoreButton.isEnabled = result
        }
    }
}

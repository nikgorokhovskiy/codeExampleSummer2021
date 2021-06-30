
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxKeyboard
import KAPinField

class SmsCodeCheckViewController: UIViewController, BindableType {
    
    // MARK: - Override properties
    
    override var isFirstResponder: Bool {
        codeTextField.becomeFirstResponder()
    }
    
    // MARK: - ViewModel/Public properties
    
    var viewModel: SmsCodeCheckViewModel!
    
    var codeTextField: KAPinField!
    var resendCodeButton: UIButton!
    
    // MARK: - Override methods/Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] visibleHeight in
                self?.resendCodeButton.snp.remakeConstraints({ maker in
                    maker.bottom.equalTo(-visibleHeight - 30)
                    maker.left.equalTo(16)
                    maker.right.equalTo(-16)
                    maker.height.equalTo(48)
                    maker.centerX.equalToSuperview()
                })
                self?.view.layoutIfNeeded()
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func bindViewModel() {
        
        codeTextField.rx.rx_pinField
            .do(onNext: { [weak self] _ in self?.codeTextField.text?.removeAll() })
            .bind(to: viewModel.code)
            .disposed(by: self.rx.disposeBag)
        
        viewModel.state
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] state in
                switch state {
                case .waitCode:
                    _ = self?.codeTextField.becomeFirstResponder()
                    self?.view.hideActivity()
                case .checkCode:
                    self?.view.endEditing(true)
                    self?.view.showActivity()
                case .errorCode, .authorized:
                    _ = self?.codeTextField.becomeFirstResponder()
                    self?.view.hideActivity()
                }
            })
            .disposed(by: self.rx.disposeBag)
        
        viewModel.timeToResent
            .bind(to: resendCodeButton.rx.title())
            .disposed(by: self.rx.disposeBag)
        
        viewModel.resendButtonIsEnabled
            .bind(to: resendCodeButton.rx.isEnabled)
            .disposed(by: self.rx.disposeBag)
        
        viewModel.resendButtonIsEnabled
            .bind(onNext: { [weak self] enable in
                self?.resendCodeButton.theme.backgroundColor = enable ? themed({ $0.mainButtonsColor }) : themed({ $0.additionalButtonsColor1 })
                self?.resendCodeButton.theme.titleColor(from: enable ? themed({ $0.whiteTextColor }) : themed({ $0.mainButtonsColor }), for: .normal)
            })
            .disposed(by: self.rx.disposeBag)
        
        resendCodeButton.rx.action = viewModel.onResend()
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        
        view.theme.backgroundColor = themed({ $0.backgroundColor })
        
        // *** Create container ***
        
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        container.alignment = .leading
        container.distribution = .fillProportionally
        
        view.addSubview(container)
        
        // *** Create code label ***
        
        let codeLabel = UILabel()
        codeLabel.text = R.string.localizable.enterSmsCode()
        codeLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        codeLabel.theme.textColor = themed({ $0.textColor })
        
        container.addArrangedSubview(codeLabel)
        
        // *** Create code textField ***
        
        codeTextField = KAPinField()
        codeTextField.textContentType = .oneTimeCode
        codeTextField.properties.numberOfCharacters = 6
        codeTextField.appearance.font = .none
        codeTextField.appearance.tokenColor = themeService.type.associatedObject.usersPinDefaultStateColor
        codeTextField.appearance.kerning = 30
        codeTextField.properties.animateFocus = false
        codeTextField.borderStyle = .none
        codeTextField.layer.cornerRadius = 9
        codeTextField.font = .systemFont(ofSize: 20, weight: .semibold)
        codeTextField.theme.backgroundColor = themed({ $0.textFieldBackground })
        codeTextField.keyboardType = .numberPad
        
        container.addArrangedSubview(codeTextField)
        
        // *** Create resendCode button ***
        
        resendCodeButton = UIButton()
        resendCodeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        resendCodeButton.layer.cornerRadius = 48 / 2
        
        view.addSubview(resendCodeButton)
        
        // *** Autolayout ***
        
        container.snp.makeConstraints { maker in
            maker.bottom.equalTo(view.snp.centerY)
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
        }
        
        codeTextField.snp.makeConstraints { maker in
            maker.width.equalTo(250)
            maker.height.equalTo(48)
        }
    }
    
    private func setPreventingCursore(on textField: UITextField) -> (_ newText: String) -> Void {
        return { newText in
            let cursorePosition = textField.offset(from: textField.beginningOfDocument, to: textField.selectedTextRange!.start) + newText.count - (textField.text?.count ?? 0)
            textField.text = newText
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorePosition) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }
}

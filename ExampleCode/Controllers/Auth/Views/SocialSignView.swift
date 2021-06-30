

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices

class SocialSignView: UIView {
    
    // MARK: - Public properties
    
    private(set) var signInWithVkButton: UIButton!
    
    // MARK: - Override methods/Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Public methods
    
    func setupView() {
        
        // *** Create orLabel ***
        
        let orLabel = UILabel()
        orLabel.text = R.string.localizable.or()
        orLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        orLabel.theme.textColor = themed({ $0.textColor })
        
        addSubview(orLabel)
        
        // *** Create social stackView ***
        
        let socialStackView = UIStackView()
        socialStackView.axis = .vertical
        socialStackView.distribution = .fillEqually
        socialStackView.spacing = 24
        
        addSubview(socialStackView)
        
        // *** Create VKButton ***
        
        signInWithVkButton = signInButton(title: R.string.localizable.signVK(), image: R.image.icSocialVKWhite())
        socialStackView.addArrangedSubview(signInWithVkButton)
        
        // *** Create SignInWithAppleButton ***
        
        if #available(iOS 13.0, *) {
            let button = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
            button.cornerRadius = 48 / 2
            button.constraints.forEach({ $0.isActive = false })
            socialStackView.addArrangedSubview(button)
        }
        
        // *** Autolayout ***
        
        orLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
        }
        
        socialStackView.snp.makeConstraints { maker in
            maker.top.equalTo(orLabel.snp.bottom).offset(38)
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.bottom.equalToSuperview()
        }
        
        signInWithVkButton.snp.makeConstraints { maker in
            maker.height.equalTo(48)
        }
        
    }
    
    private func signInButton(title: String, image: UIImage?) -> UIButton {
        
        // *** Create button ***
        
        let button = UIButton()
        button.layer.cornerRadius = 48 / 2
        button.theme.backgroundColor = themed({ $0.usersPinDefaultStateColor })
        
        // *** Create container ***
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 10
        
        button.addSubview(container)
        
        // *** Create image view ***
        
        let imageView = UIImageView()
        imageView.image = image
        
        container.addArrangedSubview(imageView)
        
        // *** Create label with title ***
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = title
        label.textColor = .white
        
        container.addArrangedSubview(label)
        
        // *** Autolayout ***
        
        imageView.snp.makeConstraints { maker in
            maker.height.width.equalTo(28)
        }
        
        container.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        
        return button
    }
}

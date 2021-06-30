
import UIKit

class WelcomeView: UIView {
    
    // MARK: - Public properties
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var appStoreButton: UIButton!
    var registerButton: UIButton!
    
    // MARK: - INIT
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties
    
    private func setupView() {
        
        theme.backgroundColor = themed({ $0.backgroundColor })
        
        titleLabel = UILabel()
        titleLabel.text = R.string.localizable.registerTitle()
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.theme.textColor = themed({ $0.textColor })
        addSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.text = R.string.localizable.registerSubtitle()
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.theme.textColor = themed({ $0.textLight })
        addSubview(subtitleLabel)
        
        appStoreButton = UIButton()
        appStoreButton.setTitle(R.string.localizable.appStoreButton(), for: .normal)
        appStoreButton.theme.titleColor(from: themed({ $0.usersPinDefaultStateColor }), for: .normal)
        appStoreButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(appStoreButton)
        
        registerButton = UIButton()
        registerButton.setTitle(R.string.localizable.registerButton(), for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.theme.backgroundColor = themed({ $0.mainButtonsColor })
        registerButton.layer.cornerRadius = 48 / 2
        addSubview(registerButton)
        
        let imageView = UIImageView()
        imageView.image = R.image.imageWelcome()
        addSubview(imageView)
        
        // *** Autolayout ***
        
        imageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(164)
            maker.width.equalTo(273)
        }
        
        subtitleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.bottom.equalTo(imageView.snp.top).offset(-57)
        }
        
        titleLabel.snp.makeConstraints { maker in
            maker.bottom.equalTo(subtitleLabel.snp.top).offset(-9)
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
        }
        
        registerButton.snp.makeConstraints { maker in
            maker.bottom.equalTo(-38)
            maker.width.equalTo(self.frame.width - 30)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(48)
        }
        
        appStoreButton.snp.makeConstraints { maker in
            maker.bottom.equalTo(registerButton.snp.top).offset(-18)
            maker.width.equalTo(self.frame.width - 30)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(48)
        }
        
    }
}

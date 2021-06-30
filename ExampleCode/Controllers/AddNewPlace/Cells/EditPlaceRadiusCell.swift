

import UIKit
import RxSwift
import Action

class EditPlaceRadiusCell: UITableViewCell {
    
    // MARK: - Public properties
    
    static let reuseIdentifier = "cell.EditPlaceRadiusCell"
    private(set) var minRadiusLabel: UILabel!
    private(set) var maxRadiusLabel: UILabel!
    private(set) var slider: UISlider!
    private(set) var createButton: UIButton!
    
    // MARK: - Private properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - INIT
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        createButton.rx.action = nil
        super.prepareForReuse()
    }
    
    // MARK: - Public methods
    
    func configure(cellModel: EditPlaceRadiusCellModel, createButtonAction: CocoaAction? = nil) {
        
        // TESTS BINDINGS BELOW
        createButton.theme.backgroundColor = themed({ $0.additionalButtonsColor1 })
        createButton.theme.titleColor(from: themed({ $0.textPurple }), for: .normal)
        
        createButton.rx.action = createButtonAction
        
        slider.rx.value
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        
        // *** Setup self ***
        
        self.selectionStyle = .none
        self.theme.backgroundColor = themed({ $0.backgroundColor })
        
        // *** Create container ***
        
        let container = UIView()
        container.backgroundColor = .clear
        self.contentView.addSubview(container)
        
        // *** Create and setup stackView ***
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        container.addSubview(stackView)
        
        // *** Create and setup minRadiusLabel ***
        
        self.minRadiusLabel = UILabel()
        self.minRadiusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        self.minRadiusLabel.theme.textColor = themed({ $0.textBlue })
        self.minRadiusLabel.textAlignment = .left
        self.minRadiusLabel.text = R.string.localizable.minRadiusLabel()
        stackView.addArrangedSubview(self.minRadiusLabel)
        
        // *** Create and setup maxRadiusLabel ***
        
        self.maxRadiusLabel = UILabel()
        self.maxRadiusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        self.maxRadiusLabel.theme.textColor = themed({ $0.textBlue })
        self.maxRadiusLabel.textAlignment = .right
        self.maxRadiusLabel.text = R.string.localizable.maxRadiusLabel()
        stackView.addArrangedSubview(self.maxRadiusLabel)
        
        // *** Create and setup slider ***
        
        self.slider = UISlider()
        self.slider.maximumValue = 1000
        self.slider.minimumValue = 10
        self.slider.theme.tintColor = themed({ $0.mainButtonsColor })
        self.slider.theme.thumbTintColor = themed({ $0.mainButtonsColor })
        self.slider.theme.maximumTrackTintColor = themed({ $0.additionalButtonsColor1 })
        container.addSubview(self.slider)
        
        // *** Create and setup createButton ***
        
        self.createButton = UIButton()
        self.createButton.setTitle(R.string.localizable.readyCreationNewPlaceButton(), for: .normal)
        self.createButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        self.createButton.theme.titleColor(from: themed({ $0.textLight }), for: .highlighted)
        self.createButton.layer.cornerRadius = 48 / 2
        container.addSubview(self.createButton)
        
        // *** Autolayout ***
        
        container.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.left.equalTo(17)
            maker.right.equalTo(-17)
            maker.top.equalTo(31.5)
        }

        self.slider.snp.makeConstraints { (maker) in
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.top.equalTo(stackView.snp.bottom).offset(13)
        }
        
        self.createButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.top.equalTo(self.slider.snp.bottom).offset(37)
            maker.bottom.equalToSuperview().offset(-5)
            maker.height.equalTo(48)
        }
    }
}

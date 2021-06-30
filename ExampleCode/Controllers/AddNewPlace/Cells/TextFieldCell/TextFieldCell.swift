
import UIKit
import RxSwift

class TextFieldCell: UITableViewCell {
    
    // MARK: - Public properties
    
    static let reuseIdentifier = "cell.TextFieldCell"
    private(set) var textField: UITextField!
    
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
        super.prepareForReuse()
    }
    
    // MARK: - Pubic methods
    
    func configure(cellModel: TextFieldCellModel) {
        self.textField.placeholder = cellModel.placeholder
        
        textField.rx.text.orEmpty
            .filter({ $0 != "" })
            .bind(to: cellModel.textFieldText)
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
        container.isUserInteractionEnabled = true
        addSubview(container)
        
        // *** Setup textField ***
        
        self.textField = UITextField()
        self.textField.font = .systemFont(ofSize: 18, weight: .medium)
        self.textField.theme.textColor = themed({ $0.textColor })
        self.textField.theme.backgroundColor = themed({ $0.backgroundColor })
        self.textField.borderStyle = .none
        self.textField.isUserInteractionEnabled = true
        container.addSubview(self.textField)
        
        // *** Create separator ***
        
        let separator = UIView()
        separator.theme.backgroundColor = themed({ $0.separatorColor })
        container.addSubview(separator)
        
        // *** Autolayout ***
        
        container.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
            maker.height.equalTo(60)
        }
        
        self.textField.snp.makeConstraints { maker in
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
            maker.top.equalTo(22)
        }
        
        separator.snp.makeConstraints { maker in
            maker.left.equalTo(16)
            maker.right.bottom.equalToSuperview()
            maker.height.equalTo(0.5)
        }
    }
    
}

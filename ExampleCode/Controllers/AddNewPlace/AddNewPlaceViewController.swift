
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action
import UltraDrawerView
import RxDataSources
import Differentiator
import RxKeyboard

class AddNewPlaceViewController: UIViewController, BindableType {
    
    // MARK: - ViewModel
    
    var viewModel: AddNewPlaceViewModel!
    
    // MARK: - Private properties
    
    private var drawerView: ExtensionedDrawerView!
    private var tableView: UITableView!
    private var headerView = HeaderViewForDrawerInModalController()
    private var middleView: UIView!
    private let nameOfPlaceTextField = UITextField()
    private let addressTextField = UITextField()
    private var dataSource: RxTableViewSectionedReloadDataSource<DataSourceSectionData>!
    
    private enum Layout {
        static let topInsetPortrait: CGFloat = 36
        static let topInsetLandscape: CGFloat = 20
        static let middleInsetFromBottom: CGFloat = 380
        static let headerHeight: CGFloat = 50
        static let cornerRadius: CGFloat = 25
        static let shadowRadius: CGFloat = 3
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize.zero
    }
    private var isFirstLayout: Bool = true
    
    // MARK: - Override methods/Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view = RootViewForModalViewController(frame: UIScreen.main.bounds)
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        
        setupMiddleView()
        setupView()
        setupDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
             isFirstLayout = false
            updateLayoutWithCurrentOrientation()
            drawerView.setState(UIDevice.current.orientation.isLandscape ? .top : .middle, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let prevState = drawerView.state
        updateLayoutWithCurrentOrientation()
        coordinator.animate { [weak self] context in
            let newState: DrawerView.State = (prevState == .bottom) ? .bottom : .top
            self?.drawerView.setState(newState, animated: context.isAnimated)
        }
    }
    
    func bindViewModel() {
        
        // *** Lifecycle bindings ***
        
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] _ in self?.viewModel.keyboardWillShow.accept(()) })
            .disposed(by: self.rx.disposeBag)
        
        viewModel.newDrawerState
            .skip(1)
            .bind(onNext: { [weak self] in self?.drawerView.setState($0, animated: true) })
            .disposed(by: self.rx.disposeBag)
        
        viewModel.keyboardNeedHide
            .bind(onNext: { [weak self] in self?.view.endEditing(true) })
            .disposed(by: self.rx.disposeBag)
        
        viewModel.tableViewContent
            .filter({ !$0.isEmpty })
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.rx.disposeBag)
        
        // *** Other bindings ***
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
                cell.textField.becomeFirstResponder()
            })
            .disposed(by: self.rx.disposeBag)
        
        drawerView.rx.willBeginUpdateOrigin
            .bind(onNext: { [weak self] parameters in
                if parameters.source != .program {
                    self?.viewModel.keyboardNeedHide.accept(())
                }
            })
            .disposed(by: self.rx.disposeBag)
        
        drawerView.rx.didChangeState
            .bind(onNext: { [weak self] state in
                if state == .dismissed {
                    _ = self?.viewModel.dismissAction.execute()
                }
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        
        // *** Create and setup header view ***
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { maker in
            maker.height.equalTo(Layout.headerHeight)
        }
        
        // *** Create and setup tableView ***
        
        self.tableView = UITableView()
        self.tableView.theme.backgroundColor = themed({ $0.backgroundColor })
        self.tableView.separatorStyle = .none
        self.tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        self.tableView.register(EditPlaceRadiusCell.self, forCellReuseIdentifier: EditPlaceRadiusCell.reuseIdentifier)
        
        // *** Setup drawerView ***
        
        self.drawerView = ExtensionedDrawerView(scrollView: tableView, delegate: nil, headerView: headerView)
        self.drawerView.middlePosition = .fromBottom(Layout.middleInsetFromBottom)
        self.drawerView.cornerRadius = Layout.cornerRadius
        self.drawerView.containerView.theme.backgroundColor = themed({ $0.backgroundColor })
        self.drawerView.layer.shadowRadius = Layout.shadowRadius
        self.drawerView.layer.shadowOpacity = Layout.shadowOpacity
        self.drawerView.layer.shadowOffset = Layout.shadowOffset
        self.drawerView.animationParameters = .spring(mass: 1, stiffness: 800, dampingRatio: 0.75)
        self.drawerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.drawerView)
        
    }
    
    private func setupDataSource() {
        
        self.dataSource = RxTableViewSectionedReloadDataSource<DataSourceSectionData>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .textFieldCell(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
                cell.configure(cellModel: model)
                return cell
            case .editPlaceRadusCell(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: EditPlaceRadiusCell.reuseIdentifier, for: indexPath) as! EditPlaceRadiusCell
                cell.configure(cellModel: model)
                return cell
            }
        })

    }
    
    private func setupMiddleView() {
        
        middleView = ContainerView(frame: view.frame)
        middleView.backgroundColor = .none
        view.addSubview(middleView)
    }
    
    private func updateLayoutWithCurrentOrientation() {
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            drawerView.snp.removeConstraints()
            drawerView.snp.remakeConstraints { maker in
                maker.top.equalTo(view.snp.top)
                if #available(iOS 11.0, *) {
                    maker.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(16)
                } else {
                    maker.left.equalTo(view.snp.left).offset(16)
                }
                maker.bottom.equalTo(view.snp.bottom)
                maker.width.equalTo(view.bounds.width)
            }
            drawerView.topPosition = .fromTop(Layout.topInsetLandscape)
            drawerView.availableStates = [.top, .bottom]
        } else {
            drawerView.snp.removeConstraints()
            drawerView.snp.remakeConstraints { maker in
                maker.top.equalTo(view.snp.top)
                maker.left.equalTo(view.snp.left)
                maker.bottom.equalTo(view.snp.bottom)
                maker.right.equalTo(view.snp.right)
            }
            drawerView.topPosition = .fromTop(Layout.topInsetPortrait)
            drawerView.availableStates = [.top, .middle, .dismissed]
        }
    }
}

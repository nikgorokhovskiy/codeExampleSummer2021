
import Foundation
import RxSwift
import RxRelay
import Action
import UltraDrawerView

struct AddNewPlaceViewModel {
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let regionService: RegionService
    private let sceneCoordinator: SceneCoordinatorType
    
    private let newPlace = PlaceItem()
    
    // MARK: - Inputs
    
    let dismissAction: CocoaAction
    let keyboardWillShow = PublishRelay<Void>()
    let drawerWillBiginUpdating = PublishRelay<Void>()
    let enteringAddress = PublishRelay<String>()
    
    // MARK: - Outputs
    
    let tableViewContent = BehaviorRelay<[DataSourceSectionData]>(value: [])
    let newDrawerState = BehaviorRelay<DrawerView.State>(value: .middle)
    let keyboardNeedHide = PublishRelay<Void>()
    
    // MARK: - INIT
    
    init(coordinator: SceneCoordinatorType, regionService: RegionService, dismissAction: CocoaAction) {
        self.sceneCoordinator = coordinator
        self.regionService = regionService
        self.dismissAction = dismissAction
        
        self.bindOutputs()
        self.createTableViewContentAndBindToNewPlaceModel()
    }
    
    // MARK: - Private methods
    
    private func bindOutputs() {
        
        self.keyboardWillShow
            .flatMapLatest({ _ -> Observable<DrawerView.State> in
                return Observable.just(.top)
            })
            .bind(to: newDrawerState)
            .disposed(by: self.disposeBag)
        
        self.drawerWillBiginUpdating
            .bind(to: self.keyboardNeedHide)
            .disposed(by: self.disposeBag)
        
    }
    
    private func createTableViewContentAndBindToNewPlaceModel() {
        
        // *** Create cell models ***
        
        let namePlaceCellModel = TextFieldCellModel(placeholder: R.string.localizable.placeNamePlaceholder())
        let addressCellModel = TextFieldCellModel(placeholder: R.string.localizable.addressPlaceholder())
        
        let editPlaceRadiusCellModel = EditPlaceRadiusCellModel()
        
        // *** Binding models ***
        
        namePlaceCellModel.textFieldText
            .subscribe(onNext: {
                self.newPlace.title = $0
            })
            .disposed(by: disposeBag)
        
        addressCellModel.textFieldText
            .bind(to: self.enteringAddress)
            .disposed(by: disposeBag)
        
        // *** Send to tableView ***
        
        tableViewContent.accept([
            DataSourceSectionData(items: [
                .textFieldCell(namePlaceCellModel),
                .textFieldCell(addressCellModel),
                .editPlaceRadusCell(editPlaceRadiusCellModel)
            ])
        ])
    }
}

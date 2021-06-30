
import Foundation
import RxSwift

struct TextFieldCellModel {
    
    var placeholder: String
    
    let textFieldText = BehaviorSubject<String>(value: "")
}


import Foundation
import RxDataSources

enum DataSourceCellType {
    case textFieldCell(TextFieldCellModel)
    case editPlaceRadusCell(EditPlaceRadiusCellModel)
}

struct DataSourceSectionData {
    var items: [DataSourceCellType]
}

extension DataSourceSectionData: SectionModelType {
    
    typealias Item = DataSourceCellType
    
    init(original: DataSourceSectionData, items: [DataSourceCellType]) {
        self = original
        self.items = items
    }
}

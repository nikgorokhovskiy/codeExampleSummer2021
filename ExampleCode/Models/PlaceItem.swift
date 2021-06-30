
import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm
import RxDataSources

class PlaceItem: Object, Mappable {
    
    @objc dynamic var uid: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var address: String = ""
    @objc dynamic var point: PointItem?
    @objc dynamic var distance: Int = 1000
    @objc dynamic var title: String = ""
    
    // MARK: - Mappable
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        if let _ = try? map.value("point") as PointItem {
            point <- map["point"]
        }
        
        id <- map["id"]
        address <- map["address"]
        distance <- map["distance"]
        title <- map["title"]
    }
    
    // MARK: - RxDataSource
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension PlaceItem: IdentifiableType {
    var identity: Int {
        return self.isInvalidated ? 0 : uid
    }
}

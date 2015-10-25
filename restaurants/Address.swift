import UIKit

class Address: NSObject {
   
    var address: String?
    var lat: Double?
    var lng: Double?
    var distance: Int?
    var postalCode: String?
    var city: String?
    var state: String?
    var addressDictionary: NSDictionary!
    init (dictionary: NSDictionary) {
        addressDictionary = dictionary
        address = dictionary["address"] as? String
        lat = dictionary["lat"] as? Double
        lng = dictionary["lng"] as? Double
        distance = dictionary["distance"] as? Int
        postalCode = dictionary["postalCode"] as? String
        city = dictionary["city"] as? String
        state = dictionary["state"] as? String
    }
    
    func getDistanceString() -> String {
        let distanceFloat = Float(distance!) * 0.000621371
        return String(format: "%.2f mi", distanceFloat)
    }
}

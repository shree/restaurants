import UIKit

class Venue: NSObject {
    
    static var priceStrings = ["$", "$$", "$$$", "$$$$"]
    var id: String!
    var name: String?
    var phone: String?
    var formattedPhone: String?
    var address: Address?
    var price: Int?
    var status: String?
    var rating: Double?
    var ratingCount: Int?
    var venueDictionary: NSDictionary!
    
    
    
    init (dictionary: NSDictionary) {
        venueDictionary = dictionary
        
        id = dictionary["id"] as! String
        name = dictionary["name"] as? String
        
        let contact = dictionary["contact"] as? NSDictionary
        if (contact != nil) {
            phone = contact!["phone"] as? String
            formattedPhone = contact!["formattedPhone"] as? String
        }
        
        
        let locationDictionary = dictionary["location"] as? NSDictionary
        if (locationDictionary != nil) {
            address = Address(dictionary: locationDictionary!)
        }
        
        let priceDictionary = dictionary["price"] as? NSDictionary
        if (priceDictionary != nil) {
            price = priceDictionary!["tier"] as? Int
        } else {
            price = 1
        }
        
        let hoursDictionary = dictionary["hours"] as? NSDictionary
        if (hoursDictionary != nil) {
            status = hoursDictionary!["status"] as? String
        }
        
        rating = dictionary["rating"] as? Double
        ratingCount = dictionary["ratingSignals"] as? Int
    }
    
    func getPriceString() -> String {
        return Venue.priceStrings[price! - 1]
    }
    
    func getRatingString() -> String {
        var ratingString = ""
        
        let ratingInt = Int(round(rating!))

        for index in 1...ratingInt {
            ratingString += "★"
        }
        
        return ratingString
    }
}

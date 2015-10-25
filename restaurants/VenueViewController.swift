import UIKit
import MapKit
import AddressBook
import MBProgressHUD
import FlatUIKit
import NZAlertView

class VenueViewController: UIViewController {
    
    @IBOutlet weak var titleRowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var ratingRowView: UIView!
    @IBOutlet weak var ratingDescLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var phoneRowView: UIView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneDescLabel: UILabel!
    
    @IBOutlet weak var priceRowView: UIView!
    @IBOutlet weak var priceDescLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var addressRowView: UIView!
    @IBOutlet weak var addressDescLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeMap: MKMapView!

    @IBOutlet weak var getDirectionsButton: FUIButton!

    var venue: Venue!

    override func viewDidLoad() {
        super.viewDidLoad()
        setPhoneNumber()
        setTitleAndStatus()
        setPrice()
        setRating()
        setAddress()
        setPlaceMap()
        setButtons()
    }
    
    func setPhoneNumber() {
        phoneLabel.text = venue.formattedPhone != nil ? venue.formattedPhone! : "Not Available"
        phoneRowView.backgroundColor = UIColor.concreteColor()
        phoneLabel.font = UIFont.flatFontOfSize(15)
        phoneDescLabel.font = UIFont.flatFontOfSize(15)
        phoneDescLabel.textColor = UIColor.whiteColor()
    }
    
    func setRating() {
        ratingRowView.backgroundColor = UIColor.alizarinColor()
        
        ratingDescLabel.text = "Based on \(venue.ratingCount!) reviews"
        ratingLabel.text = "\(venue.rating!)★"
        ratingLabel.font = UIFont.flatFontOfSize(15)
        ratingDescLabel.font = UIFont.flatFontOfSize(15)
        ratingDescLabel.textColor = UIColor.whiteColor()
    }
    
    func setTitleAndStatus() {
        titleRowView.backgroundColor = green
        titleLabel.text = venue.name?.uppercaseString
        statusLabel.text = venue.status != nil ? venue.status! : ""
        statusLabel.font = UIFont.flatFontOfSize(14)
        titleLabel.font = UIFont.boldFlatFontOfSize(20)
        titleLabel.numberOfLines = 0
    }
    
    func setPrice() {
        priceLabel.text = venue.getPriceString()
        priceRowView.backgroundColor = UIColor.peterRiverColor()
        priceLabel.font = UIFont.flatFontOfSize(15)
        priceDescLabel.font = UIFont.flatFontOfSize(15)
        priceDescLabel.textColor = UIColor.whiteColor()
    }
    
    func setAddress() {
        addressRowView.backgroundColor = UIColor.wetAsphaltColor()
        addressDescLabel.text = venue.address?.address!
        addressLabel.text = venue.address?.getDistanceString()
        addressLabel.font = UIFont.flatFontOfSize(15)
        addressDescLabel.font = UIFont.flatFontOfSize(15)
        addressDescLabel.textColor = UIColor.whiteColor()
    }
    
    func setPlaceMap() {
        let location = CLLocation(latitude: venue.address!.lat!, longitude: venue.address!.lng!)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        placeMap.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: venue.address!.lat!, longitude: venue.address!.lng!)
        annotation.coordinate = locationCoordinate
        annotation.title = venue.name!
        annotation.subtitle = venue.address?.address!
        placeMap.addAnnotation(annotation)
        placeMap.selectAnnotation(annotation, animated: true)
    }
    
    func setButtons() {
        getDirectionsButton.buttonColor = green
        getDirectionsButton.titleLabel?.font = UIFont.boldFlatFontOfSize(14)
        getDirectionsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        getDirectionsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        getDirectionsButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        getDirectionsButton.cornerRadius = 6.0
    }
//
    @IBAction func getDirectionsTapped(sender: AnyObject) {
        let addressDictionary = [String(kABPersonAddressStreetKey): venue.address!.address!]
        let locationCoordinate = CLLocationCoordinate2D(latitude: venue.address!.lat!, longitude: venue.address!.lng!)

        let placemark = MKPlacemark(coordinate: locationCoordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

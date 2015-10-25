import UIKit
import MapKit
import QuadratTouch
import MBProgressHUD
import FlatUIKit
import NZAlertView

let green = UIColor(red: 0.149, green: 0.651, blue: 0.357, alpha: 1)
let lightGreen = UIColor(red: 0.463, green: 1, blue: 0.012, alpha: 1)
class QuestionsViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let commutePreferenceKey = "isWalk"
    let pricePreferenceOne = "priceSelectedOne"
    let pricePreferenceTwo = "priceSelectedTwo"
    let pricePreferenceThree = "priceSelectedThree"
    let pricePreferenceFour = "priceSelectedFour"

    @IBOutlet weak var preferencesView: UIView!
    
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: FUIButton!
    @IBOutlet weak var commutePreferenceSegment: FUISegmentedControl!
    
    @IBOutlet weak var commuteLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var selectPreferencesLabel: UILabel!
//    
    @IBOutlet weak var buttonOne: FUIButton!
    @IBOutlet weak var buttonTwo: FUIButton!
    @IBOutlet weak var buttonThree: FUIButton!
    @IBOutlet weak var buttonFour: FUIButton!
//    @IBOutlet weak var priceSegment: UISegmentedControl!
    var session: Session!
    var venues: [Venue]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = Session.sharedSession()
        // Do any additional setup after loading the view.
        
//        preferencesView.layer.borderWidth = 1.25
        preferencesView.layer.borderColor = UIColor.grayColor().CGColor
//        preferencesView.layer.cornerRadius = 3
        
        commutePreferenceSegment.selectedFont = UIFont.boldFlatFontOfSize(16)
        commutePreferenceSegment.selectedFontColor = UIColor.whiteColor()
        commutePreferenceSegment.deselectedFont = UIFont.flatFontOfSize(16)
        commutePreferenceSegment.deselectedFontColor = UIColor.whiteColor()
        commutePreferenceSegment.selectedColor = UIColor.peterRiverColor()
        commutePreferenceSegment.deselectedColor = UIColor.silverColor()
        commutePreferenceSegment.cornerRadius = 5.0
        
        setPricingButtonStyle(buttonOne)
        setPricingButtonStyle(buttonTwo)
        setPricingButtonStyle(buttonThree)
        setPricingButtonStyle(buttonFour)
        
        selectButton(buttonOne)
        
        searchButton.buttonColor = green
        searchButton.titleLabel?.font = UIFont.boldFlatFontOfSize(17)
        searchButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        searchButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        locationManager.delegate = self
        let accuracy: CLLocationAccuracy = 50
        locationManager.desiredAccuracy = accuracy
        
//        titleLabel.font = UIFont.boldFlatFontOfSize(24)
        selectPreferencesLabel.font = UIFont.flatFontOfSize(18)
        selectPreferencesLabel.textColor = UIColor.blackColor()
        priceLabel.font = UIFont.flatFontOfSize(18)
        priceLabel.textColor = UIColor.blackColor()
        commuteLabel.textColor = UIColor.blackColor()
        commuteLabel.font = UIFont.flatFontOfSize(18)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        
        var isWalkDefaults = defaults.valueForKey(commutePreferenceKey) as? Bool
        var isWalk = true
        if (isWalkDefaults != nil) {
            isWalk = isWalkDefaults!
        }
        if (isWalk) {
            commutePreferenceSegment.selectedSegmentIndex = 0
        } else {
            commutePreferenceSegment.selectedSegmentIndex = 1
        }
        
        var ppOne = defaults.valueForKey(pricePreferenceOne) as? Bool
        var ppTwo = defaults.valueForKey(pricePreferenceTwo) as? Bool
        var ppThree = defaults.valueForKey(pricePreferenceThree) as? Bool
        var ppFour = defaults.valueForKey(pricePreferenceFour) as? Bool
        
        if (ppOne != nil) {
            setButtonSelected(ppOne!, button: buttonOne)
        }
        
        if (ppTwo != nil) {
            setButtonSelected(ppTwo!, button: buttonTwo)
        }
        
        if (ppThree != nil) {
            setButtonSelected(ppThree!, button: buttonThree)
        }
        
        if (ppFour != nil) {
            setButtonSelected(ppFour!, button: buttonFour)
        }

        
    }
    
    func setButtonSelected(selected: Bool, button: FUIButton) {
        if (selected) {
            selectButton(button)
        } else {
            unselectButton(button)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let defaults = NSUserDefaults.standardUserDefaults()
        var latitude = locationManager.location!.coordinate.latitude
        var longitude = locationManager.location!.coordinate.longitude
        
        var isWalk = false
        if(commutePreferenceSegment.selectedSegmentIndex == 0){
            isWalk = true
        }
        var priceSelected: [Int] = []
        
        if(buttonOne.selected){
            priceSelected.append(1)
        }
        if(buttonTwo.selected){
            priceSelected.append(2)
        }
        if(buttonThree.selected){
            priceSelected.append(3)
        }
        if(buttonFour.selected){
            priceSelected.append(4)
        }

        defaults.setObject(buttonOne.selected, forKey: pricePreferenceOne)
                defaults.synchronize()
        defaults.setObject(buttonTwo.selected, forKey: pricePreferenceTwo)
                defaults.synchronize()
        defaults.setObject(buttonThree.selected, forKey: pricePreferenceThree)
                defaults.synchronize()
        defaults.setObject(buttonFour.selected, forKey: pricePreferenceFour)
                defaults.synchronize()

    
        
        if (priceSelected.count == 0) {
                let alertController = UIAlertController(
                    title: "Missing Info",
                    message: "Please Select Price Range",
                    preferredStyle: .Alert)
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            stopLoading()
            return
        }
        
        search(isWalk, pricing: priceSelected, lat: latitude, lng: longitude)
        
        defaults.setObject(isWalk, forKey: commutePreferenceKey)
        defaults.synchronize()
    }
    
    
    func setPricingButtonStyle(button: FUIButton){
        button.buttonColor = UIColor.silverColor()
        button.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.boldFlatFontOfSize(16)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchSelected(sender: AnyObject) {
        startLoading()
        locationManager.startUpdatingLocation()
    }
    
    func intToStringArray(intArray: [Int]) -> String {
        var pricing = ""
        for price in intArray{
            pricing += "\(price),"
        }
        return (pricing as NSString).substringToIndex(pricing.characters.count-1)
    }
    
    func search(isWalk: Bool, pricing: [Int], lat: CLLocationDegrees, lng: CLLocationDegrees) {
        print("Latitude \(lat)")
        print("Longitude \(lng)")
        venues = []
        var parameters = [Parameter.ll: "\(lat),\(lng)"]
        if (isWalk) {
            parameters += [Parameter.radius: "250"]
        }
        parameters += [Parameter.section: "food"]
        var check = intToStringArray(pricing)
        parameters += [Parameter.price: check ]
        print(check)
//        parameters += [Parameter.price: "[\(pricing)]"]
        let searchTask = session.venues.explore(parameters) {
            (result) -> Void in
            if let response = result.response {
                print("got to response")
                if let groupsArray = response["groups"] as? [NSDictionary] {
                    if let itemsArray = groupsArray[0]["items"] as? [NSDictionary] {
                        for itemsDictionary in itemsArray {
                            if let venueDictionary = itemsDictionary["venue"] as? NSDictionary {
                                self.venues.append(Venue(dictionary: venueDictionary))
                            }
                        }
                    }
                }
            }
            self.stopLoading()
            if (self.venues.count > 0) {
                self.selectVenue(self.venues)
            }else{
                let alertController = UIAlertController(
                    title: "No Restaurants Nearby",
                    message: "Please select a location to drive to",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
        }
        searchTask.start()
    }
    
    func selectVenue(venues: [Venue]!) {
        // Get an array of last venueIDs from nsdefaults
        // Go through venues and if id is in there then choose next
        // Save chosen venue id into nsdefaults array
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var unVisitedVenues: [Venue] = []
        
        
        
        var venueIds: [String]! = []
        let defaultIds = defaults.stringArrayForKey("lastVenueIds")
        if (defaultIds != nil) {
            venueIds = defaultIds as! [String]?
        }
        
        for venue in venues{
            if (!venueIds.contains(venue.id)){
            unVisitedVenues.append(venue)
            }
        }
        
        if (unVisitedVenues.count == 0) {
            unVisitedVenues = venues
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(unVisitedVenues.count)))
        showSelectedVenue(unVisitedVenues[randomIndex], ids: venueIds)
    }
    
    func showSelectedVenue(venue: Venue, ids: [String]) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var venueIds = ids
        defaults.setObject(venue.venueDictionary, forKey: "lastVenue")
        let date = NSDate()
        defaults.setObject(date, forKey: "lastVenueTime")
        venueIds.append(venue.id)
        defaults.setObject(venueIds, forKey: "lastVenueIds")
        defaults.synchronize()
        showVenue(venue)
    }
    
    func startLoading() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func stopLoading() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func showVenue(venue: Venue) {
        performSegueWithIdentifier("venueSegue", sender: venue)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "venueSegue") {
            let venueViewController = segue.destinationViewController as! VenueViewController
            venueViewController.venue = sender as! Venue
        }
    }
    @IBAction func pricingAction(button: FUIButton) {
        if(button.selected){
            unselectButton(button)
    
        }else{
            selectButton(button)
        }
    }
    
    func selectButton (button: FUIButton){
        button.selected=true
        button.buttonColor = UIColor.peterRiverColor()
    }
    
    func unselectButton(button: FUIButton){
        button.selected = false
        button.buttonColor = UIColor.silverColor()
    }

}

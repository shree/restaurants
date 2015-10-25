
import UIKit
import MapKit
import QuadratTouch
import MBProgressHUD
import FlatUIKit
import NZAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let client = Client(clientID:       "BUCS1IGHSG0WATTFOH20CVENO3WFVYIZMKEL4X31S5BWKXL3",
            clientSecret:   "VICO4IQNQROWR0E4EQ4GB0TOOU4LAI2AG4VR5Z43F3T1OEJE",
            redirectURL:    "")
        var configuration = Configuration(client:client)
        configuration.shouldControllNetworkActivityIndicator = true
        Session.setupSharedSessionWithConfiguration(configuration)
        
        print(CLLocationManager.locationServicesEnabled())
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            var rootView = storyboard.instantiateViewControllerWithIdentifier("gpsView") as! GPSViewController
            self.window?.rootViewController = rootView
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let venueDictionary = defaults.dictionaryForKey("lastVenue");
        if(venueDictionary != nil){
        let venue = Venue(dictionary: venueDictionary!)
        let date = defaults.objectForKey("lastVenueTime") as! NSDate
        let dateDifference = NSDate().timeIntervalSinceDate(date)
        if (dateDifference < 60*1) {
            var venueView = storyboard.instantiateViewControllerWithIdentifier("venueView") as! VenueViewController
            venueView.venue = venue
            self.window?.rootViewController = venueView
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
            let rootView = storyboard.instantiateViewControllerWithIdentifier("gpsView") as! GPSViewController
            self.window?.rootViewController = rootView
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


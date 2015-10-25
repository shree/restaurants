import UIKit
import CoreLocation
import MBProgressHUD
import FlatUIKit
import NZAlertView

class GPSViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var enableGPSButton: FUIButton!
    @IBOutlet weak var enableGPSLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let newBlue = UIColor(red: 0, green: 176/255, blue: 1, alpha: 1)
        self.view.backgroundColor = green
        
        enableGPSButton.buttonColor = UIColor.whiteColor()
        enableGPSButton.cornerRadius = 8
        enableGPSButton.titleLabel?.font = UIFont.flatFontOfSize(16)
        enableGPSButton.setTitleColor(newBlue, forState: UIControlState.Normal)
        
        appNameLabel.textColor = UIColor.whiteColor()
        appNameLabel.text = "Avocado"
        appNameLabel.font = UIFont.boldFlatFontOfSize(24)
        
        
        enableGPSLabel.textColor = UIColor.whiteColor()
        enableGPSLabel.text = "We use your location to find restaurants near you. Please enable location services."
        enableGPSLabel.font = UIFont.flatFontOfSize(16)
        enableGPSLabel.numberOfLines = 10
        enableGPSLabel.sizeToFit()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enableGPS(sender: AnyObject) {
        
        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse:
            print("Authorized Already")
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to find a restaurant near you, please enable location services",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        default: return
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            performSegueWithIdentifier("gpsSeque", sender: nil)
        }
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

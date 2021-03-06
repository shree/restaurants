//
//  FirstViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import UIKit
import CoreLocation

import QuadratTouch

typealias JSONParameters = [String: AnyObject]

/** Shows result from `explore` endpoint. And has search controller to search in nearby venues. */
class ExploreViewController: UITableViewController, CLLocationManagerDelegate, SearchTableViewControllerDelegate, SessionAuthorizationDelegate {
    var searchController: UISearchController!
    var resultsTableViewController: SearchTableViewController!
    
    var session : Session!
    var locationManager : CLLocationManager!
    var venueItems : [[String: AnyObject]]?
    
    /** Number formatter for rating. */
    let numberFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .DecimalStyle
        
        session = Session.sharedSession()
        session.logger = ConsoleLogger()
        
        resultsTableViewController = Storyboard.create("venueSearch") as! SearchTableViewController
        resultsTableViewController.session = session
        resultsTableViewController.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController.searchResultsUpdater = resultsTableViewController
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
            || status == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            showNoPermissionsAlert()
        }
    }
    
    
    func showNoPermissionsAlert() {
        let alertController = UIAlertController(title: "No permission", message: "In order to work, app needs your location", preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(openSettings)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: NSError) {
        let alertController = UIAlertController(title: "Error", message:error.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            showNoPermissionsAlert()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // Process error.
        // kCLErrorDomain. Not localized.
        showErrorAlert(error)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if venueItems == nil {
            exploreVenues()
        }
        resultsTableViewController.location = newLocation
        locationManager.stopUpdatingLocation()
    }
    
    func exploreVenues() {

        let location = self.locationManager.location
        var parameters = location.parameters()
        let task = self.session.venues.explore(parameters) {
            (result) -> Void in
            if self.venueItems != nil {
                return
            }
            if !NSThread.isMainThread() {
                fatalError("!!!")
            }
            
            if result.response != nil {
                if let groups = result.response!["groups"] as? [[String: AnyObject]]  {
                    var venues = [[String: AnyObject]]()
                    for group in groups {
                        if let items = group["items"] as? [[String: AnyObject]] {
                            venues += items
                        }
                    }
                    
                    self.venueItems = venues
                }
                self.tableView.reloadData()
            } else if result.error != nil && !result.isCancelled() {
                self.showErrorAlert(result.error!)
            }
        }
        task.start()
    }

    @IBAction func authorizeButtonTapped() {
        session.authorizeWithViewController(self, delegate: self) {
            (authorized, error) -> Void in
            //
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if venueItems != nil {
            return venueItems!.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("venueCell", forIndexPath: indexPath) as! VenueTableViewCell
        let item = self.venueItems![indexPath.row] as JSONParameters!
        self.configureCellWithItem(cell, item: item)
        return cell
    }
    
    
    func configureCellWithItem(cell:VenueTableViewCell, item: JSONParameters) {
        let venueInfo = item["venue"] as? JSONParameters
        let tips = item["tips"] as? [JSONParameters]
        if venueInfo != nil {
            cell.venueNameLabel.text = venueInfo!["name"] as? String
            if let rating = venueInfo!["rating"] as? CGFloat {
                cell.venueRatingLabel.text = numberFormatter.stringFromNumber(rating)
            }
        }
        if tips != nil  {
            if let tip = tips!.first {
                cell.venueCommentLabel.text = tip["text"] as? String
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! VenueTableViewCell
        let tips = self.venueItems![indexPath.row]["tips"] as? [JSONParameters]
        if tips != nil  {
            if let tip = tips!.first {
                if let user = tip["user"] as? JSONParameters {
                    if let photo = user["photo"] as? JSONParameters  {
                        let URL = photoURLFromJSONObject(photo)
                        if let imageData = session.cachedImageDataForURL(URL)  {
                            cell.userPhotoImageView.image = UIImage(data: imageData)
                        } else {
                            cell.userPhotoImageView.image = nil
                            session.downloadImageAtURL(URL) {
                                (imageData, error) -> Void in
                                let cell = tableView.cellForRowAtIndexPath(indexPath) as? VenueTableViewCell
                                if cell != nil && imageData != nil {
                                    let image = UIImage(data: imageData!)
                                    cell!.userPhotoImageView.image = image
                                }
                            }
                            
                        }
                        
                    } // let photo
                    
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let venue = venueItems![indexPath.row]["venue"] as! JSONParameters
        openVenue(venue)
    }
    
    func searchTableViewController(controller: SearchTableViewController, didSelectVenue venue:JSONParameters) {
        openVenue(venue)
    }
    
    func openVenue(venue: JSONParameters) {
        let viewController = Storyboard.create("venueDetails") as! VenueTipsViewController
        viewController.venueId = venue["id"] as? String
        viewController.session = session
        viewController.title = venue["name"] as? String
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func photoURLFromJSONObject(photo: JSONParameters!) -> NSURL {
        let prefix = photo!["prefix"] as! String
        let suffix = photo!["suffix"] as! String
        let URLString = prefix + "100x100" + suffix
        let URL = NSURL(string: URLString)
        return URL!
    }
    
    func sessionWillPresentAuthorizationViewController(controller: AuthorizationViewController) {
        println("Will present authorization view controller.")
    }
    
    func sessionWillDismissAuthorizationViewController(controller: AuthorizationViewController) {
        println("Will disimiss authorization view controller.")
    }
}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}


class Storyboard: UIStoryboard {
    class func create(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name) as! UIViewController
    }
}


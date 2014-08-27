//
//  ViewController.swift
//  MapKitAppCoreData
//
//  Created by Jeff Gayle on 8/19/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreBluetooth

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latTextField: UITextField!
    
    @IBOutlet weak var longTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    var myContext : NSManagedObjectContext!
    var peripheralManager : CBPeripheralManager!
    
    var beaconRegion : CLBeaconRegion!
    var beaconData : NSDictionary!
    let uuID = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        println(CLLocationManager.authorizationStatus().toRaw())
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("Authorized")
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        case .AuthorizedWhenInUse:
            println("Authorized when in use")
            self.locationManager.startUpdatingLocation()
        case .NotDetermined:
            println("Not determined")
            self.locationManager.requestWhenInUseAuthorization()
        case .Restricted:
            println("Location services are restricted")
        case .Denied:
            println("Location services have been denied. Please go to settings to change this")
        }
        
        println(CLLocationManager.authorizationStatus().toRaw())
        
        var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
        self.mapView.addGestureRecognizer(longPress)
        self.mapView.delegate = self
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        //FIX: Change to elevator uuid
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuID, identifier: "org.codefellows.east_room")
        self.beaconData = self.beaconRegion.peripheralDataWithMeasuredPower(nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func mapPressed(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("Began")
            
            //Figuring out where they touched the map View
            var touchPoint = sender.locationInView(self.mapView)
            var touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            //Setting our pin
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add Reminder"
            self.mapView.addAnnotation(annotation)
            
        case .Changed:
            println("Changed")
        case .Ended:
            println("Ended")
            
            var touchPoint = sender.locationInView(self.mapView)
            var touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.myContext) as Reminder
            newReminder.lat = touchCoordinate.latitude
            newReminder.long = touchCoordinate.longitude
            newReminder.message = "Blank Message"
            println(newReminder.lat)
            println(newReminder.long)
            
            var error : NSError?
            self.myContext.save(&error)
            if error != nil {
                println(error?.localizedDescription)
            }
            self.performSegueWithIdentifier("showReminders", sender: self)
        default:
            println("default")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeLocationPressed(sender: AnyObject) {
        
        var latString = NSString(string: self.latTextField.text)
        var lat = latString.doubleValue
        
        var longString = NSString(string: self.longTextField.text)
        var long = longString.doubleValue
        
        var newLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        var region = MKCoordinateRegionMakeWithDistance(newLocation, 1000, 1000)
        
        self.mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func showRemindersPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("showReminders", sender: self)
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("User has authorized")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        case .Denied:
            println("User has denied access")
        case .AuthorizedWhenInUse:
            println("Authorized when in use Changed")
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        default:
            println("Auth has changed")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: MKMapView Delegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //First try to dequeue old annotation
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            self.configureAnnotation(annotationView)
            return annotationView
        } else {
            // If don't get one back, create a new one with identifier
            var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            self.configureAnnotation(annotationView)
            return annotationView
        }
    }
    
    //Configure Annotation Method
    func configureAnnotation(annotationView: MKPinAnnotationView) {
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        
        //Configure callout
        var rightButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView = rightButton
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        var annotation = view.annotation
        
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
        
    }
    
    //Listen for entering/leaving region
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered Region")
        
        var notification = UILocalNotification()
        notification.alertBody = "You entered the East Room!"
        notification.alertAction = "Click here!"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Exited Region")
        
        var notification = UILocalNotification()
        notification.alertBody = "You have exited the East Room!"
        notification.alertAction = "Click here!"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var state = peripheral.state
        switch state {
        case .PoweredOn:
            self.peripheralManager.startAdvertising(self.beaconData)
        case .PoweredOff:
            self.peripheralManager.stopAdvertising()
        default:
            println("Try again")
        }
    }
    
    
}


import UIKit
import FirebaseDatabase
import Firebase
import MapKit
import CoreLocation


class CustomAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var annotationImage: String?
    var projPhoto: UIImage?
    var posterPic: UIImage?
    var rating: Double
    var postingDetails : [String : String]
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.annotationImage = nil
        self.postingDetails = [:]
        self.rating = 0.0
    }
}


class CustomAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "HomePin.png")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "HomePin.png")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}



class MapsViewController: UIViewController, MapSettingDelegate{

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationServiceDidFailNotificationView: UIView!
    
    @IBOutlet weak var enableLocationServicesButton: UIButton!
    
    @IBOutlet weak var mapSettingButton: UIButton!
    
    @IBOutlet weak var mapSettingView: UIView!
    
    var locationManager : CLLocationManager?
    var postingReference : DatabaseReference?
    var maxTravelDistanceInMiles : Int = 25
    var isContractor = false
    var inRadiusProjects : [CustomAnnotation] = []
    var outsideRadiusProjects : [CustomAnnotation] = []
    var selectedAnnotation : [CustomAnnotation] = []
    
    @IBAction func mapSettingButtonPressed(_ sender: UIButton) {
        mapSettingView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()// This function will call didChangeAuthorization aync
        locationManager?.delegate = self
        mapView.delegate = self
        
        getUserType()
        /*
         let button = UIButton()
         button.frame = CGRect(0, 0, 51, 31) //won't work if you don't set frame
         button.setImage(UIImage(named: "MapSettingIcon"), for: .normal)
         button.addTarget(self, action: Selector("MapSettingButtonPressed"), for: .touchUpInside)
         
         let barButton = UIBarButtonItem()
         barButton.customView = button
         self.navigationItem.rightBarButtonItem = barButton
         */
    }
    
    //Its Called when user first authorizes location
    func setUpMap()
    {
        postingReference = Database.database().reference().child("projects")
        createGeoRegion()
        retrivePostingFromDatabase()
        monitorNewProjects()
    }
    
    //This is one time event which grabs all projects from the database. If the project is pending, the distance between project and current location will be calculated. Depending on the distance the annotation will be added to inRadius or outSideRadius project array.
    func retrivePostingFromDatabase()
    {
        
        //guard let currentLocation = self.locationManager?.location
        //  else{return}
        
        //Go thru all projects in the database(Not using geofire)
        postingReference?.observeSingleEvent(of: .value, with: { (snapshot) in
            for projectSnap in snapshot.children.allObjects as! [DataSnapshot]
            {
                let postingDetails = projectSnap.value as? [String: String]
                self.processProject(postingDetails: postingDetails!)
            }
        })
    }
    
    
    //Called from MapSettingViewController
    func updateMaxTravelDistanceIn(miles: Int) {
        mapSettingView.isHidden = true
        
        guard let currentLocation = self.locationManager?.location
            else{return}
        
        //User did not change the radius so no need to process
        if(maxTravelDistanceInMiles == miles)
        {return}
        
        //User has increased the radius so we need to process all project which were in outsideradius array
        if(miles > maxTravelDistanceInMiles)
        {
            maxTravelDistanceInMiles = miles
            processOutsideRadiusAnnotation(currentLocation: currentLocation)
        }
            //User has decreased the radius so process projects in inradius annotation
        else if(miles < maxTravelDistanceInMiles)
        {
            maxTravelDistanceInMiles = miles
            processInRadiusAnnotation(currentLocation: currentLocation)
        }
    }
    
    func processInRadiusAnnotation(currentLocation : CLLocation)
    {
        var track = 0
        
        //Process the active projects if they fall outside new radius
        for annotationInRadius in inRadiusProjects
        {
            let projectlocation = CLLocation.init(latitude: annotationInRadius.coordinate.latitude,
                                                  longitude: annotationInRadius.coordinate.longitude)
            
            let dist = (currentLocation.distance(from: projectlocation))/1609.34
            
            if (dist > Double(maxTravelDistanceInMiles))
            {
                inRadiusProjects.remove(at: track)
                outsideRadiusProjects.append(annotationInRadius)
                mapView.removeAnnotation(annotationInRadius)
                track -= 1
            }
            track += 1
        }
    }
    
    //Go thru all projects in outside radius range projects
    //If the project is in the range remove from the array and add it to inRadius projects array
    func processOutsideRadiusAnnotation(currentLocation : CLLocation)
    {
        var track = 0
        //Process the inactive projects if they belong to new radius
        for annotationOutside in outsideRadiusProjects
        {
            let projectlocation = CLLocation.init(latitude: annotationOutside.coordinate.latitude,
                                                  longitude: annotationOutside.coordinate.longitude)
            
            let dist = (currentLocation.distance(from: projectlocation))/1609.34
            
            if (dist <= Double(maxTravelDistanceInMiles))
            {
                inRadiusProjects.append(annotationOutside)
                outsideRadiusProjects.remove(at: track)
                mapView.addAnnotation(annotationOutside)
                track -= 1
            }
            
            track += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "mapToContainer" )
        {
            let dvc = segue.destination as! MapSettingViewController
            dvc.radiusInMile = maxTravelDistanceInMiles
            dvc.delegate = self
        }
        
        if (segue.identifier == "mapTobidSegue" )
        {
            let customAnnotation = selectedAnnotation[0]
            let dvc = segue.destination as! BidFormViewController
            
            
            dvc.projectImagePhoto = customAnnotation.projPhoto
            dvc.posterImagePhoto = customAnnotation.posterPic
            dvc.projectTitleString = customAnnotation.title
            dvc.projectDescriptionString = customAnnotation.postingDetails["description"]
            dvc.postingId = customAnnotation.postingDetails["posting_id"]
            dvc.userWhoPostedId = customAnnotation.postingDetails["user_id"]
          dvc.ownerTitleHolder = UsersList.getUsers()[customAnnotation.postingDetails["user_id"]!]?.name
            //Disable textbox/button if user is client
            if isContractor == false
            {
                dvc.bidButtonisHidden = true
                dvc.bidAmountFieldIsHidden = true
            }
        }
    }
    
    func processProject(postingDetails : [String:String])
    {
        guard let currentLocation = self.locationManager?.location
            else{return}
        
        if let lat = postingDetails["latitude"],
            let lon =  postingDetails["longitude"],
            let status = postingDetails["status"]
        {
            if status == "pending"
            {
                let projectAnnotation = CustomAnnotation()
                projectAnnotation.postingDetails = postingDetails
                projectAnnotation.title = projectAnnotation.postingDetails["title"]
                projectAnnotation.annotationImage = "homepin.png"
                
                let projectlocation = CLLocation.init(latitude: Double(lat)!, longitude: Double(lon)!)
                projectAnnotation.coordinate = projectlocation.coordinate
                
                let dist = (currentLocation.distance(from: projectlocation))/1609.34
                
                if (dist <= Double(self.maxTravelDistanceInMiles))
                {
                    print("PROCESS PROJECT INSIDE")
                    self.inRadiusProjects.append(projectAnnotation)
                    self.mapView.addAnnotation(projectAnnotation)
                    
                }
                else
                {
                    self.outsideRadiusProjects.append(projectAnnotation)
                }
                
                self.setChangeObservation(posting_id: (projectAnnotation.postingDetails["posting_id"])!, annotation: projectAnnotation)
            }
        }
    }
    
    
    //Check for new project on the project database
    func monitorNewProjects()
    {
        postingReference?.observe(.childAdded, with: { (snapshot) in
            let postingDetails = snapshot.value as? [String: String]
            self.processProject(postingDetails: postingDetails!)
        })
    }
    
    
    //Obserbe any changes to nearby projects
    func setChangeObservation(posting_id: String, annotation: MKAnnotation)
    {
        postingReference?.child(posting_id).observe(.childChanged, with: {(snapshot) in
            
            if snapshot.key == "status"
            {
                let status = String(describing: snapshot.value!)
                
                switch status{
                case "complete":
                    //remove annotation
                    //print("REMOVED ANNOTATION")
                    self.mapView.removeAnnotation(annotation)
                    break
                case "pending":
                    //add the annotation
                    //print("ADDED ANNOTATION")
                    self.mapView.addAnnotation(annotation)
                    break
                default:
                    break
                }
            }
        })
    }
    
    
    func createGeoRegion()
    {
        print("CREATING REGION")
        let userLat = self.locationManager?.location?.coordinate.latitude
        let userLon = self.locationManager?.location?.coordinate.longitude
        let coordinate = CLLocationCoordinate2DMake(userLat!, userLon!)
        let region = CLCircularRegion(center: coordinate, radius: 1609.34, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        region.notifyOnExit = true
        region.notifyOnEntry = false
        locationManager?.startMonitoring(for: region)
        //let circle = MKCircle(center: coordinate, radius: 1609.34)
        //mapView.add(circle)
    }
    
    
    func centerMapOnUserLocation()
    {
        //print("CENTER MAP ON USER LOCATION")
        guard let coordinate = locationManager?.location?.coordinate else{return}
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 9701,9701), animated: false)
    }
    
    
    func getUserType()
    {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            
            guard let userInfo = FIRDataSnapshot.value as? [String : String] else{ return }
            
            if (userInfo["userType"] == "Contractor")
            {
                self.isContractor = true
            }
            else
            {
                self.isContractor = false
            }
        })
    }
    
    
    func getImage(url : String, completion: @escaping (Data) -> ())
    {
        let url = NSURL(string: url)
        
        URLSession.shared.dataTask(with: url as! URL, completionHandler: {(data, response, error) in
            completion(data!)
        }).resume()
    }
    
    func getProjectPosterProfileImage(userID: String, completion: @escaping (Data) -> ())
    {
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            guard let userInfo = FIRDataSnapshot.value as? [String : String] else { return }
            
            self.getImage(url: userInfo["profilePicture"]!, completion: { (data) in
                completion(data)
            })
        })
    }
    
    func getPosterRating(userID: String, completion: @escaping (Int) -> ())
    {
        var numberOfRatings = 0
        var sumRating = 0
        
        print(userID)
        Database.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            for reviewSnap in snapshot.children.allObjects as! [DataSnapshot]
            {
                guard let reviewDetails = reviewSnap.value as? [String: Any] else { continue }
                //let id = reviewDetails["user_id"] as? String
                
                if let id = reviewDetails["user_id"] as? String,
                    let stars = reviewDetails["stars"] as? Int
                {
                    if(id == userID)
                    {
                        print("TESSSSS")
                        numberOfRatings += 1
                        sumRating += stars
                    }
                }
            }
            var avgRating = 0
            if(numberOfRatings == 0){
                avgRating = 0
            }
            else{
                avgRating = sumRating/numberOfRatings
            }
            completion(avgRating)
        })
    }
    
    
    //Sends user to app setting where they can the app allow location access
    @IBAction func enableLocationServicesButton(_ sender: UIButton) {
        
        UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy")!, options: [:], completionHandler: nil)
    }
    
    //Depending on Location Authorization Status it will enable or disable the Location Service View
    func isLocationServiceAuthorized(isAuthorized: Bool)
    {
        //print("SHOW LOCATION IS UN AVAILABLE VIEW")
        locationServiceDidFailNotificationView.isHidden = isAuthorized
    }
    
    func handleTap(_: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "mapTobidSegue", sender: self)
    }
}


extension MapsViewController: MKMapViewDelegate
{
    
    //Just for test .. Remove later
    //It will render circle where projects should be displayed
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation
        {
            return
        }
        
        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("AnnotationCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! AnnotationCalloutView
        calloutView.projectTitleLabel.text = customAnnotation.title
        calloutView.projectDescription.text = customAnnotation.postingDetails["description"]
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        
        var projLoc = CLLocation.init(latitude: customAnnotation.coordinate.latitude, longitude: customAnnotation.coordinate.longitude)
        let dist = (locationManager?.location?.distance(from: projLoc))!/1609.34
        calloutView.distanceLabel.text = String(format: "%.1f", dist) + " mi"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.getImage(url: customAnnotation.postingDetails["photoUrl"]!, completion: { (data) in
            customAnnotation.projPhoto = UIImage(data : data)
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        self.getProjectPosterProfileImage(userID: customAnnotation.postingDetails["user_id"]!, completion: { (data) in
            customAnnotation.posterPic = UIImage(data : data)
            dispatchGroup.leave()
        })
        
        //REViEW
        dispatchGroup.enter()
        print(customAnnotation.postingDetails["user_id"] )
        self.getPosterRating(userID: customAnnotation.postingDetails["user_id"]!, completion: { (data) in
            calloutView.setRatingImage(rating: data)
            print(data)
            dispatchGroup.leave()
        })//REVIEW
        
        dispatchGroup.notify(queue: .main, execute: {
            self.selectedAnnotation.removeAll()
            calloutView.profileImage.image = customAnnotation.projPhoto
            view.addSubview(calloutView)
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            self.selectedAnnotation.append(customAnnotation)
            calloutView.addGestureRecognizer(tap)
        })
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?  {
        
        print("ANNOTATION INSIDE")
        //Return if Annotation is not of type CustomAnnotation
        if !(annotation is CustomAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        //Annotation does not exsist yet
        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
            //Annotation exsist
        else
        {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
}


extension MapsViewController: CLLocationManagerDelegate
{
    //Called when the locationManager object is created
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            //print("NOT DETERMINED")
            locationManager?.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            //print("AUTHORIZED WHEN IN USE")
            //print(" OR AUTHORIZED ALWAYS")
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
            mapView.showsUserLocation = true
            setUpMap()
            //isLocationServiceAuthorized(isAuthorized: true)
            break
        case .restricted, .denied:
            //print("RESTRICTED")
            // restricted by e.g. parental controls. User can't enable Location Services
            // call function which will display disable map screen and ask user to enable
            //print("OR DENIED")
            // user denied your app access to Location Services, but can grant access from Settings.app
            // Display appropriate view to let user know if they want to view the map they will need to enable user loation.
            isLocationServiceAuthorized(isAuthorized: false)
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region.identifier == "geofence"
        {
            locationManager?.stopMonitoring(for: region)
            
            guard let currentLocation = self.locationManager?.location
                else{return}
            
            createGeoRegion()
            
            processInRadiusAnnotation(currentLocation: currentLocation)
            processOutsideRadiusAnnotation(currentLocation: currentLocation)
        }
    }
    
    
    //This is called when location manager is set to start updating location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMapOnUserLocation()
        locationManager?.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        isLocationServiceAuthorized(isAuthorized: false)
    }
}

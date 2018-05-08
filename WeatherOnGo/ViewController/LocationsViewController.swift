//
//  LocationsViewController.swift
//  WeatherOnGo
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,NSFetchedResultsControllerDelegate {
    
    //MARK:VARIABLES
    var coreDataController : CoreDataManager!
    var locationFetchController : NSFetchedResultsController<WeatherLocations>!
    //MARK:IBOUTLETS
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:LIFECYCLE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationSearchBar.delegate = self
        setupLocationController()
    }
    
    //MARK:OTHER FUNCTIONS
    fileprivate func setupLocationController() {
        let locationFetchRequest : NSFetchRequest<WeatherLocations> = WeatherLocations.fetchRequest()
        locationFetchRequest.sortDescriptors = []
        locationFetchController = NSFetchedResultsController(fetchRequest: locationFetchRequest, managedObjectContext: coreDataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        locationFetchController.delegate = self
        do{
            try locationFetchController.performFetch()
        } catch {
            fatalError("FetchResultsController Error \(error.localizedDescription)")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if !(searchBar.text?.isEmpty)!{
            activityIndicator.startAnimating()
            let locationToSave = searchBar.text
            getGeoString(locationString: locationToSave!) { (locationCoordinate, error) in
                if error == "nil"{
                    self.saveLocation(coordinates: locationCoordinate, locationName: locationToSave!)
                    self.locationTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.showAlert()
                }
            }
        }
    }
    
    
    fileprivate func showAlert() {
        let alertView = UIAlertController(title: "Location Error", message: "Sorry, But We Could not Find This Location", preferredStyle: .alert)
        //Adding a Confirm Button
        let confirmAction = UIAlertAction(title: "OK !", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(confirmAction)
        present(alertView, animated: true, completion: nil)
    }
    
    func saveLocation(coordinates : CLLocationCoordinate2D,locationName : String){
        let aLocation = WeatherLocations(context: coreDataController.viewContext)
        aLocation.locationName = locationName
        aLocation.locationLatitude = coordinates.latitude
        aLocation.locationLongitude = coordinates.longitude
        try? coreDataController.viewContext.save()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        try? locationFetchController.performFetch()
        return locationFetchController.fetchedObjects?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        try? locationFetchController.performFetch()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let locationInstance = locationFetchController.object(at: indexPath)
        cell.textLabel?.text = locationInstance.locationName
        cell.detailTextLabel?.text = "\(locationInstance.locationLatitude),\(locationInstance.locationLongitude)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateMainView(indexPath: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updateMainView(indexPath : IndexPath){
        try? locationFetchController.performFetch()
        let mainViewFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MainView")
        let mainViewDeleteRequest = NSBatchDeleteRequest(fetchRequest: mainViewFetchRequest)
        _ = try? coreDataController.viewContext.execute(mainViewDeleteRequest)
        
        let locationInstance = locationFetchController.object(at: indexPath)
        let mainViewToAdd = MainView(context: coreDataController.viewContext)
        mainViewToAdd.mainLatitude = locationInstance.locationLatitude
        mainViewToAdd.mainLongitude = locationInstance.locationLongitude
        try? coreDataController.viewContext.save()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteLocationObject(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    fileprivate func deleteLocationObject(_ indexPath: IndexPath) {
        try? locationFetchController.performFetch()
        let locationToDelete = locationFetchController.object(at: indexPath)
        coreDataController.viewContext.delete(locationToDelete)
        try? coreDataController.viewContext.save()
    }
    
    func getGeoString(locationString:String,completitionHandler:@escaping(_ locationCoordinate:CLLocationCoordinate2D,_ error:String)-> ()){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationString) { (placemark, error) in
            if error == nil { //Location Got Successfully
                if let initialPlacemark = placemark?[0]{
                    let locationFound = initialPlacemark.location
                    completitionHandler((locationFound?.coordinate)!,"nil")
                    return
                }
            }
            completitionHandler(kCLLocationCoordinate2DInvalid,(error?.localizedDescription)!)
        }
    }

}

//
//  MainViewController.swift
//  WeatherOnGo
//
//  Created by Sultan on 05/05/18.
//  Copyright © 2018 Aryan. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    //MARK:IBOUTLETS
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:VARIABLES
    var coreDataController : CoreDataManager!
    
    //MARK:LIFECYCLE FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMainScreen()
    }
    //MARK:OTHER FUNCTIONS
    fileprivate func setupMainScreen() {
        let mainFetchRequest : NSFetchRequest<MainView> = MainView.fetchRequest()
        mainFetchRequest.sortDescriptors = []
        if let results = try? coreDataController.viewContext.fetch(mainFetchRequest){
            if results.count == 0{
                showPromptController()
            } else {
                activityIndicator.startAnimating()
                let openWeather = OWNetworking(latitude: results[0].mainLatitude, longitude: results[0].mainLongitude)
                openWeather.callNetwork { (temp, humidity,locationName,error) in
                    if error == ""{
                        self.setTimeImage()
                        DispatchQueue.main.async {
                            self.tempLabel.text = "Temp is \(temp) C"
                            self.humidityLabel.text = "Humidity is \(humidity)"
                            self.locationNameLabel.text = locationName
                            self.activityIndicator.stopAnimating()
                        }
                    } else {
                        self.showAlertView(message: error)
                    }
                }
            }
        }
    }
    
    fileprivate func setTimeImage() {
        let date = Date()
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        DispatchQueue.main.async {
            if hour >= 6 && hour < 12{
                self.timeImageView.image = #imageLiteral(resourceName: "morning")
            }else if hour >= 12 && hour < 16{
                self.timeImageView.image = #imageLiteral(resourceName: "afternoon")
            }else if hour >= 16 && hour < 18{
                self.timeImageView.image = #imageLiteral(resourceName: "evening")
            }else{
                self.timeImageView.image = #imageLiteral(resourceName: "night")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocationsVC"{
            let destinationVC = segue.destination as! LocationsViewController
            destinationVC.coreDataController = coreDataController
        }
    }
    func showPromptController(){
        let alertView = UIAlertController(title: "Enter a Location", message: "Please Add a Location To Get Started", preferredStyle: .alert)
        //Adding a Confirm Button
        let confirmAction = UIAlertAction(title: "Go", style: .default) { (action) in
            self.performSegue(withIdentifier: "toLocationsVC", sender: AnyClass.self)
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(confirmAction)
        present(alertView, animated: true, completion: nil)
    }
    
}

extension UIViewController{
    func showAlertView(message:String){
        let view = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "I Will Handle it", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        view.addAction(okButton)
        present(view, animated: true, completion: nil)
    }
}


//
//  WeatherForecaseViewController.swift
//  WeatherOnGo
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import UIKit
import CoreData

class WeatherForecaseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    //MARK:VARIABLES
    var weatherForecastArray = [DarkSkyNetworking.WeatherForecast]()
    var coreDataController : CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupForecastView()
    }
    
    fileprivate func setupForecastView() {
        let mainFetchRequest : NSFetchRequest<MainView> = MainView.fetchRequest()
        mainFetchRequest.sortDescriptors = []
        if let results = try? coreDataController.viewContext.fetch(mainFetchRequest){
            if results.count != 0{
                DarkSkyNetworking().urlMaker(latitude: results[0].mainLatitude, longitude: results[0].mainLongitude) { (weatherArray,error)  in
                    if error == ""{
                        self.weatherForecastArray = weatherArray
                        DispatchQueue.main.async {
                            self.weatherTableView.reloadData()
                        }
                    } else {
                        self.showAlertView(message: error)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Date()
        let calendar = Calendar.current.date(byAdding: .day, value: section, to: date)
        let dateStyle = DateFormatter()
        dateStyle.dateFormat = "MM-dd-yyyy"
        let formattedString = dateStyle.string(from: calendar!)
        return formattedString
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return weatherForecastArray.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let aWeatherForecast = weatherForecastArray[indexPath.section]
        cell.textLabel?.text = aWeatherForecast.summary
        cell.detailTextLabel?.text = "\(aWeatherForecast.temp)"
        cell.imageView?.image = UIImage(named: aWeatherForecast.icon)
        return cell
    }

}

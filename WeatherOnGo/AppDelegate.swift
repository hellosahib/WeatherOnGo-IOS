//
//  AppDelegate.swift
//  WeatherOnGo
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coreDataController = CoreDataManager(modelName: "WeatherOnGo")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        coreDataController.loadPersistentContainer()
        injectCoreData()
        return true
    }

    func injectCoreData(){
        var mainViewController : MainViewController
        let tabBarController = window?.rootViewController as! UITabBarController
        //For First Screen
        let navigationController = tabBarController.viewControllers?.first as! UINavigationController
        mainViewController =  navigationController.topViewController as! MainViewController
        mainViewController.coreDataController = coreDataController
        
        //For 2nd Screen
        let weatherForecastController = tabBarController.viewControllers?.last as! WeatherForecaseViewController
        weatherForecastController.coreDataController = coreDataController
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        try? coreDataController.viewContext.save()
    }


}


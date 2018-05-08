//
//  OWNetworking.swift
//  Open Weather Networking
//  WeatherOnGo
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import Foundation

class OWNetworking{
    
    var networkLatitude = Double()
    var networkLongitude = Double()
    
    init(latitude:Double!,longitude:Double!) {
        networkLatitude = latitude
        networkLongitude = longitude
    }
    
    
    
    func currentWUrlMaker()-> URL{
        let dataParameters = [NetworkConstants.OWParameter.APPID:NetworkConstants.OWParameter.APIKey,
                              NetworkConstants.OWParameter.latitude:"\(networkLatitude)",
                              NetworkConstants.OWParameter.longitude:"\(networkLongitude)",
                              NetworkConstants.OWParameter.units:NetworkConstants.OWParameter.unitsToUse]
        var components = URLComponents()
        components.scheme = "\(NetworkConstants.OWURL.scheme)"
        components.host = "\(NetworkConstants.OWURL.host)"
        components.path = "\(NetworkConstants.OWURL.path)"
        components.queryItems = [URLQueryItem]()
        for (key,value) in dataParameters{
            let urlqueryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(urlqueryItem)
        }
        return components.url!
    }
    
    func callNetwork(completitionHandler:@escaping(_ temprature : Int,_ humidity : Int,_ cityName:String,_ error : String)->()){
        URLSession.shared.dataTask(with: currentWUrlMaker()) { (data, response, error) in
            if error == nil {//No Error Found
                if let parsedData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]{
                    let cityName = parsedData["name"] as! String
                    let mainData = parsedData["main"] as! [String:Any]
                    let temp = mainData["temp"] as! NSNumber
                    let humidity = mainData["humidity"] as! Int
                    completitionHandler(Int(truncating: temp),humidity,cityName,"")
                }
            } else {
                completitionHandler(0,0,"",(error?.localizedDescription)!)
            }
        }.resume()
    }
}

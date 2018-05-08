//
//  DarkSkyNetworking.swift
//  WeatherOnGo
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import Foundation

class DarkSkyNetworking{
    var weatherArray:[WeatherForecast] = []
    
    struct WeatherForecast {
        let summary : String
        let icon : String
        let temp : Double
        
        init(jsonData:[String:Any]) {
            temp = jsonData[NetworkConstants.DarkSkyKey.temprature] as! Double
            icon = jsonData[NetworkConstants.DarkSkyKey.icon] as! String
            summary = jsonData[NetworkConstants.DarkSkyKey.summary] as! String
        }
    }
    
    func urlMaker(latitude : Double,longitude : Double,completitionHandler:@escaping(_ weatherArray:[WeatherForecast], _ error : String)->()){
        let darkSkyURL = URL(string:"\(NetworkConstants.DarkSkyURL.baseURL)/\(NetworkConstants.DarkSkyURL.APIID)/\(latitude),\(longitude)?units=si")
        URLSession.shared.dataTask(with: darkSkyURL!) { (data, response, error) in
            if error == nil {
                if let parsedData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]{
                    if let dailyData = parsedData["daily"] as? [String:Any],let finalData = dailyData["data"] as? [[String:Any]]{
                        for dataEntry in finalData{
                            let weatherInstance = WeatherForecast(jsonData: dataEntry)
                            self.weatherArray.append(weatherInstance)
                        }
                    }else{
                        completitionHandler(self.weatherArray,"Error Getting Final Data")
                    }
                }else {
                    completitionHandler(self.weatherArray,(error?.localizedDescription)!)
                }
                
            }
            completitionHandler(self.weatherArray,"")
        }.resume()
    }
}

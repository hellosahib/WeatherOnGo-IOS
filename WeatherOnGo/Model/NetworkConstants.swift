//
//  NetworkConstants.swift
//  WeatherOnGo
//
//  Created by Sultan on 05/05/18.
//  Copyright © 2018 Aryan. All rights reserved.
//

import Foundation

struct NetworkConstants {
    
    struct DarkSkyKey {
        static let temprature = "temperatureMax"
        static let summary = "summary"
        static let icon = "icon"
    }
    
    struct DarkSkyURL {
        static let baseURL = "https://api.darksky.net/forecast"
        static let APIID = "caeab56588cd50db811d3489b25437de"
    }
    
    struct OWURL {
        static let scheme = "http"
        static let host = "api.openweathermap.org"
        static let path = "/data/2.5/weather"
    }
    
    struct OWParameter{
        static let APPID = "APPID"
        static let APIKey = "762d0d7d13d8833c1bf0800e8369a3f1"
        static let latitude = "lat"
        static let longitude = "lon"
        static let units = "units"
        static let unitsToUse = "metric"
        
    }
    
    
}

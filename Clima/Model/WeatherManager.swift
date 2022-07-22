//
//  WeatherManager.swift
//  Clima
//
//  Created by Nimish Mangee on 12/06/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=db780c9d10f782bddc0bc1dbd43058fa&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString="\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString);
        
    }
    
    func fetchWeather(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString="\(weatherURL)&lat=\(latitude)&lon=\(longitude)";
        performRequest(urlString: urlString);
        
    }
    
    func performRequest(urlString:String){
        
        if let url=URL(string: urlString){
            
            let session=URLSession(configuration: .default)
            
            let task=session.dataTask(with: url) { data, response, error in
                if (error != nil){
                    self.delegate?.didFailWithError(error:error!)
                    return
                }
                
                if let safeData=data{
                    if let weather=self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(weather: weather);
                    }
                }
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(weatherData:Data)->WeatherModel?{
        let decoder=JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id=decodedData.weather[0].id;
            let temp=decodedData.main.temp
            let name=decodedData.name
            
            let weather=WeatherModel(conditionId: id, cityName: name, temperature: temp);
            return weather;
        }
        catch{
            self.delegate?.didFailWithError(error: error)
            return nil;
        }
    }
    
   
}

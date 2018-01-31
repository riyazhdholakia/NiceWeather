//
//  ConditionsViewController.swift
//  NiceWeather
//
//  Created by Riyazh Dholakia on 10/13/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
//import DarkSky
import CoreLocation

class ConditionsViewController: UIViewController {
    // var condition: WeatherCondtion! this is another way it could be done
    var daily: AverageCondition?
    var hourly: MomentaryCondition?
    
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var tempMaxLabel: UILabel!
    
    @IBOutlet weak var tempMinLabel: UILabel!
    
    @IBOutlet weak var precipProbLabel: UILabel!
    
    @IBOutlet weak var humidLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var visibilityLabel: UILabel!
    
    @IBOutlet weak var cloudCoverLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDetailsOfWeather()
    }
    
    func showDetailsOfWeather() {
        if let hourly = hourly {
            summaryLabel.text = hourly.summary
            tempMaxLabel.text = "Temp: \(hourly.temperature.prettyTemp)"
            tempMinLabel.text = "Feels like: \(hourly.apparentTemperature.prettyTemp)"
            let roundPrecipHourly = Int((hourly.precipProbability * 10).rounded()*10)
            precipProbLabel.text = "Chance of \(hourly.precipType): \(roundPrecipHourly)%"
            humidLabel.text = "Humidity: \((Int(hourly.humidity)) * 100)%"
            windSpeedLabel.text = "Wind: \(Int(hourly.windSpeed)) mph"
            visibilityLabel.text = "Visibility: \(Int(hourly.visibility)) miles"
            cloudCoverLabel.text = "Cloud cover: \((Int(hourly.cloudCover)) * 100)%"
            iconImage.image = hourly.icon.image
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, ha"
            title = formatter.string(from: hourly.time)
        }
        else if let daily = daily {
            summaryLabel.text = daily.summary
            tempMaxLabel.text = "High: \(daily.temperatureMax.prettyTemp)"
            tempMinLabel.text = "Low: \(daily.temperatureMin.prettyTemp)"
            precipProbLabel.text = "\(daily.prettyPrepType)"
            humidLabel.text = "Humidity: \((Int(daily.humidity)) * 100)%"
            windSpeedLabel.text = "Wind: \(Int(daily.windSpeed)) mph"
            visibilityLabel.text = "Visibility: \(Int(daily.visibility)) miles"
            cloudCoverLabel.text = "Cloud cover: \((Int(daily.cloudCover)) * 100)%"
            iconImage.image = daily.icon.image
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            title = formatter.string(from: daily.time)
        }
    }
}


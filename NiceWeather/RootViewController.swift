//
//  RootViewController.swift
//  NiceWeather
//
//  Created by Nathan Hosselton on 8/6/17.
//  Copyright © 2017 Codebase. All rights reserved.
//


import UIKit
import DarkSky
import CoreLocation

class RootViewController: UITableViewController {
    
    //let savannah = CLLocation(latitude: 32.076176, longitude: -81.088371 )
    var forecast: Forecast?
    let locationManager = CLLocationManager()
    var date = Date()
    
    @IBOutlet weak var currentSummaryLabel: UILabel!
    
    @IBOutlet weak var currentTempLabel: UILabel!
    
    @IBOutlet weak var currentIconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        reload()
        
        tableView.estimatedSectionHeaderHeight = 40
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow?.section {
            if let conditionsVC = segue.destination as? ConditionsViewController {
                if indexPath == 0 {
                    conditionsVC.hourly = forecast?.hourly[indexPath]
                } else if indexPath == 1 {
                    conditionsVC.daily = forecast?.daily[indexPath]
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            header.frame.size.height = newSize.height
        }
    }
    
    func reload() {
        switch CLLocationManager.authorizationStatus() /* or status will work */ {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            show(alertError: "Please go to Settings and enable this APP's location services.")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        }
    }
    
    @IBAction func onRefreshPulled(_ sender: UIRefreshControl) {
        reload()
    }
    
    func onForecastDownloaded(downloadedForecast: Forecast?, error: Error?) {
        forecast = downloadedForecast
        if let forecast = forecast, let summary = forecast.currently.summary{
            currentSummaryLabel.text = "Now: \(summary)"
            currentTempLabel.text = "\(forecast.currently.temperature.prettyTemp)"
            currentIconImage.image = forecast.currently.icon.image
            currentIconImage.tintColor = UIColor.blue
            currentIconImage.image = forecast.currently.icon.image.withRenderingMode(.alwaysTemplate)
        }
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("TableSectionHeader", owner: nil, options: nil)!.first! as! TableSectionHeader
        if section == 0 {
            if let forecast = forecast?.hourlySummary {
                header.titleLabel.text = "Next 12 hours: \(forecast)"
            }
        }
        else if section == 1 {
            if let forecast = forecast?.dailySummary {
                header.titleLabel.text = "This week: \(forecast)"
            }
        }
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let forecast = forecast?.hourly.count {
                if forecast >= 12 {
                    return 12
                } else {
                    return forecast
                }
            }
        } else if section == 1 {
            if let forecast = forecast {
                return forecast.daily.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyCell", for: indexPath) as! DailyCell
        if indexPath.section == 0 {
            if let hourly = forecast?.hourly[indexPath.row] {
                formatter.dateFormat = "ha: "
                cell.weatherIconImageView.image = hourly.icon.image
                cell.weatherSummaryLabel.text = formatter.string(from: hourly.time) + hourly.summary!
                let roundPrecipHourly = Int((hourly.precipProbability * 10).rounded()*10)
                cell.weatherDetailLabel.text = "Temp: \(hourly.temperature.prettyTemp), Feels like: \(hourly.apparentTemperature.prettyTemp), Chance of \(hourly.precipType): \(roundPrecipHourly)%"
                cell.weatherIconImageView.tintColor = UIColor.blue
                cell.weatherIconImageView.image = forecast?.hourly[indexPath.row].icon.image.withRenderingMode(.alwaysTemplate)
            }
        }
        else if indexPath.section == 1 {
            if let day = forecast?.daily[indexPath.row] {
                formatter.dateFormat = "EEE: "
                cell.weatherIconImageView.image = day.icon.image
                cell.weatherSummaryLabel.text = formatter.string(from: day.time) + day.summary!
                cell.weatherDetailLabel.text = "High: \(day.temperatureMax.prettyTemp), Low: \(day.temperatureMin.prettyTemp), \(day.prettyPrepType)"
                cell.weatherIconImageView.tintColor = UIColor.blue
                cell.weatherIconImageView.image = forecast?.daily[indexPath.row].icon.image.withRenderingMode(.alwaysTemplate)
            }
        }
        return cell
    }
    
//    func conditions(forSection: Int) -> [WeatherCondition]? {
//        return nil
//    }
    
    func show(alertError error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "Error", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        refreshControl?.endRefreshing()
    }
    
    func onReverseGeocodeCompleted(placemarks: [CLPlacemark]?, error: Error?) {
        if let placemark = placemarks?.first, let titleForPlacemark = titleForPlacemark(placemark: placemark) {
            title = titleForPlacemark
        } else {
            title = error?.localizedDescription ?? "ERROR!!!! We can not find your CITY or STATE."
            refreshControl?.endRefreshing()
        }
    }

    func titleForPlacemark(placemark: CLPlacemark!) -> String? {
        if let placemark = placemark, let city = placemark.locality, let state = placemark.administrativeArea {
            return "\(city), \(state)"
        } else {
            return nil
        }
    }
}


extension RootViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchLocation = searchBar.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchLocation, completionHandler: onGeocodeCompleted)
            searchBar.resignFirstResponder()
            refreshControl?.beginRefreshing()
            searchBar.text = "" //clears text on enter
        }
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func onGeocodeCompleted(placemarks: [CLPlacemark]?, error: Error?) {
        if let placemark = placemarks?.first, let titleForPlacemark = titleForPlacemark(placemark: placemark) {
            title = titleForPlacemark
            if let location = placemarks?.first?.location {
            requestForecast(for: location, completion: onForecastDownloaded)
            }
        } else {
            title = error?.localizedDescription ?? "ERROR!!!! We can not find your CITY or STATE."
            refreshControl?.endRefreshing()
        }
    }
}


extension Double {
    var prettyTemp: String {
        return "\(Int(self))°"
    }
}

extension AverageCondition {
    var roundPrecip: Int {
        let roundPrecip = Int((precipProbability * 10).rounded()*10)
        return (roundPrecip)
    }
    var prettyPrepType: String {
        return "Chance of \(precipType): \(roundPrecip)%"
    }
}


extension RootViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            title = "Nice Weather"
        case .denied, .restricted:
            show(alertError: "Please go to Settings and enable this APP's location services.")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        requestForecast(for: locations.last!, completion: onForecastDownloaded)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locations.last!, completionHandler: onReverseGeocodeCompleted)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        show(alertError: error.localizedDescription)
    }
}

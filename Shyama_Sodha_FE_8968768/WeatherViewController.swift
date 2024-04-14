//
//  WeatherViewController.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by user237598 on 4/11/24.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

  var textFieldForInput: UITextField?
  var isFromSearch: Bool = false

  @IBOutlet weak var cityNameL: UILabel!
  @IBOutlet weak var conditionL: UILabel!
  @IBOutlet weak var conditionImg: UIImageView!
  @IBOutlet weak var tempL: UILabel!
  @IBOutlet weak var humidityL: UILabel!
  @IBOutlet weak var windL: UILabel!
  @IBOutlet weak var cityNameLabel1: UILabel!
  
  @IBAction func backToHomeBtn(_ sender: Any) {
    let myFinalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myFinal") as! MyFinalViewController
    navigationController?.pushViewController(myFinalViewController, animated: true)
    }
  
  @IBAction func cityAlertBtn(_ sender: Any) {
    let alert = UIAlertController(title: "Alert Ttitle", message: "Alert Message", preferredStyle:
                                    UIAlertController.Style.alert)
    alert.addTextField(configurationHandler: textFieldHandler)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
      self.fetchWeatherDataForCityName(cityName: self.textFieldForInput?.text)
    }))
    self.isFromSearch = true
    self.present(alert, animated: true, completion:nil)
  }
  
  func textFieldHandler(textField: UITextField!) {
        if (textField) != nil {
          self.textFieldForInput = textField
        }
    }

  private let locationManager = CLLocationManager()


  enum WeatherCondition: String {
      case rain = "Rain"
      case snow = "Snow"
      case sunny = "Clear"
      case unknown = "Unknown"
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
      
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      showInitialLocationWeather()
  }
  
  func showInitialLocationWeather(){
      if CLLocationManager.locationServicesEnabled() {
              switch locationManager.authorizationStatus {
              case .authorizedWhenInUse, .authorizedAlways:
                  locationManager.requestLocation()
              case .denied, .restricted:
                  print("Allow Location!")
              case .notDetermined:
                  print("Can't determine access")
                  locationManager.requestWhenInUseAuthorization()
              @unknown default:
                  fatalError("Unhandled exception")
              }
          } else {
              print("Enabled Location!")
          }
  }
  
  func fetchWeatherDataForCityName(cityName: String?) {
    guard let cityName = cityName else { return }
    let urlString = SharedConstants().urlStringForLonLat(cityName: cityName)
    
    if let url = URL(string: urlString) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
              do {
                  // Parse the JSON data
                  if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                      // Loop through each object in the array
                      for jsonDict in jsonArray {
                          if let lat = jsonDict["lat"] as? Double,
                             let lon = jsonDict["lon"] as? Double {
                            self.weatherData(latitude: lat, longitude: lon, cityName: cityName)
                          }
                      }
                  } else {
                      print("Failed to parse JSON")
                  }
              } catch {
                  print("Error: \(error)")
              }
            }
        }
        task.resume()
    }
  }
  
  func weatherData(latitude: Double, longitude: Double, cityName: String?){
    let urlString = SharedConstants().urlStringForWeatherAtLonLat(latitude: latitude, longitude: longitude)

          if let url = URL(string: urlString) {
              let task = URLSession.shared.dataTask(with: url) { data, response, error in
                  guard let data = data, error == nil else {
                      print("Error: \(error?.localizedDescription ?? "Unknown error")")
                      return
                  }
                  
                  if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                      do {
                          if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                              if let cityName = json["name"] as? String,
                                 let weatherArray = json["weather"] as? [[String: Any]],
                                 let main = json["main"] as? [String: Any],
                                 let temperature = main["temp"] as? Double,
                                 let humidity = main["humidity"] as? Int,
                                 let wind = json["wind"] as? [String: Any],
                                 let windSpeed = wind["speed"] as? Double {
                                  
                                  // get weather condition
                                  if let weatherMain = weatherArray.first?["main"] as? String {
                                      var weatherIconName: String
                                      var weatherConditionText: String
                                      
                                      // set image and label according to condition of weather
                                      switch weatherMain.lowercased() {
                                      case "rain":
                                          weatherIconName = "rain"
                                          weatherConditionText = "Rainy"
                                      case "snow":
                                          weatherIconName = "snow"
                                          weatherConditionText = "Snowy"
                                      default:
                                          weatherIconName = "sunny"
                                          weatherConditionText = "Sunny"
                                      }
                                      
                                      let tempC = temperature.rounded()
                                      let windKm = (windSpeed * 3.6).rounded()
                                      
                                      DispatchQueue.main.async {
                                          // show values in image and labels
                                          self.conditionImg.image = UIImage(named: weatherIconName)
                                          self.conditionL.text = weatherConditionText
                                          self.cityNameL.text = cityName
                                          self.tempL.text = "\(tempC)°"
                                          self.humidityL.text = "Humidity: \(humidity)%"
                                          self.windL.text = "Wind Speed: \(windKm) km/h"
                                        if self.isFromSearch {
                                          self.isFromSearch = false
                                          let weatherItem = WeatherItem(cityName: cityName, temperature: "\(tempC)°", humidity: "Humidity: \(humidity)%", wind: "Wind Speed: \(windKm) km/h")
                                          HistoryDataSource.shared.addItem(item: weatherItem)
                                        }
                                      }
                                  }
                              }
                          }
                      } catch {
                          print("Error parsing JSON: \(error.localizedDescription)")
                      }
                  }
              }
              task.resume()
          }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.last {
          weatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, cityName: "")
      }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Can't get location: \(error.localizedDescription)")
  }
  
  @IBAction func newsBtn(_ sender: Any) {
    let newsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocalNews") as! NewsViewController
    navigationController?.pushViewController(newsViewController, animated: true)
  }
  
  @IBAction func directionsBtn(_ sender: Any) {
    let directionsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "directions") as! DirectionsViewController
    navigationController?.pushViewController(directionsViewController, animated: true)
  }
  
  @IBAction func weatherBtn(_ sender: Any) {
    let weatherViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "weather") as! WeatherViewController
    navigationController?.pushViewController(weatherViewController, animated: true)
  }
  
  
}

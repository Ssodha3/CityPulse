//
//  ViewController.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by user237598 on 4/11/24.
//

import UIKit
import MapKit
import CoreLocation

class MyFinalViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapViewHome: MKMapView!
    @IBOutlet weak var newsBtnHome: UIButton!
    @IBOutlet weak var directionBtnHome: UIButton!
    @IBOutlet weak var weatherBtnHome: UIButton!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
  
  private let locManager = CLLocationManager()
    private let apiKey = "7a64f892d1228553cf9d34431b8f6c1c"
    
    enum WeatherCondition: String {
        case rain = "Rain"
        case snow = "Snow"
        case clear = "Clear"
        case unknown = "Unknown"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        mapViewHome.showsUserLocation = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentCityWeather()
    }
    
    func currentCityWeather(){
        guard let userLocation = locManager.location else {
            print("Location not available.")
            return
        }
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.displayWeather(with: weatherData)
                }
            }
            
            catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func displayWeather(with weatherData: WeatherData){
        let temperature = Int(weatherData.main.temp - 273.15)
        tempLabel.text = "\(temperature)o"
        humidityLabel.text = "\(weatherData.main.humidity)%"
        windLabel.text = "\(weatherData.wind.speed)km/h"
        
        let weatherCondition = WeatherCondition(rawValue: weatherData.weather.first?.main ?? "") ?? .unknown
        switch weatherCondition{
        case .rain:
            weatherImg.image = UIImage(named: "rain")
        case .snow:
            weatherImg.image = UIImage(named: "snow")
        case .clear:
            weatherImg.image = UIImage(named: "sunny")
        case.unknown:
            weatherImg.image = UIImage(named: "default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLoc = locations.last else{
            return
        }
        mapViewHome.removeAnnotations(mapViewHome.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = userLoc.coordinate
        mapViewHome.addAnnotation(annotation)
        
        let radius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: userLoc.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapViewHome.setRegion(coordinateRegion, animated: true)
      
      locManager.stopUpdatingLocation()
      mapViewHome.showsUserLocation = false

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't get location")
    }
    
    @IBAction func newsBtnHome(_ sender: Any) {
      performSegue(withIdentifier: "newsSegue", sender: self)
    }
    
    @IBAction func directionBtnHome(_ sender: Any) {
      performSegue(withIdentifier: "directionSegue", sender: self)
    }
    
    @IBAction func weatherBtnHome(_ sender: Any) {
      performSegue(withIdentifier: "weatherSegue", sender: self)
    }
}

struct WeatherData: Codable {
    let main: Main
    let wind: Wind
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}

struct Weather: Codable {
    let main: String
}

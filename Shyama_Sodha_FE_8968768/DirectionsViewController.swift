//
//  DirectionsViewController.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by user237598 on 4/11/24.
//

import UIKit
import CoreLocation
import MapKit

class DirectionsViewController: UIViewController, CLLocationManagerDelegate {

  struct Place {
    let lon: Double
    let lat: Double
    let name: String
  }
  
  let locationManager = CLLocationManager()
  var toTextField: UITextField?
  var fromTextField: UITextField?
  var place1: Place?
  var place2: Place?
  var transportationMode: MKDirectionsTransportType = .automobile
  var isFromSearch: Bool = false
  var isBikeMode = false

  @IBOutlet weak var zoomMapSlider: UISlider!
  
  @IBOutlet weak var displayMapView: MKMapView!
  @IBAction func carModeBtn(_ sender: Any) {
    transportationMode = .automobile
    isBikeMode = false
    toggleModeOfTransport()
  }
  
  @IBAction func bikeModeBtn(_ sender: Any) {
    // apple map does not have bike mode so we use walking mode
    transportationMode = .walking
    isBikeMode = true
    toggleModeOfTransport()
  }
  
  @IBAction func walkModeBtn(_ sender: Any) {
    transportationMode = .walking
    isBikeMode = false
    toggleModeOfTransport()
  }
  
  @IBAction func backHomeBtn(_ sender: Any) {
    let myFinalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myFinal") as! MyFinalViewController
    navigationController?.pushViewController(myFinalViewController, animated: true)
  }
  
  @IBAction func cityAlertBtn(_ sender: Any) {
    self.place1 = nil
    self.place2 = nil
    let alert = UIAlertController(title: "Alert Ttitle", message: "Alert Message", preferredStyle:
                                    UIAlertController.Style.alert)
    alert.addTextField(configurationHandler: toTextFieldHandler)
    alert.addTextField(configurationHandler: fromTextFieldHandler)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
      self.fetchLonAndLatForCity(cityName: self.toTextField?.text)
      self.fetchLonAndLatForCity(cityName: self.fromTextField?.text)
    }))
    self.present(alert, animated: true, completion:nil)
    self.isFromSearch = true
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
      displayMapView.delegate = self
      updateZoomLevel(zoomMapSlider.value)
      zoomMapSlider.addTarget(self, action: #selector(zoomMapSliderValueChanged(_:)), for: .valueChanged)
      displayMapView.showsUserLocation = true
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
  }
  
  func toTextFieldHandler(textField: UITextField!) {
      if (textField) != nil {
        self.toTextField = textField
      }
  }
  
  func fromTextFieldHandler(textField: UITextField!) {
      if (textField) != nil {
        self.fromTextField = textField
      }
  }
  
  func fetchLonAndLatForCity(cityName: String?) {
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
              if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                  // Loop through each object in the array
                  for jsonDict in jsonArray {
                    if let lat = jsonDict["lat"] as? Double,
                       let lon = jsonDict["lon"] as? Double {
                       if self.place1 == nil {
                         self.place1 = Place(lon: lon, lat: lat, name: cityName)
                        }else {
                          self.place2 = Place(lon: lon, lat: lat, name: cityName)
                        }
                    if (self.place1 != nil && self.place2 != nil) {
                         DispatchQueue.main.async {
                         self.updateMapWith2LocationsPlacesToStart(cityName: cityName)
                        
                        }
                        }
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
  
  func distanceBetweenPlaces(places1: Place, places2: Place) -> CLLocationDistance {
    let location1 = CLLocation(latitude: places1.lat, longitude: places1.lon)
    let location2 = CLLocation(latitude: places2.lat, longitude: places2.lon)
    let distanceInMeters = location1.distance(from: location2)
    let distanceInKilometers = distanceInMeters / 1000
    return distanceInKilometers
    //return location1.distance(from: location2)
    
  }
  
  func toggleModeOfTransport() {
    guard let place1 = place1, let place2 = place2 else { return }
    let directionsRequest = MKDirections.Request()
    directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: place1.lat, longitude: place2.lon)))
    directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: place1.lat, longitude: place2.lon)))
    directionsRequest.transportType = transportationMode
    
    let directions = MKDirections(request: directionsRequest)
    
    directions.calculate { [weak self] (response, error) in
          guard let route = response?.routes.first else {
              return
          }
          self?.displayMapView.removeOverlays(self?.displayMapView.overlays ?? [])
          self?.displayMapView.addOverlay(route.polyline)
          self?.displayMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
  
  func updateMapWith2LocationsPlacesToStart(cityName: String) {
    let distance = self.distanceBetweenPlaces(places1: self.place1!, places2: self.place2!)
    
    if self.isFromSearch {
      var modeTravelString = "Car"
      if self.transportationMode == .walking {
        modeTravelString = self.isBikeMode ? "Bike" : "Walk"
      }
      self.isFromSearch = false
      let place1Name = self.place1?.name
      let place2Name = self.place2?.name
      let weatherItem = DirectionItem(cityName: cityName, to: place1Name!, from: place2Name!, modeTravel: modeTravelString, distance: "Distance: \(String(format: "%.2f km", distance))")
      HistoryDataSource.shared.addItem(item: weatherItem)
    }
    
    // Clear previous annotations and overlays
    displayMapView.removeAnnotations(displayMapView.annotations)
    displayMapView.removeOverlays(displayMapView.overlays)
    // Define two points (start and end locations)
    let startCoordinate = CLLocationCoordinate2D(latitude: self.place1!.lat, longitude: self.place1!.lon)
    let endCoordinate = CLLocationCoordinate2D(latitude: self.place2!.lat, longitude: self.place2!.lon)
    
    // Add annotations for start and end points
    let startAnnotation = MKPointAnnotation()
    startAnnotation.coordinate = startCoordinate
    startAnnotation.title = "Start"
    
    let endAnnotation = MKPointAnnotation()
    endAnnotation.coordinate = endCoordinate
    endAnnotation.title = "End"
    
    displayMapView.addAnnotations([startAnnotation, endAnnotation])
            
    // Create polyline
    let coordinates = [startCoordinate, endCoordinate]
    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
    displayMapView.addOverlay(polyline)
            
    // Set region to show both points
    let region = MKCoordinateRegion(center: startCoordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
    displayMapView.setRegion(region, animated: true)
  }
  
  @objc func zoomMapSliderValueChanged(_ sender: UISlider) {
    updateZoomLevel(sender.value)
  }
  
  func updateZoomLevel(_ value: Float) {
    let minValue: Double = 100 // Define your minimum value here
    let maxValue: Double = 1000 // Define your maximum value here
    let invertedSliderValue = 1.0 - value

    let span = minValue + (maxValue - minValue) * Double(invertedSliderValue)
      let region = MKCoordinateRegion(center: displayMapView.centerCoordinate, latitudinalMeters: span, longitudinalMeters: span)
      displayMapView.setRegion(region, animated: true)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let userLoc = locations.last else{
          return
      }
    displayMapView.removeAnnotations(displayMapView.annotations)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = userLoc.coordinate
    displayMapView.addAnnotation(annotation)
      
      let radius: CLLocationDistance = 1000
      let coordinateRegion = MKCoordinateRegion(center: userLoc.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
    displayMapView.setRegion(coordinateRegion, animated: true)
    
    locationManager.stopUpdatingLocation()
    displayMapView.showsUserLocation = false
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Can't get location")
  }
  
  
  @IBAction func newsBtn(_ sender: Any) {
    let newsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocalNews") as! NewsViewController
    navigationController?.pushViewController(newsViewController, animated: true)
  }
  
  @IBAction func directionBtn(_ sender: Any) {
    let directionsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "directions") as! DirectionsViewController
    navigationController?.pushViewController(directionsViewController, animated: true)
  }

  @IBAction func weatherBtn(_ sender: Any) {
    let weatherViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "weather") as! WeatherViewController
    navigationController?.pushViewController(weatherViewController, animated: true)
  }
  
}

extension DirectionsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
  
  
}

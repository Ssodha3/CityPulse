//
//  NewsViewController.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by user237598 on 4/11/24.
//

import UIKit
import CoreLocation

class NewsViewController: UIViewController,CLLocationManagerDelegate , UITableViewDelegate, UITableViewDataSource {
  
  struct Article {
    let title: String
    let source: String
    let content: String
    let author: String
  }
  
  @IBOutlet weak var alertBtn: UIBarButtonItem!
  @IBOutlet weak var newTableView: UITableView!
  @IBOutlet weak var homeBtn: UIBarButtonItem!
  
  var textFieldForInput: UITextField?
  var dataSource: [Article] = []
  var isFromSearch: Bool = false

  private let locationManager = CLLocationManager()
  
  @IBAction func backToHomeBtn(_ sender: Any) {
    let myFinalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myFinal") as! MyFinalViewController
    navigationController?.pushViewController(myFinalViewController, animated: true)
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
    }else{
            print("Enabled Location!")
         }
  }
    
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
            
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse lon-lat to city did not work: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks at this point")
                return
            }
            
            if let city = placemark.locality {
              self.fetchNewsForQuery(query: city)
            }
        }
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Can't get location: \(error.localizedDescription)")
  }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
      let article = dataSource[indexPath.row]
      cell.newsTitleLabel.text = article.title
      cell.newsContentLabel.text = article.content
      cell.authorLabel.text = article.author
      cell.sourceLabel.text = article.source
      return cell
    }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
  
  
  @IBAction func alertBtn(_ sender: Any) {
    let alert = UIAlertController(title: "Alert Ttitle", message: "Alert Message", preferredStyle:
                                    UIAlertController.Style.alert)
    alert.addTextField(configurationHandler: textFieldHandler)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
      self.fetchNewsForQuery(query: self.textFieldForInput?.text)
    }))
    self.present(alert, animated: true, completion:nil)
    self.isFromSearch = true
  }
  
  func textFieldHandler(textField: UITextField!) {
        if (textField) != nil {
          self.textFieldForInput = textField
        }
    }
  
  func fetchNewsForQuery(query: String?) {
    guard let query = query else { return }
    let urlString = SharedConstants().urlStringForNews(query: query)
    if let url = URL(string: urlString) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
              do {
                  if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                     let articles = json["articles"] as? [[String: Any]] {
                    var allArticles: [Article] = []
                      for article in articles {
                          if let source = article["source"] as? [String: Any],
                             let sourceName = source["name"] as? String,
                             let author = article["author"] as? String,
                             let title = article["title"] as? String,
                             let content = article["content"] as? String {
                            allArticles.append(Article(title: title, source: sourceName, content: content, author: author))
                          }
                      }
                    DispatchQueue.main.async {
                      // add first item to History DataSource
                      if allArticles.count > 0 && self.isFromSearch {
                        let firstItem = allArticles[0]
                        let newsItem = NewsItem(title: firstItem.title, source: firstItem.source, author: firstItem.author, content: firstItem.content, city: query)
                        HistoryDataSource.shared.addItem(item: newsItem)
                        self.isFromSearch = false
                      }
                      self.dataSource = allArticles
                      self.newTableView.reloadData()
                    }
                  }
              } catch {
                  print("Error parsing JSON: \(error)")
              }
            }
        }
        task.resume()
    }
    
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


class TableViewCell: UITableViewCell {
  @IBOutlet weak var newsTitleLabel: UILabel!
  
  @IBOutlet weak var newsContentLabel: UILabel!
  
  @IBOutlet weak var sourceLabel: UILabel!
  
  @IBOutlet weak var authorLabel: UILabel!
  
}

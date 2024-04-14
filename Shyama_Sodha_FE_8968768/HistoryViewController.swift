//
//  HistoryViewController.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by user237598 on 4/11/24.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var historyTableView: UITableView!
  var dataSource: [Any] = []
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let itemAtIndex = dataSource[indexPath.row]
    if (itemAtIndex as AnyObject).isKind(of: NewsItem.self) {
      let item: NewsItem = itemAtIndex as! NewsItem
      let cell: HistoryNewsTabelViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryNewsTabelViewCell", for: indexPath) as! HistoryNewsTabelViewCell
      cell.contentOfLabel.text = item.content
      cell.newsTitle.text = item.title
      cell.newsAuthorLabel.text = item.author
      cell.newsSource.text = item.source
      cell.cityNameLabel.text = item.city
      return cell
    } else if (itemAtIndex as AnyObject).isKind(of: WeatherItem.self) {
      let item: WeatherItem = itemAtIndex as! WeatherItem
      let cell: HistoryWeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryWeatherTableViewCell", for: indexPath) as! HistoryWeatherTableViewCell
      cell.weatherCityHistoryLabel.text = item.cityName
      cell.weatherTempHistoryLabel.text = item.temperature
      cell.weatherHumidityHistoryLabel.text = item.humidity
      cell.weatherWindHistoryLabel.text = item.wind
      return cell
    } else if (itemAtIndex as AnyObject).isKind(of: DirectionItem.self) {
      let item: DirectionItem = itemAtIndex as! DirectionItem
      let cell: HistoryDirectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryDirectionTableViewCell", for: indexPath) as! HistoryDirectionTableViewCell
      cell.mapCityNameHistoryLabel.text = item.cityName
      cell.mapStartPointHistoryLabel.text = item.to
      cell.mapEndPointHistoryLabel.text = item.from
      cell.mapTotalDistanceHistoryLabel.text = item.distance
      cell.mapModeHistoryLabel.text = item.modeTravel
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let itemAtIndex = dataSource[indexPath.row]
    if (itemAtIndex as AnyObject).isKind(of: NewsItem.self) {
      return 140
    } else if (itemAtIndex as AnyObject).isKind(of: WeatherItem.self) {
      return 140
    } else if (itemAtIndex as AnyObject).isKind(of: DirectionItem.self) {
      return 140
    }
    return 100
  }

  override func viewDidLoad() {
      super.viewDidLoad()
      dataSource = HistoryDataSource.shared.dataSourceItems
      historyTableView.reloadData()
  }
}

class HistoryNewsTabelViewCell : UITableViewCell{
  
  @IBOutlet weak var contentOfLabel: UILabel!
  
  @IBOutlet weak var cityNameLabel: UILabel!
  
  @IBOutlet weak var fromLabel: UILabel!
  @IBOutlet weak var newsTitle: UILabel!
  @IBOutlet weak var newsSource: UILabel!
  
  @IBOutlet weak var newsAuthorLabel: UILabel!
  @IBOutlet weak var newsContentLabel: UILabel!
  
}

class HistoryWeatherTableViewCell: UITableViewCell{
  
  @IBOutlet weak var weatherFromHistoryLabel: UILabel!
  
  @IBOutlet weak var weatherTempHistoryLabel: UILabel!
  @IBOutlet weak var weatherCityHistoryLabel: UILabel!
  
  @IBOutlet weak var weatherHumidityHistoryLabel: UILabel!
  
  @IBOutlet weak var weatherDataFromHistoryLabel: UILabel!
  @IBOutlet weak var weatherWindHistoryLabel: UILabel!
}

class HistoryDirectionTableViewCell: UITableViewCell {
  @IBOutlet weak var mapNameHistoryLabel: UIView!
  
  @IBOutlet weak var mapCityNameHistoryLabel: UILabel!
  @IBOutlet weak var mapEndPointHistoryLabel: UILabel!
  @IBOutlet weak var mapStartPointHistoryLabel: UILabel!
  
  @IBOutlet weak var mapFromHistoryLabel: UILabel!

  @IBOutlet weak var mapTotalDistanceHistoryLabel: UILabel!
  @IBOutlet weak var mapModeHistoryLabel: UILabel!
  
  
  
  
}

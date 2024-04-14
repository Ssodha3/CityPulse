//
//  HistoryDataSource.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by nidhi raithatha on 4/13/24.
//

import Foundation

class NewsItem {
  let title: String
  let source: String
  let author: String
  let content: String
  let city: String
  
  init(title: String, source: String, author: String, content: String, city: String) {
    self.title = title
    self.source = source
    self.author = author
    self.content = content
    self.city = city 
  }
}

class WeatherItem {
  let cityName: String
  let temperature: String
  let humidity: String
  let wind: String
  
  init(cityName: String, temperature: String, humidity: String, wind: String) {
    self.cityName = cityName
    self.temperature = temperature
    self.humidity = humidity
    self.wind = wind
  }
}

class DirectionItem {
  let cityName: String
  let to: String
  let from: String
  let modeTravel: String
  let distance: String
  
  init(cityName: String, to: String, from: String, modeTravel: String, distance: String) {
    self.cityName = cityName
    self.to = to
    self.from = from
    self.modeTravel = modeTravel
    self.distance = distance
  }
}

class HistoryDataSource {
  
  static let shared = HistoryDataSource()
  
  private init() {}
  
  var dataSourceItems: [Any] = []
    
  func addItem(item: Any) {
    dataSourceItems.insert(item, at: 0)
  }
  
  func removeItemAtIndex(index: Int) {
    dataSourceItems.remove(at: index)
  }
}

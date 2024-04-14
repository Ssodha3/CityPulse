//
//  SharedConstants.swift
//  Shyama_Sodha_FE_8968768
//
//  Created by nidhi raithatha on 4/12/24.
//

import Foundation

struct SharedConstants {
  //my api key for openweaterapi
  private let apiKey = "7a64f892d1228553cf9d34431b8f6c1c"
  
  func urlStringForLonLat(cityName: String) -> String {
    return "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(apiKey)"
  }
  
  func urlStringForWeatherAtLonLat(latitude: Double, longitude: Double) -> String {
    return "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(apiKey)"
  }
  
  func urlStringForNews(query: String) -> String {
    let stringWithSpace = "https://newsapi.org/v2/everything?q=\(query)&apiKey=008d6d45feb34808b1326b3711da8c0a&language=en"
    if let encodedString = stringWithSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
      return encodedString
    }
    return ""
    
  }
}


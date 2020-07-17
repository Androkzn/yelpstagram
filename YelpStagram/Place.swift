
import Foundation

// https://www.yelp.com/developers/documentation/v3/business_search

struct Place: Codable {
  var id: String
  var name: String
  var image_url: String
  var rating: Double
  var review_count: Int
  var price: String?
  var is_closed: Bool
  var url: String
  var transactions: [String]
  
  var photos: [String]?
}

import UIKit

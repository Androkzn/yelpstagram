//
//  ApiResult.swift
//  YelpStagram
//
//  Created by Andrei Tekhtelev on 2020-05-25.
//  Copyright © 2020 Sam Meech-Ward. All rights reserved.
//

import Foundation

struct ApiResult: Codable {
  var total: Int
  var businesses: [Place]
}

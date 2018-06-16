//
//  DirectionData.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 15/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

struct DirectionData : Decodable {
    let geocoded_waypoints : [geocodeWaypoints]?
    let routes: [routesData]?
    let status: String?
}

struct geocodeWaypoints : Decodable {
    let geocoder_status: String?
    let place_id: String?
    let types: [String]?
}

struct routesData:Decodable {
    let bounds:boundsData?
    let copyrights:String?
    let legs:[DataDetail]?
    let overview_polyline:polylineData?
    let summary:String?
}

struct boundsData:Decodable {
    let northeast:coordinates?
    let southwest:coordinates?
}
struct value : Decodable {
    let text: String?
    let value: Float?
}

struct coordinates : Decodable {
    let lat : Float?
    let lng : Float?
}

struct DataDetail: Decodable {
    let distance: value?
    let duration: value?
    let end_location: coordinates?
    let end_address: String?
    let start_location: coordinates?
    let steps:[stepsData]?
}
struct stepsData:Decodable {
    let distance: value?
    let duration: value?
    let end_location: coordinates?
    let html_instructions: String?
    let polyline: polylineData?
    let start_location:coordinates?
    let travel_mode: String?
}
struct polylineData: Decodable {
    let points:String?
}

//
//  File.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 12/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {

    let place: GooglePlace

    init(place: GooglePlace) {
        self.place = place
        super.init()

        position = place.coordinate
        icon = UIImage(named: place.placeType)
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}

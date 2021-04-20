//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 18/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {

    //MARK: - enum
    enum PlaceType {
        case place
        case poi
    }

    //MARK: - variable
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var  type: PlaceType
    var address: String?

    //MARK: - init
    init(coordinate: CLLocationCoordinate2D, type: PlaceType ) {
        self.coordinate = coordinate
        self.type = type
    }
}

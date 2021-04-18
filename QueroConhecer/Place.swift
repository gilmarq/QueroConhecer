//
//  Place.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 07/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import Foundation
import MapKit

struct Place: Codable {

    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String

    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func getFormatterAdress(with placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
            address += street
        }
        if let number = placemark.subThoroughfare {
            address += "\(number)"
        }
        if let subLocality = placemark.subLocality {
            address += ", \(subLocality)"
        }
        if let city  = placemark.locality {
            address += "\n\(city)"
        }
        if let state  = placemark.administrativeArea {
            address += " - \(state)"
        }
        if let postalCode  = placemark.postalCode {
            address += "\n CEP: \(postalCode)"
        }

        if let country  = placemark.country {
            address += "\n\(country)"
        }
        return address
    }

}

extension Place: Equatable {
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

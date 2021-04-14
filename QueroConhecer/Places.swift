//
//  Places.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 12/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import Foundation
import MapKit

struct Places {
    let name: String
    let latidute: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    var coordinete: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latidute, longitude: longitude)
    }

    func getFormattedAddress(with placemarck : CLPlacemark) -> String {
        var address = ""
        if let street = placemarck.thoroughfare {
            address += street
        }
        if let number = placemarck.subThoroughfare {
            address += " \(number)"
        }
        if let subLocality = placemarck.subLocality {
            address += ", \(subLocality)"
        }
        if let city = placemarck.location {
            address += " \n \(city)"
        }
        if let state = placemarck.administrativeArea {
            address += " -\(state)"
        }
        if let postalCode = placemarck.postalCode {
            address += " \n CEP:  \(postalCode)"
        }
        if let country = placemarck.country {
            address += " \n \(country)"
        }
        return address
    }

}

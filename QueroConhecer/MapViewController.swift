//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 06/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!

    //MARK: - variable
    var places: [Place]!

     //MARK: - life cyclo
    override func viewDidLoad() {
        super.viewDidLoad()
        for place in places {
            addToMap(place)
        }
        showPlaces()
        setupView()
    }

     //MARK: - methods
    func addToMap(_ place:Place) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        mapView.addAnnotation(annotation)
    }

    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func setupView() {
        self.searchBar.isHidden = true
        self.viInfo.isHidden = true

        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus lugares"
        }
    }

    //MARK: = action
    @IBAction func showRoute(_ sender: Any) {
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
    }


    
}

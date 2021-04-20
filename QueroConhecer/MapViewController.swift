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
    @IBOutlet weak var loading: UIActivityIndicatorView!

    //MARK: - variable
    var places: [Place]!
    var poi: [MKAnnotation] = []

    //MARK: - life cyclo
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.mapType = .mutedStandard

        for place in places {
            addToMap(place)
        }
        showPlaces()
        setupView()
    }

    //MARK: - methods
    func addToMap(_ place:Place) {
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
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
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation){
            return nil
        }
        let type = (annotation as! PlaceAnnotation).type
        let identifier  = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main"): UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") :  UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required  : .defaultHigh


        return annotationView
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)

        search.start { (response , error) in
            if error == nil {
                guard let response = response else {
                    self.loading.stopAnimating()
                    return
                }
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                for item in response.mapItems {
                    let annotation  =  PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormatterAdress(with: item.placemark)
                    self.poi.append(annotation)
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
            }
            self.loading.stopAnimating()
        }
    }
}

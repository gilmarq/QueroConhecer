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

    enum MapMessageType {
        case routeError
        case authorizationWarnnig

    }

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
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    var selectedAnnotaion: PlaceAnnotation?

    //MARK: - life cyclo
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        mapView.mapType = .mutedStandard

        for place in places {
            addToMap(place)
        }

        showPlaces()
        configurelocationButton()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestUserLocationAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }

    //MARK: - methods
    func addToMap(_ place:Place) {

        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        //annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.address = place.address
        mapView.addAnnotation(annotation)
    }

    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapView.addSubview(btUserLocation)
                    break
                case .denied:
                    showMessager(type: .authorizationWarnnig)
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    break
                default:
                    break
            }
        } else {
            // Deus ruim
        }
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

    func showMessager(type: MapMessageType) {


        let title = type ==  .authorizationWarnnig ? "Aviso" : "Erros"
        let message = type == .authorizationWarnnig ? "Para usar o recuso de localização do App, você precisa permitir o usa na tela de ajuste" : " não foi possivel encontrar esta rota"


        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction  = UIAlertAction(title: "Cancelar", style: .cancel
            , handler: nil)
        alert.addAction(cancelAction)

        if type == .authorizationWarnnig {

            let confirmeAction = UIAlertAction(title: "ir para ajustes", style: .default, handler:
            { (action) in
                if let AppSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(AppSetting, options: [:], completionHandler: nil)
                }
            })

            alert.addAction(confirmeAction)
        }
        present(alert, animated: true, completion: nil)
    }

    func configurelocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.masksToBounds = true
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
    }

    func showInfo() {
        lbName.text = selectedAnnotaion!.title
        lbAddress.text = selectedAnnotaion!.address
        viInfo.isHidden = false
    }

    //MARK: = action
    @IBAction func showRoute(_ sender: Any) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showMessager(type: .authorizationWarnnig)
            return
        }
        // traçando a rota
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedAnnotaion!.coordinate))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))

        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if error == nil {
                if let response = response {
                   // self.mapView.removeOverlay(self.mapView?.overlays)

                    // pegando a primeira rota
                    let route = response.routes.first!
                    for step in route.steps {
                        print("Em  \(step.distance) metros ,\(step.instructions)")
                    }
                    self.mapView.addOverlay(route.polyline, level:.aboveRoads)
                    var annotation = self.mapView.annotations.filter({!($0 is PlaceAnnotation)})
                    annotation.append(self.selectedAnnotaion!)
                    self.mapView.showAnnotations(annotation, animated: true)

                }
            } else {
                self.showMessager(type: .routeError)
            }
        }
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotaion = (view.annotation as! PlaceAnnotation)

        let camera = MKMapCamera()
        camera .centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80 // angulo da camera
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)

        showInfo()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }
}
//MARK: - UISearchBarDelegate
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

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
                mapView.addSubview(btUserLocation)
                locationManager.startUpdatingLocation()
            default:
                break
        }
    }

    //        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //            if let location = locations.last {
    //                print("velocidade", location.speed)
    //                let region = MKCoordinateRegion(center: location.coordinate ,latitudinalMeters: 500,longitudinalMeters: 500)
    //                mapView.setRegion(region, animated: true)
    //            }
    //        }
}

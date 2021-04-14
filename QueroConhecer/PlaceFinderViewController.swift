//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 06/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import UIKit
import MapKit

enum PlaceFinderMessageType {
    case error(String)
    case confirmation(String)
}

class PlaceFinderViewController: UIViewController {

    //MARK: - outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var viewLoanding: UIView!
    @IBOutlet weak var loanding: UIActivityIndicatorView!
    var  place: Place!

    //MARK: - life cyclo
    override func viewDidLoad() {
        super.viewDidLoad()
        gestor()
    }

    //MARK: - action
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finderCity(_ sender: Any) {
        tfCity.resignFirstResponder()
        let address = tfCity.text!
        load(show: true)
        let geoCode = CLGeocoder()
        geoCode.geocodeAddressString(address) { (placemark, error) in
            self.load(show: false)
            //self.loadGeoLocation(error as! Error, placemark:placemark)
            if error == nil {
                if !self.savePlace(with: placemark?.first) {

                    self.showMessager(type: .error("Não encontrado nenhum local com este nome ") )
                } else {
                    self.showMessager(type: .error("Local Desconhecido"))
                }
            }
        }
    }

    //MARK: - method

    func loadGeoLocation(_ error:Error, placemark: CLPlacemark) {
      self.load(show: false)
        if error == nil {

            if !self.savePlace(with: placemark) {

                self.showMessager(type: .error("Não encontrado nenhum local com este nome ") )
            } else {
                self.showMessager(type: .error("Local Desconhecido"))
            }
        }
    }

    func gestor() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
    }

    @objc func getLocation(_ gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point =  gesture.location(in: mapView)
            let coordinator = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinator.latitude, longitude: coordinator.longitude)
            let geoLocation = CLGeocoder()
            geoLocation.reverseGeocodeLocation(location) { (placemark, error) in
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemark?.first) {

                        self.showMessager(type: .error("Não encontrado nenhum local com este nome ") )
                    } else {
                        self.showMessager(type: .error("Local Desconhecido"))
                    }
                }
            }

        }
    }

    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard  let placemark = placemark , let  coordinate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormatterAdress(with: placemark)
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3500, longitudinalMeters: 3500)
        mapView.setRegion(region, animated: true)
        showMessager(type: .confirmation(place.name))

        return true
    }

    func showMessager(type: PlaceFinderMessageType) {
        let title: String
        let message: String
        var hasConfirmation: Bool = false

        switch type {
            case .confirmation(let name ):
                title = "Local encontrado"
                message = "Deseja adicionar \(name)?"
                hasConfirmation = true
            case .error(let errorMassege):
                title = "Erro"
                message = errorMassege
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction  = UIAlertAction(title: "Cancelar", style: .cancel
            , handler: nil)
        alert.addAction(cancelAction)
        if hasConfirmation {
            let confirmeAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                print("ok")
            }
            alert.addAction(confirmeAction)
        }
        present(alert, animated: true, completion: nil)

    }

    func  load(show: Bool) {
        viewLoanding.isHidden = !show
        show ? loanding.startAnimating() : loanding.stopAnimating()
    }
}

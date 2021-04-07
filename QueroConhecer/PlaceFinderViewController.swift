//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 06/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var viewLoanding: UIView!
    @IBOutlet weak var loanding: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
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

            guard let placemark = placemark?.first else {return}
            print(Place.getFormatterAdress(with:placemark))
        }
    }
    
    func  load(show: Bool) {
        viewLoanding.isHidden = !show
        show ? loanding.startAnimating() : loanding.stopAnimating()
    }
}

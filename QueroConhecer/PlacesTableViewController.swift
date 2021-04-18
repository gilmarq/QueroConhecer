//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Gilmar Queiroz on 06/04/21.
//  Copyright © 2021 Gilmar Queiroz. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    //MARK: - variable
    var places: [Place] = []
    let userDefaults = UserDefaults.standard

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
    }
    //MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! != "mapSegue" {
            let vc = segue.destination as! PlaceFinderViewController
            vc.delegate = self
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        return cell
    }


    //MARK: - methods
    func loadPlaces() {
        if let placesData = userDefaults.data(forKey: "plaves") {
            do{
                places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            }catch{
                print(error.localizedDescription)
            }
        }
    }

    func  savePlaces() {
        let json = try? JSONEncoder().encode(places)
        userDefaults.set(json, forKey: "places")
    }
}

extension PlacesTableViewController: PlacesFindeDelegate {
    func addPlaces(_ place: Place) {
        if !places.contains(place) {
            places.append(place)
            savePlaces()
            tableView.reloadData()
        }
    }
}

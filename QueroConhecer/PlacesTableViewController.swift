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
    var lbNoPlaces: UILabel!

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        noplaceButton()
        savePlaces()
    }
    //MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! != "mapSegue" {
            let vc = segue.destination as! PlaceFinderViewController
            vc.delegate = self
        } else {
            let vc = segue.destination as! MapViewController
            switch sender {
                case let place as Place:
                    vc.places = [place]
                default:
                    vc.places = places 
            }

        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            let btShowAll = UIBarButtonItem(title: "Mostra todos no mapa", style:.plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = btShowAll
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lbNoPlaces
        }

        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle  == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
    }

    //MARK: - methods
    func loadPlaces() {
        if let placesData = userDefaults.data(forKey: "places") {
            do{
                places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            }catch{
                print(error.localizedDescription)
            }
        }
    }

    func savePlaces() {
        let json = try? JSONEncoder().encode(places)
        userDefaults.set(json, forKey: "places")
    }

    @objc func showAll() {
         performSegue(withIdentifier: "mapSegue", sender: nil)
    }

    func noplaceButton() {
        self.lbNoPlaces = UILabel()
        self.lbNoPlaces.text = "Cadatre os locais que deseja conhecer\nclicador no botão + a cima"
        self.lbNoPlaces.textAlignment = .center
        self.lbNoPlaces.numberOfLines = 0

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

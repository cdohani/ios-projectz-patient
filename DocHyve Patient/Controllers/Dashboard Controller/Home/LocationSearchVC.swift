//
//  LocationSearchVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 08/12/2025.
//

import UIKit
import GooglePlaces
class LocationSearchVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var txtSearch: AuthTextField!
    @IBOutlet var tblLocationSearch: UITableView!
    
    
    var queryText = ""
    
    //MARK: Variable
    weak var dataDelegate: TransferDataDelegate?
    var placesClient = GMSPlacesClient.shared()
    var predictions: [GMSAutocompletePrediction] = []
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.text = queryText
        performSearch(query: queryText)
    }
    
    //MARK: Functions
    
    
    
    //MARK: ButtonActions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func txtSearchDidChange(_ sender: UITextField) {
        performSearch(query: sender.text)
    }
    
    func performSearch(query: String?) {
        guard let text = query, !text.isEmpty else {
            predictions = []
            tblLocationSearch.reloadData()
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.countries = ["USA"]

        placesClient.findAutocompletePredictions(
            fromQuery: text,
            filter: filter,
            sessionToken: GMSAutocompleteSessionToken()
        ) { (results, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.predictions = results ?? []
            self.tblLocationSearch.reloadData()
        }
    }
    
}
extension LocationSearchVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleSearchTCell") as! GoogleSearchTCell
        let place = predictions[indexPath.row]
        cell.lblPlacesName.text = place.attributedFullText.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prediction = predictions[indexPath.row]
        
        let placeID = prediction.placeID
        
        placesClient.fetchPlace(
            fromPlaceID: placeID,
            placeFields: [.name, .formattedAddress, .coordinate],
            sessionToken: nil
        ) { place, error in
            
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                var tempAddress = GoogleLocationModel()
                tempAddress.placeName = place.name ?? ""
                tempAddress.placeAddress = place.formattedAddress ?? ""
                tempAddress.latitude = place.coordinate.latitude
                tempAddress.longitude = place.coordinate.longitude
                
                self.txtSearch.text = place.formattedAddress
                self.predictions = []
                self.tblLocationSearch.reloadData()
                self.dataDelegate?.sendData(tempAddress)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

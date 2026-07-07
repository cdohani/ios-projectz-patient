//
//  BottomSheetMultiSelectionVC.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 12/29/25.
//

import UIKit
import GooglePlaces
//import GooglePlacesSwift
import CoreLocationUI
import Localize_Swift

class BottomSheetMultiSelectionVC: ParentViewController {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var txtSearchBar: UISearchBar!
    @IBOutlet weak var heightSearchBar: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    
    enum BottomSheetMulti {
        case specialty
        case state
        case none
        case location
        case reviewType
    }
    
    var type: BottomSheetMulti = .none
    
    var isMultiSelection = true
    
    private let placesClient = GMSPlacesClient.shared()
    private var sessionToken: GMSAutocompleteSessionToken?
    var predictions: [GMSAutocompleteSuggestion] = []
//    var onAddressSelected: ((GMSAutocompletePlaceSuggestion? ,[GMSAddressComponent]?) -> Void)?
    var onAddressSelected: ((GMSAutocompletePrediction? ,GMSPlace?) -> Void)?

    var predic: [GMSAutocompletePrediction] = []
    
    private func getSessionToken() -> GMSAutocompleteSessionToken {
        if sessionToken == nil {
            sessionToken = GMSAutocompleteSessionToken()
        }
        return sessionToken!
    }

    
    var arrSelectedIndex = [Int]()
    
    
    var filterSpeciality = [SpecialityDataModel]()
    var specialities = [SpecialityDataModel]()
    
    var states = [CountryState]()
    var filterStates = [CountryState]()
    
    var reviewTypes: [String] = []
    
    var handler: (([Int]) -> Void)?
    var handlerReview: ((String) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //vwContainer.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
        
        txtSearchBar.delegate = self
        txtSearchBar.addDoneButtonOnKeyboard()
        txtSearchBar.placeholder = "search".localized()
        txtSearchBar.searchTextField.font = UIFont.mySystemFont(ofSize: 16, weight: .regular)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register("MultiSelectCell")
        
        switch type {
        case .specialty: filterSpeciality = specialities
        case .state: filterStates = states
        case .reviewType:
            btnDone.isHidden = true
            heightSearchBar.constant = 0
            txtSearchBar.isHidden = true
        case .location: break
        default: break
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwContainer.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
   
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        handler?(arrSelectedIndex)
        dismiss(animated: true)
    }
    
//    func searchPlaces(searchText: String) {
//        guard !searchText.isEmpty else { return }
//        let request = GMSAutocompleteRequest(query: searchText)
//        let filter = GMSAutocompleteFilter()
//        filter.countries = ["US"]
//        request.filter = filter
//        request.sessionToken = getSessionToken()
//        placesClient.fetchAutocompleteSuggestions(from: request) { [weak self] (results, error) in
//            if let error {
//                println("❌ Error: \(error.localizedDescription)")
//                println("❌ Error domain: \(error as NSError).domain")
//                println("❌ Error code: \(error as NSError).code")
//                println("❌ User info: \(error as NSError).userInfo)")
//                return
//            }
//            guard let results else { return }
//            self?.predictions = results
//            self?.tblView.reloadData()
//        }
//        
//    }
    
    func performSearch(query: String?) {
        guard let text = query, !text.isEmpty else {
            predic = []
            tblView.reloadData()
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.countries = ["USA"]
        placesClient.findAutocompletePredictions(
            fromQuery: text,
            filter: filter,
            sessionToken: GMSAutocompleteSessionToken()
        ) { (results, error) in
            
            if let error {
                print("Error: \(error.localizedDescription)")
                return
            }
            print("total address found = \(results?.count ?? 0)")
            self.predic = results ?? []
            self.tblView.reloadData()
        }
    }
    func searchPlaces(searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.predictions.removeAll()
            self.tblView.reloadData()
            return
        }
        let request = GMSAutocompleteRequest(query: searchText)
        let filter = GMSAutocompleteFilter()
        filter.countries = ["US"] // Make sure this is supported
        request.filter = filter
        request.sessionToken = getSessionToken()
        placesClient.fetchAutocompleteSuggestions(from: request) { [weak self] results, error in
            
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    print("❌ Error:", error.localizedDescription)
                    print("❌ Domain:", error.domain)
                    print("❌ Code:", error.code)
                    print("❌ Full Info:", error.userInfo)
                    
                    // 🔥 Important: catch specific parsing error
                    if error.domain == "com.google.places" {
                        print("⚠️ Possible API mismatch or invalid response format")
                    }
                    return
                }

                guard let results = results else {
                    print("⚠️ No results returned")
                    return
                }

                print("✅ Results count:", results.count)

                self?.predictions = results
                self?.tblView.reloadData()
            }
        }
    }
    
    
   

}

extension BottomSheetMultiSelectionVC: UISearchBarDelegate, UIScrollViewDelegate, UIBarPositioningDelegate {
    
    //MARK: Search bar delegate and dataSource Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar textDidChange")
        // Filter the options based on searchText and update the table view
        switch type {
        case .specialty:
            //let items: [SpecialityDataModel] = items as? [SpecialityDataModel] ?? []
            
            if searchText.count > 0{
                //filteredItems = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) } as! [Item]
                filterSpeciality = specialities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            } else {
                //filteredItems = items as! [Item]
                filterSpeciality = specialities
            }
        case .state:
            if searchText.count > 0 {
                filterStates = states.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }
            } else {
                filterStates = states
            }
        case .location: performSearch(query: searchText)//searchPlaces(searchText: searchText)
        case .reviewType: break
        case .none: break
        }
        tblView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }
    
}

extension BottomSheetMultiSelectionVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: Tableview delegate and dataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return switch type {
        case .specialty: filterSpeciality.count
        case .state: filterStates.count
        case .reviewType: reviewTypes.count
        case .location: predic.count
        default: 0
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectCell") as! MultiSelectCell
        switch type {
        case .specialty:
            cell.lbTitle.text = filterSpeciality[indexPath.row].name;
            if arrSelectedIndex.contains(filterSpeciality[indexPath.row].id) {
                cell.imgSelect.image = .SFSymbol.checkmark
            } else {
                cell.imgSelect.image = nil
            }
        case .state:
            cell.lbTitle.text = filterStates[indexPath.row].name;
            if arrSelectedIndex.contains(filterStates[indexPath.row].id ?? 0) {
                cell.imgSelect.image = .SFSymbol.checkmark
            } else {
                cell.imgSelect.image = nil
            }
        case .reviewType: cell.lbTitle.text = reviewTypes[indexPath.row]
        case .location:
//            cell.lbTitle.attributedText = predictions[indexPath.row].placeSuggestion?.attributedFullText
            cell.lbTitle.attributedText = predic[indexPath.row].attributedFullText
        default: break
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .specialty:
            if arrSelectedIndex.contains(filterSpeciality[indexPath.row].id){
                if let index = arrSelectedIndex.firstIndex(of: filterSpeciality[indexPath.row].id) {
                    arrSelectedIndex.remove(at: index)
                }
            } else {
                arrSelectedIndex.append(filterSpeciality[indexPath.row].id)
            }
        case .state:
            if isMultiSelection {
                if arrSelectedIndex.contains(filterStates[indexPath.row].id ?? 0){
                    if let index = arrSelectedIndex.firstIndex(of: filterStates[indexPath.row].id ?? 0) {
                        arrSelectedIndex.remove(at: index)
                    }
                } else {
                    arrSelectedIndex.append(filterStates[indexPath.row].id ?? 0)
                }
            } else {
                arrSelectedIndex = [filterStates[indexPath.row].id ?? 0]
                handler?(arrSelectedIndex)
                dismiss(animated: true)
            }
        case .reviewType:
            handlerReview?(reviewTypes[indexPath.row])
            dismiss(animated: true)
        case .location:
            let placeID = predic[indexPath.row].placeID
            oldWayGet(placeID: placeID, row: indexPath.row)
            
            //MARK: - new method to get place address
//            guard let placeID = selectedSuggestion?.placeID, !placeID.isEmpty else { return }
//            let fields: GMSPlaceField = [.addressComponents, .formattedAddress]
//            GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { [weak self] (place, error) in
//                if let error {
//                    println("An error occurred: \(error.localizedDescription)")
//                    self?.onAddressSelected?(selectedSuggestion, nil)
//                    return
//                }
//                
//                if let place {
//                    self?.onAddressSelected?(selectedSuggestion, place.addressComponents)
//                }
//            }
            
//            let properties: [String] = [
//                GMSPlaceProperty.all.rawValue,
//                GMSPlaceProperty.formattedAddress.rawValue,
//                GMSPlaceProperty.addressComponents.rawValue,
//            ]
            
//            GMSPlacesClient.shared().fetchPlace(with: request) { [weak self] (place, error) in
//                println("addressComponents \(place as Any)")
//                println("addressComponents \(place?.addressComponents ?? [])")
//                println("Error fetching place: \(error?.localizedDescription ?? "")")
//                if let error {
////                    self?.onAddressSelected?(selectedSuggestion, nil)
//                    self?.onAddressSelected?(self?.predic[indexPath.row], nil)
//                } else if let place {
////                    self?.onAddressSelected?(selectedSuggestion, place.addressComponents)
//                    self?.onAddressSelected?(self?.predic[indexPath.row], place.addressComponents)
//                }
//                self?.dismiss(animated: true)
//            }
            
            
        default: break
        }
        tblView.reloadData()
    }
    
    
    func oldWayGet(placeID: String, row : Int) {
        let properties: [String] = [
            GMSPlaceProperty.formattedAddress.rawValue,
            GMSPlaceProperty.addressComponents.rawValue,
            GMSPlaceProperty.coordinate.rawValue
        ]
        let request = GMSFetchPlaceRequest(
            placeID: placeID,
            placeProperties: properties,
            sessionToken: getSessionToken() // Pass your session token here if using one
        )
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: .all, sessionToken: getSessionToken()) { [weak self] placemark, error in
           
       
            if error != nil {
                self?.onAddressSelected?(self?.predic[row], nil)
            } else {
                self?.onAddressSelected?(self?.predic[row], placemark)
            }
            self?.dismiss(animated: true)
        }
    }
}


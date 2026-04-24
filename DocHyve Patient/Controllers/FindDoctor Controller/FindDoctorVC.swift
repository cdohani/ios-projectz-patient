//
//  FindDoctorVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 01/03/2024.
//

import UIKit
import GoogleMaps
class FindDoctorVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var vwContent: UIView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDocCount: UILabel!
    @IBOutlet weak var lblSort: UILabel!
    @IBOutlet weak var tblDoctorList: UITableView!
    @IBOutlet var vwMapList: GMSMapView!
    @IBOutlet var imgNoData: UIImageView!
    
    @IBOutlet var btnMapList: UIButton!
    @IBOutlet weak var lblMap: UILabel!
    @IBOutlet weak var vwOverlay: UIView!
    @IBOutlet weak var vwAppt: UIView!
    @IBOutlet weak var lblAppHeading: UILabel!
    @IBOutlet weak var lblApptDesc: UILabel!
    @IBOutlet weak var btnBookAppt: UIButton!
    @IBOutlet var vwSortView: UIView!
    @IBOutlet  var btnSort: [UIButton]!
    @IBOutlet var lblRelevance: UILabel!
    @IBOutlet var lblWaitTime: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblReview: UILabel!
    @IBOutlet var imgTick1: UIImageView!
    @IBOutlet var imgTick2: UIImageView!
    @IBOutlet var imgTick3: UIImageView!
    @IBOutlet var imgTick4: UIImageView!
    @IBOutlet var vwLogin: UIView!
    @IBOutlet var lblLoginRequired: UILabel!
    @IBOutlet var lblLoginDesc: UILabel!
    @IBOutlet var btnCancelLogin: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var txtSearchDoctor: AuthTextField!
    
    
    
    //MARK: Variable
    var arrProvider = [SearchDoctorModel]()
    var selectedProviderIndex = -1
    var currentIndex = -1
    var arrAvailableSlot = [Slots]()
    
    var searchQuery = ""
    var selectedStateID = -1
    var selectedInsuranceID = -1
    
    var paginationInfo = PaginationInfoModel()
    var isLoadingMore = false
    
    var selectedSlotID = -1
    var selectedLocationID = -1
    var currentDate = Date()
    
    var selectedSortType = "relevance"
    var newSortType = ""
    
    var isShowingMap = false
    let locationManager = CLLocationManager()
    
    var userLatitude = 0.0
    var userLongitude = 0.0
    var hasCalledSearch = false
    
    var addressLatitude = 0.0
    var addressLongitude = 0.0
    
    var searchTimer: Timer?
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContent.isHidden = true
        customization()
        //searchDoctor()
    }
    
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwAppt.alpha = 0
        vwLogin.alpha = 0
        vwSortView.alpha  = 0
        vwMapList.isHidden = true
        
        
        imgTick2.isHidden = true
        imgTick3.isHidden = true
        imgTick4.isHidden = true
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Enable user location on map
        vwMapList.isMyLocationEnabled = true
        vwMapList.settings.myLocationButton = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwAppt.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
        vwSortView.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    func searchDoctor(){
     
        var param: [String: Any] = [
            "per_page" : 30,
            "page": paginationInfo.currentPage + 1,
            "sort_by": selectedSortType
        ]
        
        if addressLatitude != 0.0 && addressLongitude != 0.0 {
            
            param["latitude"] = addressLatitude
            param["longitude"] = addressLongitude
            
        }else{
            if let location = locationManager.location {
                //TODO: commeting this line of current address to show all doctors will ennable before live
//                param["latitude"] = location.coordinate.latitude
//                param["longitude"] = location.coordinate.longitude
            }
        }
        
        if searchQuery != ""{
            param["query"] = searchQuery
        }
        if selectedStateID != -1{
            param["state_id"] = selectedStateID
        }
        if selectedInsuranceID != -1{
            param["insurance_id"] = selectedInsuranceID
        }
        if !isLoadingMore{
            showLoadingView("")
        }
        SearchDoctorService().searchData(parameters:param,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? SearchDoctorReponseModel
                {
                    if  data.response.status != 200 && data.response.status != 201{
                        self.showAlertView(message: data.response.message)
                    }
                    else{
                        arrProvider.append(contentsOf: data.arrProvider)
                        self.paginationInfo = data.paginationInfo
                        lblDocCount.text = "Providers (\(paginationInfo.totalRecord))"
                        
                        tblDoctorList.reloadData()
                        tblDoctorList.hideLoadingIndicator()
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM-dd-yyyy"

                        let formattedDate = formatter.string(from: currentDate)
                        lblDate.text = "Today \(formattedDate)"
                        
                        addMapPin()
                        vwContent.isHidden = false
                    }
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    func addMapPin() {
        vwMapList.clear()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        var isFirstPin = true

        for item in arrProvider {
            let lat  = Double(item.slotAddress.lat) ?? 0.0
            let long = Double(item.slotAddress.long) ?? 0.0
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)

            // Create marker
            let marker = GMSMarker()
            marker.title = "\(item.firstName) \(item.lastName)"
            marker.position = position
            marker.icon = UIImage(named: "mappin")
            marker.map = vwMapList

            // 👉 Set camera only for the first pin
            if isFirstPin {
                let camera = GMSCameraPosition(latitude: lat, longitude: long, zoom: 12)
                vwMapList.camera = camera
                isFirstPin = false
            }
        }
        
        CATransaction.commit()
    }
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnFilterAction(_ sender: Any) {
        let nextVC = getFilterDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnSortAction(_ sender: Any) {
        vwOverlay.alpha = 0.3
        vwSortView.alpha = 1
    }
    @IBAction func btnMapAction(_ sender: Any) {
        isShowingMap.toggle()
        if isShowingMap {
            lblMap.text = "List"
            tblDoctorList.isHidden = true
            vwMapList.isHidden = false
        }else{
            lblMap.text = "Map"
            tblDoctorList.isHidden = false
            vwMapList.isHidden = true
        }
        
    }
    @IBAction func btnCloseViewAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwAppt.alpha = 0
    }
    @IBAction func btnBookApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwAppt.alpha = 0
        
        
        if let index = arrProvider[selectedProviderIndex].arrAddresses.firstIndex(where: { $0.isDefault == 1 }) {
             selectedLocationID = arrProvider[selectedProviderIndex].arrAddresses[index].id
        }
        
        let nextVC = getBookApptVC()
        nextVC.selectedProviderID = arrProvider[selectedProviderIndex].userId
        nextVC.selectedSlotID = self.selectedSlotID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnViewAllSlotsAction(_ sender: UIButton) {
        let nextVC = getDoctorAvailableSlotsVC()
        nextVC.providerID = arrProvider[sender.tag].userId
        nextVC.selectedStateID = arrProvider[sender.tag].slotAddress.stateID
        nextVC.selectedLocationID = arrProvider[sender.tag].slotAddress.id
        nextVC.currentDate = arrProvider[sender.tag].availableSlots.date.convertIntoDateUsingFormat(format: "yyyy-MM-dd") ?? Date()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnCloseSortAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwSortView.alpha = 0
        if newSortType != selectedSortType{
            selectedSortType = newSortType
            paginationInfo.currentPage = 0
            arrProvider.removeAll()
            searchDoctor()
        }
    }
    
    @IBAction func btnSortSelectionAction(_ sender: UIButton) {
        let sortOptions = ["relevance", "wait_time", "rating","reviews"]
        let tickImages = [imgTick1, imgTick2, imgTick3,imgTick4]

        if sender.tag >= 1 && sender.tag <= sortOptions.count {
            newSortType = sortOptions[sender.tag - 1]
        }

        for (index, tick) in tickImages.enumerated() {
            tick?.isHidden = (index + 1 != sender.tag)
        }
        
    }
    @IBAction func btnCancelLoginAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwLogin.alpha = 0
    }
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func txtSearchDoctorAction(_ sender: Any) {
        searchTimer?.invalidate()  // cancel previous timer
            
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.searchQuery = self!.txtSearchDoctor.text ?? ""
                self?.paginationInfo.currentPage = 0
                self?.arrProvider.removeAll()
                self?.searchDoctor()
            }
    }
  
    
    
    
}
extension FindDoctorVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrProvider.isEmpty{
            tblDoctorList.isHidden = true
            vwMapList.isHidden = true
            imgNoData.isHidden = false
            btnMapList.isEnabled = false
            
        }else{
            tblDoctorList.isHidden = false
//            vwMapList.isHidden = false
            btnMapList.isEnabled = true
            imgNoData.isHidden = true
        }
        return arrProvider.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindDoctorTCell") as! FindDoctorTCell
        cell.SetData(item: arrProvider[indexPath.row])
        cell.btnViewAllSlots.tag = indexPath.row
        cell.onSlotSelected = { [weak self] slotId in
            guard let self = self else { return }
            if isUserLoggedIn(){
                selectedProviderIndex = indexPath.row
                self.selectedSlotID = slotId
                vwOverlay.alpha = 0.3
                vwAppt.alpha = 1
            }else{
                vwOverlay.alpha = 0.3
                vwLogin.alpha = 1
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedProviderIndex = indexPath.row
        let nextVC = FindDoctorVC.getDoctorDetailVC()
            nextVC.providerID = arrProvider[indexPath.row].userId
            nextVC.currentDate = arrProvider[indexPath.row].availableSlots.date.convertIntoDateUsingFormat(format: "yyyy-MM-dd") ?? Date()
            self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == tblDoctorList{
            if indexPath.row == arrProvider.count - 1 {
                if paginationInfo.hasMoreRecord{
                    isLoadingMore = true
                    tblDoctorList.showLoadingIndicator()
                    searchDoctor()
                }
            }
        }
    }
}

extension FindDoctorVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLatitude = location.coordinate.latitude
        userLongitude = location.coordinate.longitude
        
        if !hasCalledSearch {
            hasCalledSearch = true      // <-- ensure only 1 call ever happens
            searchDoctor()
        }
        
        locationManager.stopUpdatingLocation()
    }
       
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Failed to get user location: \(error.localizedDescription)")
       }
}

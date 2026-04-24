//
//  DoctorDetailVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 05/03/2024.
//

import UIKit
import MapKit
import Cosmos
import GoogleMaps
class DoctorDetailVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var vwScrollView: UIScrollView!
    @IBOutlet weak var imgDoctor: UIImageView!
    @IBOutlet weak var lblDoctorName: UILabel!
    @IBOutlet weak var lblSpeciality: UILabel!
    @IBOutlet weak var lblLanguageHeading: UILabel!
    @IBOutlet weak var lblLanguages: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet var imgBookingType: UIImageView!
    @IBOutlet var lblBookingType: UILabel!
    @IBOutlet var lblSeeInNetwork: UILabel!
    
    @IBOutlet weak var lblHighLights: UILabel!
    @IBOutlet weak var vwHighlight: UIView!
    @IBOutlet weak var vwHighlightHeight: NSLayoutConstraint!
    @IBOutlet weak var tblHighlight: UITableView!
    @IBOutlet weak var lblBookAppt: UILabel!
   
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnMoreAvailable: UIButton!
    @IBOutlet weak var cvSlots: UICollectionView!
    @IBOutlet weak var lblOfficeLocation: UILabel!
    @IBOutlet weak var lblOfficeName: UILabel!
    @IBOutlet weak var lblOfficeAddress: UILabel!
    @IBOutlet weak var btnGetDirection: UIButton!
    @IBOutlet weak var lblEducation: UILabel!
    @IBOutlet weak var tblEduction: UITableView!
    @IBOutlet weak var tblEducationHeight: NSLayoutConstraint!
    @IBOutlet weak var lblInNetworkInsurance: UILabel!
    @IBOutlet weak var lblInNetworkDesc: UILabel!
    @IBOutlet weak var cvInsurance: UICollectionView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblOverallRating: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var cvReview: UICollectionView!
    @IBOutlet weak var btnAllReview: UIButton!
    
    @IBOutlet weak var vwOverlay: UIView!
    @IBOutlet weak var vwAppt: UIView!
    @IBOutlet weak var lblAppHeading: UILabel!
    @IBOutlet weak var lblApptDesc: UILabel!
    @IBOutlet weak var btnBookAppt: UIButton!
    
    @IBOutlet var lblCurrentLocation: UILabel!
    @IBOutlet var lblMoreLocation: UILabel!
    
    @IBOutlet var vwLocation: UIView!
    @IBOutlet var txtSearchLocation: UISearchBar!
    @IBOutlet var tblLocation: UITableView!
    
    @IBOutlet var btnFavourit: UIButton!
    
    @IBOutlet var vwLogin: UIView!
    @IBOutlet var lblLoginRequired: UILabel!
    @IBOutlet var lblLoginRequiredDesc: UILabel!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var vwMap: GMSMapView!
    @IBOutlet var btnShareDoctor: UIButton!
    
    
    //MARK: Variable
    var providerID = -1
    var providerData = ProviderDetailModel()
    
    var selectedLocationID = -1
    var selectedStateID = -1
    var fullAddress = ""
    var currentDate = Date()
    
    
   var currentAddressIndex = 0
   var arrSlots = [Slots]()
   var selectedSlotID = -1
    
    var isFavourit = false
    let locationManager = CLLocationManager()
    var currentMarker: GMSMarker?
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwScrollView.isHidden = true
        customization()
        getProviderInfo()
        
    }
   
    override func viewDidAppear(_ animated: Bool) {
        vwHighlightHeight.constant = tblHighlight.contentSize.height + 50
        tblEducationHeight.constant = tblEduction.contentSize.height + 20
        self.view.layoutIfNeeded()
        tblHighlight.isScrollEnabled = false
        tblEduction.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwAppt.makeCornersRound(corners: [.topLeft,.topRight], radius: 15)
    }
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwAppt.alpha = 0
        vwLogin.alpha = 0
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Enable user location on map
        vwMap.isUserInteractionEnabled = false
        vwMap.isMyLocationEnabled = true
        vwMap.settings.myLocationButton = true
        
        if !isUserLoggedIn(){
            btnFavourit.isHidden = true
            btnShareDoctor.isHidden = true
        }
    }
    
    func getProviderInfo(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let formattedDate = formatter.string(from: currentDate)
        showLoadingView("")
        GetProviderDetailService().getData(providerID: providerID, selectedDate: formattedDate, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? ProviderDetailReponseModel
                {
                    providerData = data.providerData
                    tblHighlight.reloadData()
                    tblEduction.reloadData()
                    arrSlots = providerData.availableSlots.slots
                    btnMoreAvailable.isHidden = arrSlots.isEmpty
                    cvSlots.reloadData()
                    cvReview.reloadData()
                    cvInsurance.reloadData()
                    vwScrollView.isHidden = false
//                    if let index = providerData.arrAddresses.firstIndex(where: { $0.isDefault == 1 }) {
//                      selectedLocationID = providerData.arrAddresses[index].id
//                    }
                    tblLocation.reloadData()
                    setScreenData()
                    
                   // getAvailableSlots()
                   
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    
    
    func setScreenData(){
       
        let imageURL = Constants.URLs.imagePath + providerData.providerImage
        imgDoctor.loadImage(from: imageURL)
        lblDoctorName.text = providerData.fullName
        lblSpeciality.text = providerData.specialities.joined(separator: ", ")
        lblLanguages.text = providerData.languages.joined(separator: ", ")
        lblReview.text = "\(providerData.review.averageRating) (\(providerData.review.totalReview) Reviews)"
        lblRating.text = "\(providerData.review.averageRating)"
        vwRating.rating = providerData.review.averageRating
        
         if providerData.bookingType.id == 1 {
            imgBookingType.image = UIImage(systemName: "video.fill")
        }else if  providerData.bookingType.id == 2{
            imgBookingType.image = UIImage(systemName: "person.fill")
        }else{
            imgBookingType.image = UIImage(named: "iconBoth")
        }
        lblBookingType.text = providerData.bookingType.name.capitalized
        lblSeeInNetwork.text = providerData.isInNetwork ? "In Network" : "Out of Network"
        
       
        lblCurrentLocation.text = formattedAddress(from: providerData.slotAddress)
        lblMoreLocation.text = providerData.arrAddresses.count > 1 ? "\(providerData.arrAddresses.count - 1) More Location" : ""
      
        lblDate.text =  providerData.availableSlots.date.convertToDate(format: "dd MMM YYYY",inputFormate: "yyyy-MM-dd")
        
        self.isFavourit = providerData.isFavourite
        
        let imageName = isFavourit ? "favourite" : "unFavourite"
        btnFavourit.setImage(UIImage(named: imageName), for: .normal)
        
        lblOfficeName.text = providerData.practiceName
        
        if !providerData.arrAddresses.isEmpty{
            lblOfficeAddress.text = formattedAddress(from: providerData.arrAddresses[currentAddressIndex])
           
            let lat = Double(providerData.arrAddresses[currentAddressIndex].lat) ?? 0.0
            let long = Double(providerData.arrAddresses[currentAddressIndex].long) ?? 0.0
            addMapPin(lat: lat, long: long)
        }
        
    }
    
   
    func getAvailableSlots(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: currentDate)
        showLoadingView("")
        GetAvailableSlotService().getData(providerID: providerID,addressID:selectedLocationID,date: formattedDate, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? AvailableSlotsResponseModel
                {
                    arrSlots = data.arrSlots
                    cvSlots.reloadData()
                   
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func addMapPin(lat: Double, long: Double) {

        vwMap.clear()

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.icon = UIImage(named: "mappin")
        marker.map = vwMap

        let camera = GMSCameraUpdate.setCamera(
            GMSCameraPosition(latitude: lat, longitude: long, zoom: 12)
        )

        vwMap.animate(with: camera)
    }
    func addFavourit(){
      
        let param: [String: Any] = [
            "provider_id": providerID,
            "is_favorite": !isFavourit,
        ]
        
       let  endPoint =  Constants.URLs.favouritUpdate
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    
                    isFavourit.toggle()
                    let imageName = isFavourit ? "favourite" : "unFavourite"
                    btnFavourit.setImage(UIImage(named: imageName), for: .normal)
                    showToast(message: data.message, controller: self)
                   
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
  
   
 
    @IBAction func btnCloseLocationAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                self.vwOverlay.alpha =  0
                self.vwLocation.alpha = 0
        })
        getAvailableSlots()
    }
    
    @IBAction func btnNextAddressAction(_ sender: Any) {
        if currentAddressIndex < providerData.arrAddresses.count - 1 {
            currentAddressIndex += 1
            lblOfficeAddress.text = formattedAddress(from: providerData.arrAddresses[currentAddressIndex])
            let lat = Double(providerData.arrAddresses[currentAddressIndex].lat) ?? 0.0
            let long = Double(providerData.arrAddresses[currentAddressIndex].long) ?? 0.0
            addMapPin(lat: lat, long: long)
        }
    }
    @IBAction func btnBackAddressAction(_ sender: Any) {
        if currentAddressIndex > 0 {
            currentAddressIndex -= 1
            lblOfficeAddress.text = formattedAddress(from: providerData.arrAddresses[currentAddressIndex])
            let lat = Double(providerData.arrAddresses[currentAddressIndex].lat) ?? 0.0
            let long = Double(providerData.arrAddresses[currentAddressIndex].long) ?? 0.0
            addMapPin(lat: lat, long: long)
        }
    }
    
    
    @IBAction func btnMoreAvailableAction(_ sender: Any) {
        let nextVC = getDoctorAvailableSlotsVC()
        nextVC.providerID = self.providerID
        nextVC.currentDate = self.providerData.availableSlots.date.convertIntoDateUsingFormat(format: "yyyy-MM-dd") ?? Date()
        nextVC.selectedStateID = self.providerData.slotAddress.stateID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnGetDirectionAction(_ sender: Any) {
        
        // Destination coordinates
        let destinationLatitude = Double(providerData.arrAddresses[currentAddressIndex].lat) ?? 0.0
        let destinationLongitude = Double(providerData.arrAddresses[currentAddressIndex].long) ?? 0.0
        let destinationName = "Doctor Clinic"
        
        // 1️⃣ Build Google Maps URL
        let googleMapsURLString = "comgooglemaps://?daddr=\(destinationLatitude),\(destinationLongitude)&directionsmode=driving"
        let googleMapsWebURLString = "https://www.google.com/maps/dir/?api=1&destination=\(destinationLatitude),\(destinationLongitude)&travelmode=driving"
        
        // 2️⃣ Try opening Google Maps first
        if let googleMapsURL = URL(string: googleMapsURLString),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            return
        }
        
        // 3️⃣ Otherwise, open Apple Maps as fallback
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude))
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = destinationName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
        
    }
    @IBAction func btnAllReviewAction(_ sender: Any) {
        let nextVC = getDoctorRatingVC()
        nextVC.providerID = self.providerID
        nextVC.providerName = providerData.fullName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { [self] in
            vwOverlay.alpha = 0
            vwAppt.alpha = 0
        })
        
    }
    @IBAction func btnBookApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwAppt.alpha = 0
        let nextVC = getBookApptVC()
        nextVC.selectedProviderID = self.providerData.userId
        nextVC.selectedSlotID = self.selectedSlotID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
  
    @IBAction func btnFavouritAction(_ sender: Any) {
        addFavourit()
    }
    @IBAction func btnShareAction(_ sender: Any) {
       // https://dochyve.com/doctor
        //https://dochyve.com/en/patient/doctordetails
        let url = URL(string: "https://dochyve.com/en/patient/doctordetails/\(providerID)")!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @IBAction func btnCancelLoginAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwLogin.alpha = 0
    }
    @IBAction func btnloginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
extension DoctorDetailVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblHighlight{
            return 3
        }else if tableView == tblEduction{
            return 6
        }else {
            return providerData.arrAddresses.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblHighlight{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightsTCell") as! HighlightsTCell
            cell.setHighlightData(index: indexPath.row, providerData: providerData)
            
            return cell
        }else if tableView == tblEduction{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationInfoTCell") as! EducationInfoTCell
            cell.setEducationData(index: indexPath.row, providerData: providerData)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSpecialityTCell") as! SelectSpecialityTCell
            
            let address = providerData.arrAddresses[indexPath.row]
            cell.lblTitle.text = formattedAddress(from: address)
            
            if selectedLocationID == address.id{
                cell.imgSelected.image = UIImage(systemName: "checkmark")
            }else{
                cell.imgSelected.image = nil
            }
            return cell
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblLocation{
            let address = providerData.arrAddresses[indexPath.row]
            selectedLocationID = address.id
            selectedStateID = address.stateID
            fullAddress = formattedAddress(from: address)
            lblCurrentLocation.text = fullAddress
            tblLocation.reloadData()
        }
    }
}
extension DoctorDetailVC :UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvSlots{
            if arrSlots.count > 8 {
                return 8
            }else{
                return arrSlots.count
            }
        }else if collectionView == cvInsurance{
            return providerData.arrInsurance.count
        }else{
            return providerData.review.recentReviews.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvSlots{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvialableSlotCCell", for: indexPath) as! AvialableSlotCCell
            cell.lblTime.text = arrSlots[indexPath.row].time
            cell.vwBackground.backgroundColor = arrSlots[indexPath.row].isBooked ? UIColor(named: "customGold") : UIColor(named: "customNavbarColor")
            return cell
        }else if collectionView == cvInsurance{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AcceptedInsuranceCCell", for: indexPath) as! AcceptedInsuranceCCell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewsCCell", for: indexPath) as! ReviewsCCell
            cell.setData(item: providerData.review.recentReviews[indexPath.row])
            return cell
        }
       
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvSlots{
            if isUserLoggedIn(){
                if !arrSlots[indexPath.row].isBooked{
                    selectedSlotID = arrSlots[indexPath.row].id
                    vwOverlay.alpha = 0.3
                    vwAppt.alpha = 1
                }
            }else{
                vwOverlay.alpha = 0.3
                vwLogin.alpha = 1
            }
            
            
        }
       
    }
  
}
extension DoctorDetailVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvSlots{
            let collectionViewWidth = collectionView.bounds.width
            return CGSize(width: collectionViewWidth/4.3, height:40)
        }else if collectionView == cvInsurance{
            return CGSize(width: 60, height:60)
        }else{
            return CGSize(width: 270, height:150)
        }
           
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

//Map Delegate
extension DoctorDetailVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let userLocation = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        let camera = GMSCameraPosition.camera(
            withLatitude: userLocation.latitude,
            longitude: userLocation.longitude,
            zoom: 16
        )

        vwMap.animate(to: camera)

        // Stop updates to save battery (optional)
        locationManager.stopUpdatingLocation()
    }
}

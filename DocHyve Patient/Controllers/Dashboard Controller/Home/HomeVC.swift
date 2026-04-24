//
//  HomeVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 27/02/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
class HomeVC: ParentViewController {

    //MARK: Outlets
    
    @IBOutlet var vwScrollView: UIScrollView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblUserAgeGender: UILabel!
    @IBOutlet var lblUserInsurance: UILabel!
    @IBOutlet var vwNotification: UIView!
    @IBOutlet var lblNotificationCount: UILabel!
    @IBOutlet var btnNotification: UIButton!
    
    
    @IBOutlet weak var vwTopContainer: UIView!
    @IBOutlet weak var txtSearchDoctor: AuthTextField!
    @IBOutlet weak var txtAddress: AuthTextField!
    @IBOutlet weak var txtInsurance: AuthTextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var lblPopularSpecialist: UILabel!
    @IBOutlet weak var cvPopularSpecialist: UICollectionView!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var vwVisitContainer: UIView!
    @IBOutlet weak var lblYourGuide: UILabel!
    @IBOutlet weak var tblLastVisit: UITableView!
    @IBOutlet weak var vwVisitHeight: NSLayoutConstraint!
    @IBOutlet weak var cvRecommendedDoctor: UICollectionView!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwContainer: UIView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var txtSearch: UISearchBar!
    @IBOutlet var tblState: UITableView!
    @IBOutlet var btnViewAllPopularSpeciality: UIButton!
    @IBOutlet var btnClearAll: UIButton!
    @IBOutlet var vwUserInfo: UIView!
    @IBOutlet var vwUserInfoHeight: NSLayoutConstraint!
    @IBOutlet var vwTopContainerHeight: NSLayoutConstraint!
    
    @IBOutlet var btnClearDoctorField: UIButton!
    @IBOutlet var btnClearAddressField: UIButton!
    @IBOutlet var btnClearInsuranceField: UIButton!
    
    
    //MARK: Variable
    var arrSpeciality = [SpecialityResponseModel]()
    var arrRecommendedDoctors = [RecommendedDoctorModel]()
    
    var arrState = [StateModel]()
    var selectedStateIndex = -1
    var arrFilter = [StateModel]()
    
    var arrWellnessGuide = [WellnessGuideModel]()
    var isDefaultAdded = false
    
    var selectedInsuranceID = -1
    
    var dashboardData = DashboardData()
    let locationManager = CLLocationManager()
    
    var isPlaceSearch = false
    var latitude = 0.0
    var longitude = 0.0
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cvHeight.constant = 200
        vwVisitHeight.constant = 530
        setScreenData()
        customization()
        getSpecialityData()
        getRecommendedDoctors()
        getStates()
        if isUserLoggedIn(){
            vwUserInfo.isHidden = false
            vwUserInfoHeight.constant = 65
            vwTopContainerHeight.constant = 385
            getDashboardData()
           
        }else{
            vwUserInfo.isHidden = true
            vwUserInfoHeight.constant = 0
            vwTopContainerHeight.constant = 325
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if HomeDataManager.shared.isHomeUpdated {
            HomeDataManager.shared.isHomeUpdated = false
            if isUserLoggedIn(){
                vwUserInfo.isHidden = false
                vwUserInfoHeight.constant = 65
                vwTopContainerHeight.constant = 385
                getWellnessGuide()
            }else{
                vwUserInfo.isHidden = true
                vwUserInfoHeight.constant = 0
                vwTopContainerHeight.constant = 325
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwTopContainer.makeCornersRound(corners: [.bottomLeft,.bottomRight], radius: 15)
        self.vwContainer.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    //MARK: Functions
    func customization(){
        self.tblLastVisit.isScrollEnabled = false
        self.vwContainer.alpha = 0
        self.vwOverlay.alpha = 0
        
        
        txtSearch.delegate = self
        txtSearch.addDoneButtonOnKeyboard()
        
        btnClearAll.isHidden = true
        btnClearDoctorField.isHidden = true
        btnClearAddressField.isHidden = true
        btnClearInsuranceField.isHidden = true
        
        txtSearchDoctor.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInsurance.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        vwScrollView.addPullToRefresh { refreshControl in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [refreshControl,  self] in
                refreshControl.endRefreshing()
                if isUserLoggedIn(){
                    vwUserInfo.isHidden = false
                    vwUserInfoHeight.constant = 65
                    getWellnessGuide()
                    getDashboardData()
                    getRecommendedDoctors()
                }else{
                    vwUserInfo.isHidden = true
                    vwUserInfoHeight.constant = 0
                    getRecommendedDoctors()
                }
            }
            
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let hasDoctorText = !(txtSearchDoctor.text ?? "").isEmpty
            let hasAddressText = !(txtAddress.text ?? "").isEmpty
            let hasInsuranceText = !(txtInsurance.text ?? "").isEmpty
            
            // Show Clear All if ANY field has text
            btnClearAll.isHidden = !(hasDoctorText || hasAddressText || hasInsuranceText)
            
            // Individual clear buttons
            btnClearDoctorField.isHidden = !hasDoctorText
            btnClearAddressField.isHidden = !hasAddressText
            btnClearInsuranceField.isHidden = !hasInsuranceText
    }
    
    func setScreenData(){
        if isUserLoggedIn(){
            lblUserName.text = dashboardData.userInfo.firstName + " " + dashboardData.userInfo.lastName
            if dashboardData.userInfo.age > 0 {
                lblUserAgeGender.text = "\(dashboardData.userInfo.age) Years -  \(dashboardData.userInfo.gender.capitalized)"
            }else{
                lblUserAgeGender.text = "N/A"
            }
           
            lblNotificationCount.text = "\(dashboardData.notificationCount)"
            vwNotification.isHidden = dashboardData.notificationCount == 0
            
           // vwNotification.isHidden = false
            btnNotification.isHidden = false
            vwVisitContainer.isHidden = false
            vwVisitHeight.constant = 450
            
            if dashboardData.userInfo.singleInsurance != ""{
                lblUserInsurance.text = dashboardData.userInfo.singleInsurance
            }else{
                lblUserInsurance.text  = "N/A"
            }
            if dashboardData.userInfo.isProfileUpdated == 0{
                showAlertViewWithCompletion(message: "Please update your profile to continue") {
                    let nextVC = self.getProfileVC()
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }else{
            lblUserName.text = "Guest User"
            lblUserAgeGender.text = ""
            lblUserInsurance.text = ""
            vwNotification.isHidden = true
            btnNotification.isHidden = true
            vwVisitContainer.isHidden = true
            vwVisitHeight.constant = 0
        }
    }
    func hideShowView(isShow : Bool) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            if isShow{
                self.vwOverlay.alpha = 0.3
                self.vwContainer.alpha = 1
            }else{
                self.vwOverlay.alpha = 0
                self.vwContainer.alpha = 0
               
            }
        })
    }
    func getSpecialityData(){
        showLoadingView("")
        GetPopularSpecialityService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? PopularSpecialityReponseModel
                {
                    self.arrSpeciality = data.arrSpeciality
                    cvPopularSpecialist.reloadData()
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func getRecommendedDoctors(){
        showLoadingView("")
        RecommendedDoctorService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? RecommendedDoctorReponseModel
                {
                    self.arrRecommendedDoctors = data.arrDoctors
                    cvRecommendedDoctor.reloadData()
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getStates(){
        showLoadingView("")
        StateService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? StateReponseModel
                {
                    self.arrState = data.arrState
                    arrFilter = arrState
                    tblState.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func getWellnessGuide(){
        showLoadingView("")
        GetWellGuideService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? WellnessGuideResponseModel
                {
                    self.arrWellnessGuide = data.arrGuide
                    isDefaultAdded = arrWellnessGuide.contains { $0.isDefault == false }
                    DispatchQueue.main.async {
                        self.tblLastVisit.reloadData()
                    }
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getDashboardData(){
        showLoadingView("")
        GetDashboardDataService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? DashboardDataResponseModel
                {
                    dashboardData = data.data
                    setScreenData()
                    getWellnessGuide()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func deleteExamination(id:Int){
        let param: [String: Any] = [
            "examination_id": id
        ]
        
        showLoadingView("")
        let endPoint =  Constants.URLs.deleteCustomExamination
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [weak self] in
                        self?.getWellnessGuide()
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
    
    
    //MARK: ButtonActions
    @IBAction func btnClearAllAction(_ sender: Any) {
        txtSearchDoctor.text = ""
        txtAddress.text = ""
        txtInsurance.text = ""
        latitude = 0.0
        longitude = 0.0
        selectedInsuranceID = -1
        selectedStateIndex = -1
        textFieldDidChange(txtAddress)
    }
    
    
    @IBAction func btnSearchAction(_ sender: Any) {
        let nextVC = getFindDoctorVC()
        nextVC.searchQuery = txtSearchDoctor.text!
        if txtAddress.text != "" {
            nextVC.addressLatitude  =  latitude
            nextVC.addressLongitude = longitude
        }
        nextVC.selectedStateID = self.selectedStateIndex
        nextVC.selectedInsuranceID = self.selectedInsuranceID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnNotificationAction(_ sender: Any) {
        let nextVC = getNotificationVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnSearchConditionAction(_ sender: Any) {
        let nextVC = getSearchConditionVC()
        nextVC.query = txtSearchDoctor.text!
        nextVC.dataDelegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnSelectStateAction(_ sender: Any) {
        self.view.endEditing(true)
        //hideShowView(isShow: true)
        isPlaceSearch = true
        let nextVC = getLocationSearchVC()
        nextVC.queryText = txtAddress.text!
        nextVC.dataDelegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    @IBAction func btnInsuranceAction(_ sender: Any) {
        isPlaceSearch = false
        if isUserLoggedIn(){
            let nextVC = getAddedInsurnaceVC()
            nextVC.isFromMemberScreen = true
            nextVC.dataDelegate = self
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            let nextVC = getInsuranceVC()
            nextVC.dataDelegate = self
            nextVC.searchQuery = txtInsurance.text!
            nextVC.selectedInsuranceID = self.selectedInsuranceID
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    @IBAction func btnCancelAction(_ sender: Any) {
        hideShowView(isShow: false)
    }
    @IBAction func btnDoneAction(_ sender: Any) {
        self.view.endEditing(true)
        if let idx = arrState.firstIndex(where: { $0.id == selectedStateIndex }) {
            txtAddress.text = arrState[idx].name
        }else{
            txtAddress.text = ""
        }
        textFieldDidChange(txtAddress)
        hideShowView(isShow: false)
    }
    @IBAction func btnViewAllPopularSpecialityAction(_ sender: Any) {
        let nextVC = getPopularSpecialitiesVC()
        nextVC.arrSpeciality = arrSpeciality
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnAddExaminationDateAction(_ sender: UIButton) {
        let nextVC = getCustomExaminationVC()
        nextVC.selectedExaminationID = sender.tag
        nextVC.isForEdit = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnAddReminderAction(_ sender: UIButton) {
        let nextVC = getCustomExaminationVC()
        nextVC.selectedExaminationID = sender.tag
        nextVC.isForEdit = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnDeleteReminderAction(_ sender: UIButton) {
        deleteExamination(id: sender.tag)
    }
    
    @IBAction func btnBookAppAction(_ sender: Any) {
        let nextVC = getFindDoctorVC()
        nextVC.searchQuery = txtSearchDoctor.text!
        if txtAddress.text != "" {
            nextVC.addressLatitude  =  latitude
            nextVC.addressLongitude = longitude
        }
        nextVC.selectedStateID = self.selectedStateIndex
        nextVC.selectedInsuranceID = self.selectedInsuranceID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnClearDoctorFieldAction(_ sender: Any) {
        txtSearchDoctor.text = ""
        textFieldDidChange(txtSearchDoctor)
    }
    @IBAction func btnClearAddressFieldAction(_ sender: Any) {
        txtAddress.text = ""
        latitude = 0.0
        longitude = 0.0
        selectedStateIndex = -1
        textFieldDidChange(txtAddress)
    }
    @IBAction func btnClearInsuranceFieldAction(_ sender: Any) {
        txtInsurance.text = ""
        selectedInsuranceID = -1
        textFieldDidChange(txtInsurance)
    }
}
//MARK: CollectionView Datasource
extension HomeVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvPopularSpecialist{
            return arrSpeciality.count > 6 ? 6 : arrSpeciality.count
        }else{
            return arrRecommendedDoctors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvPopularSpecialist{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularDoctorCCell", for: indexPath) as! popularDoctorCCell
            cell.setUpCell(with: arrSpeciality[indexPath.row])
            cvHeight.constant = cvPopularSpecialist.contentSize.height
            self.view.layoutIfNeeded()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedDoctorCCell", for: indexPath) as! RecommendedDoctorCCell
            cell.setUpCell(with: arrRecommendedDoctors[indexPath.row])
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvRecommendedDoctor{
            let nextVC = HomeVC.getDoctorDetailVC()
                nextVC.providerID = arrRecommendedDoctors[indexPath.row].id
//                nextVC.currentDate = arrProvider[indexPath.row].availableSlots.date.convertIntoDateUsingFormat(format: "yyyy-MM-dd") ?? Date()
                self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            let nextVC = getFindDoctorVC()
            nextVC.searchQuery = arrSpeciality[indexPath.row].name
            nextVC.selectedStateID = self.selectedStateIndex
            nextVC.selectedInsuranceID = self.selectedInsuranceID
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    
}


extension HomeVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvPopularSpecialist{
//            let collectionViewWidth = UIScreen.main.bounds.width
//            return CGSize(width: collectionViewWidth/3.2, height:100)
            return CGSize(width: 110, height:110)
        }else{
           
            return CGSize(width: 220, height:150)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

//MARK: Tableview Datasource
extension HomeVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if arrWellnessGuide.isEmpty{
            return 0
        }else{
            return  isDefaultAdded ?   arrWellnessGuide.count:  arrWellnessGuide.count + 1
        }
          
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // EXTRA custom row
         if !isDefaultAdded && indexPath.row == arrWellnessGuide.count {
             let cell = tableView.dequeueReusableCell(withIdentifier: "CustomExaminationTCell") as! CustomExaminationTCell
             return cell
         }

         // NORMAL data rows
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedVisitTCell",for: indexPath ) as! MedVisitTCell

         let item = arrWellnessGuide[indexPath.row]
         cell.setCellData(item: item)
         cell.btnAddExaminationDate.tag = item.id
         cell.btnAddReminder.tag = item.id
         cell.btnDeleteReminder.tag = item.id

         return cell

    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isDefaultAdded && indexPath.row == 3{
            let nextVC = getCustomExaminationVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the options based on searchText and update the table view
        if searchText.count > 0{
            arrFilter = arrState.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }else{
            arrFilter = arrState
        }
        tblState.reloadData()
    }
}

extension HomeVC:TransferDataDelegate{
    
    func sendData(_ data: Any) {
        if  let item = data as? String {
            
            txtSearchDoctor.text = item
            textFieldDidChange(txtSearchDoctor)
        }else{
              if isPlaceSearch{
                  if  let item = data as? GoogleLocationModel {
                      
                      txtAddress.text = item.placeAddress
                      latitude = item.latitude
                      longitude = item.longitude
                  }
                  textFieldDidChange(txtAddress)
              }else{
                  if  let item = data as? UserInsuranceModel {
                      selectedInsuranceID = item.insuranceID
                      txtInsurance.text = item.insuranceName
                  }
                  else if let item = data as? InsuranceModel {
                      selectedInsuranceID = item.id
                      txtInsurance.text = item.name
                  }
                  textFieldDidChange(txtInsurance)
              }
          }

        
    }
}


extension HomeVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        _ = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        locationManager.stopUpdatingLocation()
    }
}

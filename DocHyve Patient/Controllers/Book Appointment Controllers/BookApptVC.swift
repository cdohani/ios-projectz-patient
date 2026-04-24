//
//  BookApptVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 11/03/2024.
//

import UIKit

class BookApptVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgDoctor: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSpeciality: UILabel!
    @IBOutlet weak var lblTiming: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPatientInfoHeading: UILabel!
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblNewPatient: UILabel!
    @IBOutlet var btnPatient: [UIButton]!
    @IBOutlet weak var btnElseLooking: UIButton!
    @IBOutlet weak var lblAddInsurance: UILabel!
    @IBOutlet weak var btnAddInsurance: UIButton!
    @IBOutlet weak var vwInsuranceInfo: UIView!
    @IBOutlet weak var lblInsurance: UILabel!
    @IBOutlet weak var lblInsurancePlan: UILabel!
   
    @IBOutlet weak var lblAgreement: UILabel!
    @IBOutlet weak var btnBookAppt: UIButton!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwReason: UIView!
    @IBOutlet var txtSearchReason: UISearchBar!
    @IBOutlet var tblReason: UITableView!
    @IBOutlet var txtReason: AuthTextField!
    @IBOutlet var vwFamilyMembers: UIView!
    @IBOutlet var lblSelectFamilyMember: UILabel!
    @IBOutlet var btnAddFamilyMember: UIButton!
    @IBOutlet var tblFamilyMember: UITableView!
    @IBOutlet var vwOtherPatient: UIView!
    @IBOutlet var lblOtherPatientName: UILabel!
    @IBOutlet weak var btnRemoveInsurance: UIButton!
    @IBOutlet var vwAddInsurance: UIView!
    @IBOutlet var lblSelectInsurance: UILabel!
    @IBOutlet var tblInsurance: UITableView!
    @IBOutlet var btnAddNewInsurance: UIButton!
    @IBOutlet var vwAppointmentType: UIView!
    @IBOutlet var  btnAppointmentType: [UIButton]!
    @IBOutlet var lblInPerson: UILabel!
    @IBOutlet var lblVideoVisit: UILabel!
    @IBOutlet var vwAppointmentTypeHeight: NSLayoutConstraint!
    @IBOutlet var vwBookingContainerHeight: NSLayoutConstraint!
    @IBOutlet var txtAppointmentReason: UITextField!
    @IBOutlet var lblContactInfo: UILabel!
    @IBOutlet var lblPhoneHeading: UILabel!
    @IBOutlet var lblPhoneNo: UILabel!
    @IBOutlet var btnAddPhoneNo: UIButton!
    @IBOutlet var lblNoRecordFamily: UILabel!
    @IBOutlet var lblNoRecordInsurance: UILabel!
    
    
    //MARK: Variable
    var selectedProviderID = -1
    var selectedSlotID = -1
    var arrVisitReason = [DropDownModel]()
    var arrAllVisitReason = [DropDownModel]()
    var selectedReasonID = -1
    
    var isNewPateint = true
    
    var appointmentDetail = AppointmentInfoDetailResponseModel()
  
    var validator: Validator!
    
    var arrMembers = [MemberDetailModel]()
    var selectedMemberID = -1
    
    var selectedInsurance = UserInsuranceModel()
    
    var arrInsuranceData = [UserInsuranceModel]()
    var selectedInsuranceID = -1
    
    var selectedBookingType = "in-person"
    var userName = UserDefaults.standard.string(forKey: "userName")
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        customization()
        getAppointmentDetail()
       
       
    }
    override func viewWillAppear(_ animated: Bool) {
        getVisitReason()
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            getAppointmentDetail()
            getVisitReason()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwFamilyMembers.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
        vwReason.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
        vwAddInsurance.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    //MARK: Functions
    func customization(){
        vwInsuranceInfo.alpha = 0
        vwReason.alpha = 0
        vwOverlay.alpha = 0
        vwFamilyMembers.alpha = 0
        vwOtherPatient.alpha = 0
        btnRemoveInsurance.alpha = 0
        vwAddInsurance.alpha = 0
        validateTextField()
        txtSearchReason.delegate = self
        txtSearchReason.addDoneButtonOnKeyboard()
       
    }
   
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtReason, rules: [.minLength(1)])
        txtReason.emptyErrorText = Constants.TextFieldError.emptyString
    }
    func getAppointmentDetail(){
        showLoadingView("")
        GetAppointmentDetailService().getData(providerId: selectedProviderID,slotID: selectedSlotID,completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? AppointmentInfoDetailResponseModel
                {
                    appointmentDetail = data
                    setScreenData()
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
        
        let imageURL = Constants.URLs.imagePath + appointmentDetail.providerInfo.providerImage
        imgDoctor.loadImage(from: imageURL)
        lblDocName.text = appointmentDetail.providerInfo.fullName
        lblPatientName.text = userName
        lblPhoneNo.text = appointmentDetail.patientPhoneNo == "" ? "N/A" : appointmentDetail.patientPhoneNo
        lblType.text = appointmentDetail.providerInfo.practiceRole
        lblSpeciality.text = appointmentDetail.providerInfo.specialities.compactMap { $0.name }.joined(separator: ", ")
        
        lblAddress.text = "\(appointmentDetail.slotInfo.address) \(appointmentDetail.slotInfo.address2) \(appointmentDetail.slotInfo.city)  \(appointmentDetail.slotInfo.zipCode)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-dd-yyyy"
        let slotDate = appointmentDetail.slotInfo.slotDate.convertToDate(format: "MMM-dd-yyyy")
        
        lblTiming.text = "\(String(describing: slotDate!)) - \(appointmentDetail.slotInfo.startTime)"
        
        if appointmentDetail.providerInfo.bookingType.id == "3"{
            vwAppointmentType.alpha = 1
            vwAppointmentTypeHeight.constant = 55
            vwBookingContainerHeight.constant = 280
        }else{
            selectedBookingType = appointmentDetail.providerInfo.bookingType.id == "1" ? "video" : "in-person"
            print(selectedBookingType)
            vwAppointmentType.alpha = 0
            vwAppointmentTypeHeight.constant = 0
            vwBookingContainerHeight.constant = 225
        }

    }
    func getVisitReason(){
        showLoadingView("")
        GetIllnessService().getData(doctorID: selectedProviderID, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? DropDownResponseModel
                {
                    
                    arrAllVisitReason = data.arrData
                    arrVisitReason = arrAllVisitReason
                    tblReason.reloadData()
                    getMembers()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getMembers(){
        showLoadingView("")
        GetMemberService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MemberReponseModel
                {
                    self.arrMembers = data.arrMembers
                    tblFamilyMember.reloadData()
                    getInsurance()

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func getInsurance(){
        showLoadingView("")
        GetUserInsuranceService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? UserInsuranceReponseModel
                {
                    self.arrInsuranceData = data.arrData
                    tblInsurance.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func bookAppoinment(){
      
        var param: [String: Any] = [
            "slot_id": selectedSlotID,
            "provider_id": selectedProviderID,
            "reason": txtAppointmentReason.text!,
            "illness_id": selectedReasonID,
            "insurance_id": selectedInsuranceID,
            "booking_type": selectedBookingType,
            "is_new_patient": isNewPateint,
        ]
        if selectedMemberID != -1{
            param["member_id"] = selectedMemberID
        }
        let endPoint =  Constants.URLs.bookAppointment
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        let nextVC = self.getSurvyVC()
                        self.navigationController?.pushViewController(nextVC, animated: true)
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
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnPatientTypeAction(_ sender: UIButton) {
        for button in btnPatient {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        
        isNewPateint = sender.tag == 1 ? true : false
       
    }
    @IBAction func btnElseLookingAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0.3
            self.vwFamilyMembers.alpha = 1
        })
    }
    @IBAction func btnAddInsuranceAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0.3
            self.vwAddInsurance.alpha = 1
        })
    }
    
 
    @IBAction func btnBookApptAction(_ sender: Any) {
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.bookAppoinment()
            }
        }
    }
    
    @IBAction func btnShowReason(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0.3
            self.vwReason.alpha = 1
        })
    }
    
    @IBAction func btnCloseReasonAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0
            self.vwReason.alpha = 0
        })
    }
    
    @IBAction func btnCloseFamilyMember(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0
            self.vwFamilyMembers.alpha = 0
        })
        if selectedMemberID != -1{
            vwOtherPatient.alpha = 1
            btnElseLooking.alpha = 0
        }
    }
    @IBAction func btnAddFamilyMemberAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0
            self.vwFamilyMembers.alpha = 0
            
            let nextVC = self.getAddedMemberVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        })
    }
    @IBAction func btnRemoveOtherPatient(_ sender: Any) {
        vwOtherPatient.alpha = 0
        btnElseLooking.alpha = 1
        selectedMemberID = -1
        tblFamilyMember.reloadData()
    }
    @IBAction func btnRemoveInsuranceAction(_ sender: Any) {
        selectedInsurance = UserInsuranceModel()
        vwInsuranceInfo.alpha = 0
        btnAddInsurance.alpha = 1
        btnRemoveInsurance.alpha = 0
    }
    @IBAction func btnCloseInsuranceView(_ sender: Any) {
        vwAddInsurance.alpha = 0
        vwOverlay.alpha = 0
        if selectedInsuranceID != -1{
            vwInsuranceInfo.alpha = 1
            btnAddInsurance.alpha = 0
            btnRemoveInsurance.alpha = 1
        }
    }
    @IBAction func btnAddNewInsuranceAction(_ sender: Any) {
        vwAddInsurance.alpha = 0
        vwOverlay.alpha = 0
        let nextVC = getAddedInsurnaceVC()
        nextVC.isFromMemberScreen = true
        nextVC.dataDelegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnSelectInsuranceType(_ sender: UIButton) {
        for button in btnAppointmentType {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        selectedBookingType = sender.tag == 1 ? "in-person" : "video"
    }
    @IBAction func btnAddPhoneNoAction(_ sender: Any) {
        let nextVC = getPhoneNoVC()
        nextVC.isFromBooking = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}

extension BookApptVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblReason{
            return arrVisitReason.count
        }else if tableView == tblFamilyMember{
            lblNoRecordFamily.isHidden = arrMembers.isEmpty ? false : true
            return arrMembers.count
        }else{
            lblNoRecordInsurance.isHidden = arrInsuranceData.isEmpty ? false : true
            return arrInsuranceData.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblReason{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSpecialityTCell") as! SelectSpecialityTCell
            
            cell.lblTitle.text = arrVisitReason[indexPath.row].name
            
            if selectedReasonID == arrVisitReason[indexPath.row].id{
                cell.imgSelected.image = UIImage(systemName: "checkmark")
            }else{
                cell.imgSelected.image = nil
            }
            return cell
        }else if tableView == tblFamilyMember{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberTCell") as! SelectMemberTCell
            cell.setData(item: arrMembers[indexPath.row])
            if selectedMemberID == arrMembers[indexPath.row].id{
                cell.vwContainer.borderColor = UIColor(named: "customBlueColor")
                cell.imgSelection.isHidden = false
            }else{
                cell.vwContainer.borderColor = UIColor(named: "customTFBorderColor")
                cell.imgSelection.isHidden = true
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberTCell") as! SelectMemberTCell
            cell.setInsuranceData(item: arrInsuranceData[indexPath.row])
            if selectedInsuranceID == arrInsuranceData[indexPath.row].id{
                cell.vwContainer.borderColor = UIColor(named: "customBlueColor")
                cell.imgSelection.isHidden = false
            }else{
                cell.vwContainer.borderColor = UIColor(named: "customTFBorderColor")
                cell.imgSelection.isHidden = true
            }
            return cell
        }
      

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblReason{
            selectedReasonID = arrVisitReason[indexPath.row].id
            txtReason.text = arrVisitReason[indexPath.row].name
            tblReason.reloadData()
        }else if tableView == tblFamilyMember{
            selectedMemberID = arrMembers[indexPath.row].id
            lblOtherPatientName.text = arrMembers[indexPath.row].firstName + " " + arrMembers[indexPath.row].lastName
            tblFamilyMember.reloadData()
        }else{
            selectedInsuranceID = arrInsuranceData[indexPath.row].id
            lblAddInsurance.text = "Your Insurance"
            let plans = arrInsuranceData[indexPath.row].arrPlan.map { $0.name }.joined(separator: " - ")
            lblInsurance.text = arrInsuranceData[indexPath.row].insuranceName
            lblInsurancePlan.text = plans
            tblInsurance.reloadData()
        }
       
    }
    
}

extension BookApptVC:TransferDataDelegate{
    func sendData(_ data: Any) {
        if  let item = data as? UserInsuranceModel {
            selectedInsurance = item
            selectedInsuranceID = item.id
            vwInsuranceInfo.alpha = 1
            btnAddInsurance.alpha = 0
            btnRemoveInsurance.alpha = 1
            
            lblAddInsurance.text = "Your Insurance"
            let plans = item.arrPlan.map { $0.name }.joined(separator: " - ")
            lblInsurance.text = item.insuranceName
            lblInsurancePlan.text = plans
        }
    }
}

extension BookApptVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the options based on searchText and update the table view
        if searchText.count > 0{
            arrVisitReason = arrAllVisitReason.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }else{
            arrVisitReason = arrAllVisitReason
        }
        tblReason.reloadData()
    }
}

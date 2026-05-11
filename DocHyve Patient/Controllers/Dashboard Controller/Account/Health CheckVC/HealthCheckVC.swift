//
//  HealthCheckVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class HealthCheckVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblHealth: UITableView!
    @IBOutlet weak var btnViewHealth: UIButton!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet var txtMember: AuthTextField!
    @IBOutlet var btnClear: UIButton!
    @IBOutlet var vwConsent: UIView!
    @IBOutlet var btnAgree: UIButton!
    @IBOutlet var lblConsent: UILabel!
    @IBOutlet var lblSelectMember: UILabel!
    @IBOutlet var vwInfo: UIView!
    
    //MARK: Variable
    var arrData = [HealthCheckModel]()
    var arrMember = [MemberDetailModel]()
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    var currentMemberID : Int?
    var isAggrementCheck = false
    var accountUserName = UserDefaults.standard.string(forKey: "userName") ?? ""
    var currentSelectedName = ""
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSelectedName = accountUserName
        customization()
    }
    override func viewWillAppear(_ animated: Bool) {
        if  DataManager.shared.isDataUpdated {
            DataManager.shared.isDataUpdated = false
            getHealthData(memberId: currentMemberID)
        }
    }
  
    func customization(){
        if isUserLoggedIn(){
            txtMember.text = accountUserName + " (Self)"
            vwContainer.isHidden = true
            txtMember.isHidden = false
            tblHealth.isHidden = false
            btnViewHealth.isHidden = false
            vwConsent.isHidden = false
            lblSelectMember.isHidden = false
            vwInfo.isHidden = false
            getMembers()
           
        }else{
            vwContainer.isHidden = false
            tblHealth.isHidden = true
            btnViewHealth.isHidden = true
            txtMember.isHidden = true
            vwConsent.isHidden = true
            lblSelectMember.isHidden = true
            vwInfo.isHidden = true

        }
        setupPickerView()
    }
    //MARK: Functions
    func getHealthData(memberId: Int?){
    
        showLoadingView("")
        let endPoint = Constants.URLs.getHealthCheckHistory
        GetHealthCheckHistoryService().getData(memberID: currentMemberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel
                {
                    self.arrData = data.arrData
                    isAggrementCheck = data.healthConsentInfo.consentGiven
                    let imageName = isAggrementCheck ? "iconCheck" : "uncheck"
                    btnAgree.setImage(UIImage(named: imageName), for: .normal)
                    tblHealth.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        txtMember.delegate = self
        txtMember.inputView = pickerView
        txtMember.inputAccessoryView = toolbar
        // Toolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    @objc func doneTapped() {
         let row = pickerView.selectedRow(inComponent: 0)
        txtMember.text = arrMember[row].firstName + " " + arrMember[row].lastName
        currentMemberID = row == 0 ? nil :arrMember[row].id
        txtMember.resignFirstResponder()
        getHealthData(memberId: currentMemberID )
        btnClear.isUserInteractionEnabled = false
        currentSelectedName = row == 0 ? accountUserName :txtMember.text!
     }
     
     @objc func cancelTapped() {
         txtMember.resignFirstResponder()
     }
    
    func getMembers(){
        showLoadingView("")
        GetMemberService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MemberReponseModel
                {
                    self.arrMember = data.arrMembers
                    var adminUser = MemberDetailModel()
                    adminUser.firstName = accountUserName
                    adminUser.lastName = "(Self)"
                    adminUser.relationship = "Self"
                    arrMember.insert(adminUser, at: 0)
                    pickerView.reloadAllComponents()
                    getHealthData(memberId: currentMemberID)

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func saveHealthConsent(){
        let param: [String: Any] = [
            "consent_type" : "share_medical_info",
            "consent_given" : isAggrementCheck,
        ]
        let endPoint =  Constants.URLs.saveHealthConsent
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel{
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
    @IBAction func btnViewHealthAction(_ sender: Any) {
        let nextVC = getAllHealthCheckVC()
        nextVC.memberID = currentMemberID
        nextVC.currentUserName = currentSelectedName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnFindDoctorAction(_ sender: Any) {
//        if let parent = self.parent as? DashboardVC {
//            parent.selectTab(index: 0)
//        }
        let nextVC = getFindDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnClearAction(_ sender: UIButton) {
        txtMember.text = ""
        currentMemberID = nil
        currentSelectedName = accountUserName
        getHealthData(memberId: currentMemberID)
        btnClear.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        btnClear.isUserInteractionEnabled = false
    }
    @IBAction func btnAgreeAction(_ sender: Any) {
        isAggrementCheck.toggle()
        let imageName = isAggrementCheck ? "iconCheck" : "uncheck"
        btnAgree.setImage(UIImage(named: imageName), for: .normal)
        saveHealthConsent()
    }
    @IBAction func btnViewPolicyAction(_ sender: Any) {
    }
}
extension HealthCheckVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthCheckTCell") as! HealthCheckTCell
        cell.setData(item: arrData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrData[indexPath.row]

        switch item.id {
        case 1:
            let nextVC = getMedicalHistoryVC()
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 2:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .surgicalHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 3:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .allergyHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 4:
            let nextVC = getAddedMedicationVC()
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 5:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .familyHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 6:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .socialHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        default:
            break
        }
    }
    
}
extension HealthCheckVC: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UIPickerViewDataSource
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return arrMember.count
     }

     // MARK: - UIPickerViewDelegate
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return  "\(arrMember[row].firstName) \(arrMember[row].lastName)"
     }
}
extension HealthCheckVC : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtMember{
            return false
        }
        return true
    }
}

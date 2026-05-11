//
//  AddNewMedicationVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 18/03/2024.
//

import UIKit

class AddNewMedicationVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblMedicineName: UILabel!
    @IBOutlet weak var txtMedicineName: AuthTextField!
    @IBOutlet weak var lblDosageUsage: UILabel!
    @IBOutlet weak var lblDosageDesc: UILabel!
    @IBOutlet weak var txtDosage: AuthTextField!
    @IBOutlet weak var txtUsage: AuthTextField!
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var lblFreqDesc: UILabel!
    @IBOutlet weak var txtFrequency: AuthTextField!
    @IBOutlet weak var lblReason: UILabel!
    @IBOutlet weak var txtReasonDesc: UILabel!
    @IBOutlet weak var txtReason: AuthTextField!
    @IBOutlet weak var btnAddMedication: UIButton!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwDropdown: UIView!
    @IBOutlet var btnCancelDropdown: UIButton!
    @IBOutlet var btnDoneDropdown: UIButton!
    @IBOutlet var txtSearchDrop: UISearchBar!
    @IBOutlet var tblDropdown: UITableView!
    
    
    
    //MARK: Variable
    var validator: Validator!
    var isForEdit = false
    var medicineInfo = MedicineDetailModel()
    var arrUsage = [String]()
    var arrDosage = [String]()
    var arrFrequency = [String]()
    var selectedUsageIndex = ""
    var selectedDosageIndex = ""
    var selectedFrequencyIndex = ""
    
    var showDosage = false
    var showUsage = false
    var showFrequency = false
    
    var filteredUsage: [String] = []
    var filteredDosage: [String] = []
    var filteredFrequency: [String] = []
    
    var memberID : Int?
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        customization()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwDropdown.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
 
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwDropdown.alpha = 0
        
        validateTextField()
        getMedicationDropdown()
        txtSearchDrop.delegate = self
        txtSearchDrop.addDoneButtonOnKeyboard()
        
    }
    
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtMedicineName, rules: [.minLength(1)])
        validator.add(textField: txtDosage, rules: [.minLength(1)])
        validator.add(textField: txtUsage, rules: [.minLength(1)])
        validator.add(textField: txtFrequency, rules: [.minLength(1)])
        validator.add(textField: txtReason, rules: [.minLength(1)])
        
        txtMedicineName.emptyErrorText =  Constants.TextFieldError.emptyString
        txtDosage.emptyErrorText = Constants.TextFieldError.emptyString
        txtUsage.emptyErrorText = Constants.TextFieldError.emptyString
        txtFrequency.emptyErrorText = Constants.TextFieldError.emptyString
        txtReason.emptyErrorText = Constants.TextFieldError.emptyString
    }
    func setScreenData(){
        txtMedicineName.text = medicineInfo.medication
        txtDosage.text = medicineInfo.dosage
        txtUsage.text = medicineInfo.duration
        txtFrequency.text = medicineInfo.frequency
        txtReason.text = medicineInfo.reason
        
        selectedUsageIndex = medicineInfo.duration//arrUsage.firstIndex(of: medicineInfo.duration) ?? -1
        selectedDosageIndex = medicineInfo.dosage//arrDosage.firstIndex(of: medicineInfo.dosage) ?? -1
        selectedFrequencyIndex = medicineInfo.frequency//arrFrequency.firstIndex(of: medicineInfo.frequency) ?? -1
    }
    
    func getMedicationDropdown(){
        showLoadingView("")
        let endPoint = Constants.URLs.getMedicationScreenData
        GetMedicationDataService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MedicationDropdownReponseModel
                {
                    self.arrDosage = data.arrDosage
                    self.arrUsage = data.arrUsage
                    self.arrFrequency = data.arrFrequency
                    
                    filteredUsage = arrUsage
                    filteredDosage = arrDosage
                    filteredFrequency = arrFrequency
                    
                    tblDropdown.reloadData()
                    if isForEdit{
                        setScreenData()
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
    
    func saveData(){

        var param: [String: Any] = [
            "medication": txtMedicineName.text!,
            "dosage": txtDosage.text!,
            "duration": txtUsage.text!,
            "frequency": txtFrequency.text!,
            "reason": txtReason.text!,
        ]
        if isForEdit{
            param["id"] = medicineInfo.id
        }
        if let memId = memberID{
            param["member_id"] = memberID
        }
       let  endPoint = isForEdit ?  Constants.URLs.updateMedicationHistory : Constants.URLs.saveMedicationHistory
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popViewController(animated: true)
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
    func safeValue(from array: [String], index: Int) -> String? {
        guard index >= 0 && index < array.count else { return nil }
        return array[index]
    }
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDosageAction(_ sender: Any) {
        view.endEditing(true)
        showFrequency = false
        showUsage = false
        showDosage = true
        tblDropdown.reloadData()
        vwOverlay.alpha = 0.3
        vwDropdown.alpha = 1
    }
    @IBAction func btnUsageAction(_ sender: Any) {
        view.endEditing(true)
        showFrequency = false
        showUsage = true
        showDosage = false
        tblDropdown.reloadData()
        vwOverlay.alpha = 0.3
        vwDropdown.alpha = 1
    }
    @IBAction func btnFrequencyAction(_ sender: Any) {
        view.endEditing(true)
        showFrequency = true
        showUsage = false
        showDosage = false
        tblDropdown.reloadData()
        vwOverlay.alpha = 0.3
        vwDropdown.alpha = 1
    }
    
    
    @IBAction func btnAddMedicationAction(_ sender: Any) {
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.saveData()
            }
        }
    }
    @IBAction func btnCancelDropAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwDropdown.alpha = 0
    }
    @IBAction func btnDoneDropAction(_ sender: Any) {
        if showUsage {
            txtUsage.text = selectedUsageIndex//safeValue(from: filteredUsage, index: selectedUsageIndex)
        } else if showDosage {
            txtDosage.text = selectedDosageIndex//safeValue(from: filteredDosage, index: selectedDosageIndex)
        } else {
            txtFrequency.text = selectedFrequencyIndex//safeValue(from: filteredFrequency, index: selectedFrequencyIndex)
        }
        vwOverlay.alpha = 0
        vwDropdown.alpha = 0
    }

}

extension AddNewMedicationVC: UITableViewDelegate, UITableViewDataSource {
    
    private var currentArray: [String] {
        if showUsage { return filteredUsage }
        if showDosage { return filteredDosage }
        return filteredFrequency
    }
    
    private var selectedIndex: String {
        get {
            if showUsage { return selectedUsageIndex }
            if showDosage { return selectedDosageIndex }
            return selectedFrequencyIndex
        }
        set {
            if showUsage { selectedUsageIndex = newValue }
            else if showDosage { selectedDosageIndex = newValue }
            else { selectedFrequencyIndex = newValue }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateTCell", for: indexPath) as! StateTCell
        let isSelected = currentArray[indexPath.row] == selectedIndex
        
        cell.lblTitle.text = currentArray[indexPath.row]
        cell.imgSelected.image = isSelected ? UIImage(systemName: "checkmark") : nil
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = currentArray[indexPath.row]
        tblDropdown.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            txtSearchDrop.text = ""
            view.endEditing(true)
            if showUsage {
                
                txtUsage.text = selectedUsageIndex//safeValue(from: filteredUsage, index: selectedUsageIndex)
            } else if showDosage {
                txtDosage.text = selectedDosageIndex//safeValue(from: filteredDosage, index: selectedDosageIndex)
            } else {
                txtFrequency.text = selectedFrequencyIndex//safeValue(from: filteredFrequency, index: selectedFrequencyIndex)
            }
            filteredUsage = arrUsage
            filteredDosage = arrDosage
            filteredFrequency = arrFrequency
            
            vwOverlay.alpha = 0
            vwDropdown.alpha = 0
        }
    }
}

extension AddNewMedicationVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            filteredUsage = arrUsage
            filteredDosage = arrDosage
            filteredFrequency = arrFrequency
        } else {
            if showUsage {
                filteredUsage = arrUsage.filter {
                    $0.localizedCaseInsensitiveContains(searchText)
                }
            } else if showDosage {
                filteredDosage = arrDosage.filter {
                    $0.localizedCaseInsensitiveContains(searchText)
                }
            } else {
                filteredFrequency = arrFrequency.filter {
                    $0.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        tblDropdown.reloadData()
    }

}
        
       
    


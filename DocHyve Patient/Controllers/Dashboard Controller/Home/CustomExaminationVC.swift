//
//  CustomExaminationVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 27/02/2024.
//

import UIKit

class CustomExaminationVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblCustomExamination: UILabel!
    @IBOutlet weak var lblSelectExamination: UILabel!
    @IBOutlet weak var txtCustomExamination: AuthTextField!
    @IBOutlet weak var lblInfoHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
  
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var txtFrequency: AuthTextField!
    @IBOutlet weak var btnSave: UIButton!
    
    
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPastApptDate: UILabel!
    @IBOutlet weak var txtPastAppt: AuthTextField!
    @IBOutlet weak var lblSelectTime: UILabel!
    @IBOutlet weak var txtStartTime: AuthTextField!
    @IBOutlet weak var txtEndTime: AuthTextField!
    @IBOutlet weak var lblReminderOption1: UILabel!
    @IBOutlet var btnReminder: [UIButton]!
    @IBOutlet weak var lblSms: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblBoth: UILabel!
    
    @IBOutlet var lblOption2: UILabel!
    
    @IBOutlet var btnReminderSequence: [UIButton]!
    @IBOutlet weak var lblOneDay: UILabel!
    @IBOutlet weak var lblTwoDay: UILabel!
    @IBOutlet weak var lblThreeDay: UILabel!
    
    @IBOutlet weak var vwOverlay: UIView!
    @IBOutlet weak var vwDataConatiner: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tblExaminationData: UITableView!
    @IBOutlet var btnSelectExamination: UIButton!
    
    
    //MARK: Variable
    var option1 = "SMS"
    var selectedReminderID = 1
    var allData =  ExaminationResponseModel()
    var isExamination = true
    var selectedExaminationID = -1
    var selectedFrequencyID = -1
    
    var validator: Validator!
    var isForEdit = false
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        customization()
        getExaminationData()
        validateTextField()
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vwDataConatiner.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    
    
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwDataConatiner.alpha = 0
        if isForEdit{
            txtCustomExamination.rightImage = nil
        }
    }
    
    func validateTextField() {
        validator = Validator(withView: self.view)
        
        validator.add(textField: txtCustomExamination, rules: [.minLength(1)])
        if btnSwitch.isOn{
            validator.add(textField:txtPastAppt , rules: [.minLength(1)])
            validator.add(textField:txtStartTime , rules: [.minLength(1)])
            validator.add(textField:txtEndTime , rules: [.minLength(1)])
            validator.add(textField:txtFrequency , rules: [.minLength(1)])
            
        }else{
            validator.removeRules(textField:txtPastAppt)
            validator.removeRules(textField:txtStartTime )
            validator.removeRules(textField:txtEndTime )
            validator.removeRules(textField:txtFrequency)
        }
        
    
        txtCustomExamination.emptyErrorText = Constants.TextFieldError.emptyString
        txtPastAppt.emptyErrorText = Constants.TextFieldError.emptyString
        txtStartTime.emptyErrorText = Constants.TextFieldError.emptyString
        txtEndTime.emptyErrorText = Constants.TextFieldError.emptyString
        txtFrequency.emptyErrorText = Constants.TextFieldError.emptyString
    }
    
   
    func getExaminationData(){
        showLoadingView("")
        GetExaminationListService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? ExaminationResponseModel
                {
                    self.allData = data
                    if isForEdit{
                        txtCustomExamination.text = allData.arrExamination.first(where: { $0.id == selectedExaminationID })?.name
                        btnSelectExamination.isUserInteractionEnabled = false
                    }else{
                        btnSelectExamination.isUserInteractionEnabled = true
                    }
                    tblExaminationData.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func saveCustomExamination(){
        var param: [String: Any] = [
            "examination_id": selectedExaminationID,
        ]
        
        let reminder: [String: Any] = [
            "reminder_day_option_id": selectedReminderID,
            "date": txtPastAppt.text ?? "",
            "start_time": txtStartTime.text ?? "",
            "end_time": txtEndTime.text ?? "",
            "reminder_options": option1,
           // "notified": btnSwitch.isOn,
            "future_date_frequency_id": selectedFrequencyID
        ]
        
        param["reminder"] = reminder
        
        
        let endPoint =  Constants.URLs.saveCustomExamination
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        HomeDataManager.shared.isHomeUpdated = true
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
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSelectExamination(_ sender: Any) {
        isExamination = true
        vwOverlay.alpha = 0.3
        vwDataConatiner.alpha = 1
        tblExaminationData.reloadData()
    }
  
    @IBAction func btnReminder1Action(_ sender: UIButton) {
        for button in btnReminder {
            let imageName = (button.tag == sender.tag) ? "iconRadioSelect" : "iconRadioUnSelect"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        option1 = (sender.tag == 1) ? "SMS" : (sender.tag == 2) ? "Email" : "Both (sms & e-mail)"
    }
    
    @IBAction func btnReminder2Action(_ sender: UIButton) {
        for button in btnReminderSequence {
            let imageName = (button.tag == sender.tag) ? "iconRadioSelect" : "iconRadioUnSelect"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        selectedReminderID = sender.tag
    }
    
    
    @IBAction func btnSelectPastAppointmentAction(_ sender: Any) {
        DatePickerUtility.showDatePicker(onViewController: self, mode: .date) { [self] value in
            txtPastAppt.text = value?.convertIntoStringUsingFormat(format: "yyyy-MM-dd") ?? ""
        }
    }
    @IBAction func btnSelectStartTime(_ sender: Any) {
        DatePickerUtility.showDatePicker(onViewController: self, mode: .time) { [self] value in
            txtStartTime.text = value?.convertIntoStringUsingFormat(format: "HH:mm") ?? ""
        }
    }
    @IBAction func btnSelectEndTime(_ sender: Any) {
        DatePickerUtility.showDatePicker(onViewController: self, mode: .time) { [self] value in
            txtEndTime.text = value?.convertIntoStringUsingFormat(format: "HH:mm") ?? ""
        }
    }
    
    @IBAction func btnSwitchAction(_ sender: UISwitch) {
        if sender.isOn{
            vwContainer.isHidden = false
            vwContainerHeight.constant = 520
        }else{
            vwContainer.isHidden = true
            vwContainerHeight.constant = 0
        }
        validateTextField()
    }
    
    @IBAction func btnFrequencyAction(_ sender: Any) {
        isExamination = false
        vwOverlay.alpha = 0.3
        vwDataConatiner.alpha = 1
        tblExaminationData.reloadData()
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.saveCustomExamination()
            }
        }
    }
    @IBAction func btnCancelAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwDataConatiner.alpha = 0
    }
    @IBAction func btnDoneAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwDataConatiner.alpha = 0
        if isExamination{
            txtCustomExamination.text = allData.arrExamination.first(where: { $0.id == selectedExaminationID })?.name
        }else{
            txtFrequency.text = allData.fututeFrequecy.first(where: { $0.id == selectedFrequencyID })?.name
        }
    }
    
}

extension CustomExaminationVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  isExamination ?  allData.arrExamination.count : allData.fututeFrequecy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateTCell") as! StateTCell
        if isExamination{
            cell.lblTitle.text = allData.arrExamination[indexPath.row].name
            if allData.arrExamination[indexPath.row].id == selectedExaminationID{
                cell.imgSelected.image = UIImage(systemName: "checkmark")
            }else{
                cell.imgSelected.image = nil
            }
        }else{
            cell.lblTitle.text = allData.fututeFrequecy[indexPath.row].name
            if allData.fututeFrequecy[indexPath.row].id == selectedFrequencyID{
                cell.imgSelected.image = UIImage(systemName: "checkmark")
            }else{
                cell.imgSelected.image = nil
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isExamination{
            selectedExaminationID = allData.arrExamination[indexPath.row].id
        }else{
            selectedFrequencyID = allData.fututeFrequecy[indexPath.row].id
        }
        
        tblExaminationData.reloadData()
    }
}

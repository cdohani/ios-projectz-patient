//
//  ExaminationDateVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 03/11/2025.
//

import UIKit

class ExaminationDateVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblWhenLastVisit: UILabel!
    @IBOutlet var lblSelectMonth: UILabel!
    @IBOutlet var txtMonth: AuthTextField!
    @IBOutlet var lblSelectYear: UILabel!
    @IBOutlet var txtYear: AuthTextField!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var btnDontRemember: UIButton!
    
    
    
    //MARK: Variable
    var validator: Validator!
    var examinationID = -1
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        validateTextField()
    }
    
    //MARK: Functions
    func validateTextField() {
        validator = Validator(withView: self.view)
        
        validator.add(textField: txtMonth, rules: [.minLength(1)])
        validator.add(textField:txtYear , rules: [.minLength(1)])
 
        txtMonth.emptyErrorText = Constants.TextFieldError.emptyString
        txtYear.emptyErrorText = Constants.TextFieldError.emptyString

    }
    
    func saveExaminationDate(){
        let param: [String: Any] = [
            "examination_id": examinationID,
            "month": txtMonth.text!,
            "year": txtYear.text!,
        ]
       
        let endPoint =  Constants.URLs.saveExaminationDate
        
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
    @IBAction func btnSelectMonthAction(_ sender: Any) {
        let picker = MonthYearPickerSheet()
        picker.pickerType = .month   // .month or .year
        picker.completion = { [self] monthName, _ in
            txtMonth.text = monthName
           
        }
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .crossDissolve
        present(picker, animated: true)
        
    }
    @IBAction func btnSelectYearAction(_ sender: Any) {
        let picker = MonthYearPickerSheet()
        picker.pickerType = .year   // .month or .year
        picker.completion = { [self]  _, year in
            txtYear.text = "\(year ?? 2026)"
        }
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .crossDissolve
        present(picker, animated: true)
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.saveExaminationDate()
            }
        }
    }
    @IBAction func btnDontRememberAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

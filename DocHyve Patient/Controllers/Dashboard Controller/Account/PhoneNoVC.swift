//
//  PhoneNoVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 26/02/2024.
//

import UIKit

class PhoneNoVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPhoneNo: UILabel!
    @IBOutlet weak var txtPhoneNo: AuthTextField!
    @IBOutlet weak var lblSendPinDesc: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    
    
    //MARK: Variable
    var validator: Validator!
    
    var isFromBooking = false
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateTextField()
    }
    
    //MARK: Functions
    
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtPhoneNo, rules: [.minLength(1)])
        txtPhoneNo.emptyErrorText = Constants.TextFieldError.emptyString
    }
    
    func addPhone(){
        let param: [String: Any] = [
            "phone_number": txtPhoneNo.text!
        ]
        
        showLoadingView("")
        let endPoint =  Constants.URLs.addNewPhoneNo
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if success is GeneralResponseModel
                {
                    let nextVC = self.getVerifyPhoneNoVC()
                    nextVC.phone = txtPhoneNo.text!
                    nextVC.isFromBookingScreen = isFromBooking
                    self.navigationController?.pushViewController(nextVC, animated: true)
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
    @IBAction func btnNextAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.addPhone()
            }
        }
    }
}

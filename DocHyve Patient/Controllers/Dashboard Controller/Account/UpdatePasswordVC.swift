//
//  UpdatePasswordVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 23/02/2024.
//

import UIKit

class UpdatePasswordVC: ParentViewController,UITextFieldDelegate{

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblUpdatePassword: UILabel!
    @IBOutlet weak var lblCurrentPassword: UILabel!
    @IBOutlet weak var txtCurrentPassword: AuthTextField!
    @IBOutlet weak var lblNewPassword: UILabel!
    @IBOutlet weak var txtNewPassword: AuthTextField!
    @IBOutlet weak var lblConfirmPassword: UILabel!
    @IBOutlet weak var txtConfirmPassword: AuthTextField!
    
    @IBOutlet var btnLength: UIButton!
    @IBOutlet var btnLetters: UIButton!
    @IBOutlet var btnNumbers: UIButton!
    @IBOutlet var btnSpecialCharacters: UIButton!
    
    
    //MARK: Variable
    var isValidAll = false
    var validator: Validator!
    
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        validateTextField()
        txtNewPassword.delegate = self
    }
    
    //MARK: Functions
    
    
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtCurrentPassword, rules: [.minLength(1)])
        validator.add(textField: txtNewPassword, rules: [.minLength(8),.regex(.password)])
        validator.add(textField: txtConfirmPassword, rules: [.minLength(1),.matches(txtNewPassword)])
        
        txtCurrentPassword.emptyErrorText = Constants.TextFieldError.emptyString
        txtNewPassword.emptyErrorText = Constants.TextFieldError.emptyString
        txtNewPassword.errorText = Constants.TextFieldError.passwordValidtion
        txtConfirmPassword.emptyErrorText = Constants.TextFieldError.emptyString
        txtConfirmPassword.errorText = Constants.TextFieldError.passwordMismatch
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        isValidAll = isPasswordValid(password: currentText)
        return true
    }
    private func isPasswordValid(password: String) -> Bool {
        var isValid = true
        
        // Regular expressions for different conditions
        let conditions: [(regex: String, button: UIButton)] = [
            (".*[0-9]+.*", btnNumbers),          // Number condition
            (".*[a-zA-Z]+.*", btnLetters),       // Character condition
            (".*[^a-zA-Z0-9].*", btnSpecialCharacters) // Special character condition
        ]
        
        // Loop through each condition and update the respective button
        for condition in conditions {
            let predicate = NSPredicate(format: "SELF MATCHES %@", condition.regex)
            let isMatched = predicate.evaluate(with: password)
            let imageName = isMatched ? "iconRadioSelect" : "iconRadioUnSelect"
            condition.button.setImage(UIImage(named: imageName), for: .normal)
            
            if !isMatched {
                isValid = false
            }
        }
        
        // Check if password is at least 8 characters long
        let lengthCheck = password.count >= 8
        btnLength.setImage(UIImage(named: lengthCheck ? "iconRadioSelect" : "iconRadioUnSelect"), for: .normal)
        
        if !lengthCheck {
            isValid = false
        }

        return isValid
    }

    func updatePassword(){
        
        let param: [String: Any] = [
            "old_password": txtCurrentPassword.text!,
            "new_password": txtNewPassword.text!,
            "new_password_confirmation":  txtConfirmPassword.text!
        ]
        let endPoint =  Constants.URLs.updatePassword
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    if  data.status == 200 ||  data.status == 201 {
                        self.showAlertViewWithCompletion(message: data.message) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        self.showAlertView(message: data.message)
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
    @IBAction func btnUpdateAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.updatePassword()
            }
        }
    }
    
}

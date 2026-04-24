//
//  ResetPasswordVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/10/2025.
//

import UIKit

class ResetPasswordVC: ParentViewController,UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblResetPassword: UILabel!
    @IBOutlet var lblNewPassword: UILabel!
    @IBOutlet var txtNewPassword: AuthTextField!
    @IBOutlet var lblPasswordStrength: UILabel!
    @IBOutlet var btnLength: UIButton!
    @IBOutlet var btnLetters: UIButton!
    @IBOutlet var btnNumbers: UIButton!
    @IBOutlet var btnSpecialCharacters: UIButton!
    @IBOutlet var lblConfirmPassword: UILabel!
    @IBOutlet var txtConfirmPassword: AuthTextField!
    @IBOutlet var btnResetPassword: UIButton!
    
    
    //MARK: Variable
    var email = ""
    var code = ""
    var validator: Validator!
    var isValidAll = false
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        validateTextField()
        txtNewPassword.delegate = self
    }
   
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtNewPassword, rules: [.minLength(8),.regex(.password)])
        validator.add(textField: txtConfirmPassword, rules: [.matches(txtNewPassword)])
       
        txtNewPassword.emptyErrorText = Constants.TextFieldError.emptyString
        txtNewPassword.errorText = Constants.TextFieldError.passwordValidtion
        txtConfirmPassword.errorText = Constants.TextFieldError.passwordMismatch
    }
    
    func changePassword(){
        let param: [String: Any] = [
            "email": email,
            "code": code,
            "password": txtNewPassword.text!,
            "password_confirmation": txtConfirmPassword.text! ,
        ]
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.resetPassword,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                    self.navigationController?.popToRootViewController(animated: true)
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
    //MARK: Functions
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
    
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSecurePasswordAction(_ sender: UIButton) {
        txtNewPassword.isSecureTextEntry.toggle()
        let imageName = txtNewPassword.isSecureTextEntry ? "iconhide" : "iconshow"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func btnSecureConfirmPasswordAction(_ sender: UIButton) {
        txtConfirmPassword.isSecureTextEntry.toggle()
        let imageName = txtConfirmPassword.isSecureTextEntry ? "iconhide" : "iconshow"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func btnResetPasswordAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.changePassword()
            }
        }
    }
    
}

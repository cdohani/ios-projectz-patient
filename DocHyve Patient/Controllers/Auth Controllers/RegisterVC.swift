//
//  RegisterVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 21/02/2024.
//

import UIKit

class RegisterVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSignUp: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: AuthTextField!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var txtPassword: AuthTextField!
    @IBOutlet weak var lblConfirmPassword: UILabel!
    @IBOutlet weak var txtConfirmPassword: AuthTextField!
    @IBOutlet weak var btnContinue: UIButton!
    
    
    
    //MARK: Variable
    var validator: Validator!
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        validateTextField()
    }
    
    //MARK: Functions
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtEmail, rules: [.minLength(1),.regex(.email)])
        validator.add(textField: txtPassword, rules: [.minLength(1)])
        validator.add(textField: txtConfirmPassword, rules: [.matches(txtPassword)])
        
        txtEmail.errorText =  Constants.TextFieldError.invalidEmail
        txtEmail.emptyErrorText = Constants.TextFieldError.emptyString
        txtPassword.emptyErrorText = Constants.TextFieldError.emptyString
        txtConfirmPassword.errorText = Constants.TextFieldError.passwordMismatch
    }
    
    func callRegisterApi(){
        let param: [String: Any] = [
            "email": txtEmail.text!,
            "password": txtPassword.text!,
            "password_confirmation": txtConfirmPassword.text!
        ]
        showLoadingView("")
        let endPoint = Constants.URLs.registerStep1
        RegistrationService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? RegisterReponseModel
                {
                    if  data.response.status != 200 && data.response.status != 201{
                        self.showAlertView(message: data.response.message)
                    }
                    else{
                        let nextVC = self.getVerifyEmailVC()
                        nextVC.email = self.txtEmail.text!
                        nextVC.userId = data.userID
                        nextVC.isFromForgetPassword = false
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
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContineAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            
            if valid {
                strongSelf.callRegisterApi()
            }
        }
    }
    @IBAction func btnHideShowPassword(_ sender: UIButton) {
        txtPassword.isSecureTextEntry.toggle()
        let imageName = txtPassword.isSecureTextEntry ? "iconhide" : "iconshow"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func btnHideShowConfirmPassword(_ sender: UIButton) {
        txtConfirmPassword.isSecureTextEntry.toggle()
        let imageName = txtPassword.isSecureTextEntry ? "iconhide" : "iconshow"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }
}

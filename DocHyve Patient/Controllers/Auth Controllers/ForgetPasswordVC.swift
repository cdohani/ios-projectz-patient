//
//  ForgetPasswordVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 04/10/2023.
//

import UIKit

class ForgetPasswordVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblDoc: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtEmail: AuthTextField!
    @IBOutlet weak var btnSend: UIButton!
    
    
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
        
        txtEmail.errorText =  Constants.TextFieldError.invalidEmail
        txtEmail.emptyErrorText = Constants.TextFieldError.emptyString
     
    }
    
    func sendCode(){
        let param: [String: Any] = [
            "email": txtEmail.text!,
        ]
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.forgetPassword,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                        let nextVC = self.getVerifyEmailVC()
                        nextVC.email = txtEmail.text!
                        nextVC.isFromForgetPassword = true
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
    @IBAction func btnSendAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.sendCode()
            }
        }
    }
    
    

}

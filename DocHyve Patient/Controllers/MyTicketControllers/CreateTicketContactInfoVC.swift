//
//  CreateTicketContactInfoVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 30/07/2024.
//

import UIKit

class CreateTicketContactInfoVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblTicket: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var txtName: AuthTextField!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var txtEmail: AuthTextField!
    @IBOutlet var lblHaveAccount: UILabel!
    @IBOutlet var btnAccount: [UIButton]!
    @IBOutlet var vwUserName: UIView!
    @IBOutlet var lblIfYes: UILabel!
    @IBOutlet var txtUserName: AuthTextField!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var lblYes: UILabel!
    @IBOutlet var lblNo: UILabel!
    
    //MARK: Variable
    var categoryID = -1
    var subcategoryID = -1
    var subject = ""
    var ticketDescription = ""
    var images : [(UIImage, String, String)] = []
    var haveAccount = 1
    var validator: Validator!
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        validateTextField()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Functions
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtName, rules: [.minLength(1)])
        validator.add(textField: txtEmail, rules: [.minLength(1),.regex(.email)])
        txtName.emptyErrorText = Constants.TextFieldError.emptyString
        txtEmail.emptyErrorText = Constants.TextFieldError.emptyString
        txtEmail.errorText = Constants.TextFieldError.invalidEmail
    }
    func addTicket(){
        var param: [String: Any] = [
            "category_id": categoryID,
            "sub_category_id": subcategoryID,
            "inquiry_subject": subject,
            "description": ticketDescription,
            "name": txtName.text!,
            "email": txtEmail.text!,
            "have_account": haveAccount,
        ]
        if haveAccount == 1{
            param["username"] = txtUserName.text!
        }
        
        let endPoint = Constants.URLs.createTicket
        showLoadingView("")
        CreateTicket().addData(endPoint: endPoint, imgKey: "attachments[]", images: images, parameters: param) { message in
            self.removeLoadingView()
            self.showAlertViewWithCompletion(message: message) {
                if let navigationController = self.navigationController {
                    for viewController in navigationController.viewControllers {
                        if viewController is MyTicketVC { // Replace with your view controller class
                            DataManager.shared.isDataUpdated = true
                            navigationController.popToViewController(viewController, animated: true)
                            break
                        }
                    }
                }
            }
        } failure: { error in
            self.showAlertView(message: error)
           
        }
    }
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRadioAction(_ sender: UIButton) {
        for button in btnAccount {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelected"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnselect"), for: .normal)
            }
        }
        if sender.tag == 1{
            haveAccount = 1
            vwUserName.isHidden = false
            validator.add(textField: txtUserName, rules: [.minLength(1)])
        }
        else{
            haveAccount = 0
            vwUserName.isHidden = true
            validator.removeRules(textField: txtUserName)
        }
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.addTicket()
            }
        }
        
    }
    
}

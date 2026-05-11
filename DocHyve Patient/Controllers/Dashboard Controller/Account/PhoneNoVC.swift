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
        
        txtPhoneNo.delegate = self
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

extension PhoneNoVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhoneNo {
            guard let currentText = textField.text else { return true }
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            let formatted = formatPhoneNumber(updatedText)
            
            // Extract only digits
            let cleanDigits = formatted.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            // Limit to 10 digits only
            guard cleanDigits.count <= 10 else { return false }
            
            textField.text = formatted
            
            DispatchQueue.main.async { [textField] in
                let end = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: end, to: end)
            }
            
            return false
        }
        return true
    }

    private func formatPhoneNumber(_ input: String) -> String {
        // Remove all non-digit characters
        let digits = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard !digits.isEmpty else { return "" }
        
        var result = ""
        
        // Format as: (XXX) XXX-XXXX
        for (index, char) in digits.enumerated() {
            switch index {
            case 0: result += "(\(char)"
            case 1, 2: result += "\(char)"
            case 3: result += ") \(char)"
            case 4, 5: result += "\(char)"
            case 6: result += "-\(char)"
            default: result += "\(char)"
            }
        }
        
        return result
    }
}

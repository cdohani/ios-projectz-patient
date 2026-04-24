//
//  OtherHistoryTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 24/10/2025.
//

import UIKit

class OtherHistoryTCell: UITableViewCell {

    @IBOutlet var vwBackground: UIView!
    @IBOutlet var txtOther: AuthTextField!
    
    var validator: Validator!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        validateTextField()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func validateTextField() {
        validator = Validator(withView: self)
        validator.add(textField: txtOther, rules: [.minLength(1)])
        
        txtOther.emptyErrorText =  Constants.TextFieldError.emptyString
       
    }
   
    
    func validateNow(completion: @escaping (Bool) -> Void) {
        validator.validateNow { valid in
            // Do any internal logic
            completion(valid)
        }
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        delegate?.sendData(self, didUpdateText: textField.text ?? "")
//    }

}

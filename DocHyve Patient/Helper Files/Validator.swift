//
//  Validator.swift
//  ICT
//
//  Created by Jawad Ali on 03/01/2020.
//  Copyright © 2020 Jawad Ali. All rights reserved.
//
import Foundation
import UIKit

enum Regex {
    case email, name, password, phone, usStates, securityCode
    case custom(regex: String)
    private func get() -> String {
        switch self {
        case .name:
            return "[A-Za-z ]+"
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            
        case .password:
            return "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}$"
        case .phone:
            return "^((\\+)|(00))[0-9]{6,14}$"
        case .usStates:
            return "^(?:(A[AEKLPRZ]|C[AOT]|D[CE]|FL|GA|HI|I[ADLN]|K[SY]|LA|M[ADEINOST]|N[CDEHJMVY]|O[HKR]|P[AR]|RI|S[CD]|T[NX]|UT|V[AIT]|W[AIVY]))$"
        case .securityCode:
            return "^[0-9]{3,4}$"
        case .custom(regex: let reg):
            return reg
        }
    }
    func check(string: String) -> Bool {
        let tester = NSPredicate(format:"SELF MATCHES %@", get())
        return tester.evaluate(with: string)
    }
}

typealias SuccessEvent = (Bool) -> Void

class Validator: NSObject, UITextFieldDelegate {
    
    private var validationObjects: [ValidationObject]
    //var selectedTextField: UITextField
    private var selectedIndex: Int = 0
    private var view: UIView
    private var scrollView: UIScrollView?
    private var validationChanged: SuccessEvent?
    private var fieldsTap: EmptyEvent?
    
    init(withView: UIView, scrollView sView: UIScrollView? = nil, onFieldsTapped: EmptyEvent? = nil) {
        view = withView
        validationObjects = []
        scrollView = sView
        fieldsTap = onFieldsTapped
    }
    
    func add(textField: AuthTextField, rules: [Validations], showPasswordError: Bool = false, onChange: EmptyEvent? = nil, onReturnEvent: SuccessEvent? = nil) {
        validationObjects.last?.textField.returnKeyType = .next
        validationObjects.append(ValidationObject(textField: textField, rules: rules, showErr: showPasswordError, onReturn: onReturnEvent, onChange: onChange))
        textField.delegate = self
        textField.returnKeyType = .done
        textField.onEmpty = {
            self.validate()
        }
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(editingBegin(_:)), for: .editingDidBegin)
    }
    
    func validateNow(valid: SuccessEvent? = nil) {
        //validationObjects[selectedIndex].onSelectedTap?(validationObjects[selectedIndex].isValid())
        //validate()
        valid?(checkValidation())
    }
    
    func removeRules(textField: AuthTextField) {
        for validationObject in validationObjects {
            if textField == validationObject.textField {
                validationObject.rules = []
            }
        }
    }
    
    func addRules(textField: AuthTextField, rules: [Validations]) {
        for validationObject in validationObjects {
            if textField == validationObject.textField {
                validationObject.rules = rules
            }
        }
    }
    
    func onValidationChange(successEvent: SuccessEvent?) {
        scrollView?.keyboardDismissMode = .onDrag
        validationChanged = successEvent
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
//        validationObjects[selectedIndex].onChangeEvent?()
//
//        if validationObjects[selectedIndex].hasPhoneNumberRule() {
//            textField.text = formatPhoneNumber(textField.text ?? "")
//        }
//
//        if validationObjects[selectedIndex].hasExpirationRule() {
//            textField.text = formatExp(string: textField.text ?? "")
//        }
//        validationObjects[selectedIndex].onSelectedTap?(validationObjects[selectedIndex].isValid())
//
//        validate()
        
    }
    
    func validate() {
        let valid = checkValidation()
        validationChanged?(valid)
    }
    
    private func checkValidation() -> Bool {
        var valid: Bool = true
        for validationObject in validationObjects {
            if validationObject.isValid() == false {
                valid = false
            }
        }
        return valid
    }
    
    @objc func editingBegin(_ textField: AuthTextField) {
        for i in 0 ..< validationObjects.count {
            if validationObjects[i].textField == textField {
                selectedIndex = i
                fieldsTap?()
            }
        }
        scrollView?.scrollToView(view: textField, animated: true)
    }
    
    func getSelectedTextField() -> AuthTextField {
        return validationObjects[selectedIndex].textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //validationObjects[selectedIndex].onSelectedTap?(validationObjects[selectedIndex].isValid())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //validationObjects[selectedIndex].onSelectedTap?(validationObjects[selectedIndex].isValid())
        if selectedIndex == validationObjects.count - 1 {
            view.endEditing(true)
        } else {
            validationObjects[selectedIndex + 1].textField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = (textField.text?.count ?? 0) + string.count - range.length
        let selectedObject = validationObjects[selectedIndex]
        
        if selectedObject.hasExpirationRule() {
            let oldText = selectedObject.textField.text ?? ""
            return expirationCheck(oldText: oldText, newText: string, newLength: newLength)
        }
        
        if selectedObject.hasCreditCardRule() {
            return newLength < 24
        }
        
        if let maxLength = selectedObject.getMaxLength() {
            return maxLength >= newLength
        }
        return true
    }
    
    func expirationCheck(oldText: String, newText: String, newLength: Int) -> Bool {
        let oldLength: Int = oldText.count
        if newText == "" {
        } else if oldLength == 0 {
            
            return "01".contains(newText)
            
        } else if oldLength == 1 {
            if oldText == "0" {
                return "123456789".contains(newText)
            } else {
                return "012".contains(newText)
            }
        }
        return newLength < 6
    }
    
    func formatExp(string: String) -> String {
        var newString = string.replacingOccurrences(of: "/", with: "")
        if newString.count > 2 {
            newString.insert("/", at: newString.index(newString.startIndex, offsetBy: 2) )
        }
        return newString
    }
    
    func formatPhoneNumber(_ string: String) -> String {
        if string.count == 0 {
            return ""
        }
        let newString: String = (string as NSString).replacingCharacters(in: (string as NSString).range(of: string), with: string)
        let components: [Any] = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let decimalString: String = (components as NSArray).componentsJoined(by: "")
        let length: Int = decimalString.count
        var index: Int = 0
        var formattedString = String()
        if length - index > 3 {
            let areaCode: String = (decimalString as NSString).substring(with: NSRange(location: index, length: 3))
            formattedString += "(\(areaCode))"
            index += 3
        }
        if length - index > 3 {
            let prefix: String = (decimalString as NSString).substring(with: NSRange(location: index, length: 3))
            formattedString += " \(prefix) - "
            index += 3
        }
        let remainder = decimalString.substring(from: decimalString.index(decimalString.startIndex, offsetBy: index))
        formattedString.append(remainder)
        return formattedString
    }
}

enum Validations {
    case regex(Regex)
    case maxLength(Int)
    case minLength(Int)
    case matches(UITextField)
    case notMatchesTo(UITextField)
    case expiration
    case creditCard
    case notEmpty
    case phoneNumber
    case optionalCNIC
    
    func checkRule(on textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        switch self {
        case .regex(let reg):
            return reg.check(string: text)
        case .maxLength(let max):
            return max >= text.count
        case .minLength(let min):
            return min <= text.count
        case .matches(let matchText):
            return textField.text == matchText.text
        case .notMatchesTo(let matchText):
            return textField.text != matchText.text
        case .creditCard:
            return text.count > 13
        case .expiration:
            return text.count > 4
        case .notEmpty:
            return textField.text != ""
        case .phoneNumber:
            return text.count > 13
        case .optionalCNIC:
            if text == "" {
                return true
            } else {
                return text.count == 13
            }
        }
    }
    func getMaxLength() -> Int? {
        switch self {
        case .maxLength(let max):
            return max
        default:
            return nil
        }
    }
    func isExpiration() -> Bool {
        switch self {
        case .expiration:
            return true
        default:
            return false;
        }
    }
    func isCreditCard() -> Bool {
        switch self {
        case .creditCard:
            return true
        default:
            return false;
        }
    }
    func isPhoneNumber() -> Bool {
        switch self {
        case .phoneNumber:
            return true
        default:
            return false;
        }
    }
}

class ValidationObject {
    var textField: AuthTextField
    var rules: [Validations]
    var onSelectedTap: SuccessEvent?
    var onChangeEvent: EmptyEvent?
    var showPasswordError = false
    
    
    init(textField txt: AuthTextField, rules rul: [Validations], showErr: Bool = false, onReturn: SuccessEvent? = nil, onChange: EmptyEvent? = nil) {
        textField = txt
        rules = rul
        onSelectedTap = onReturn
        onChangeEvent = onChange
        showPasswordError = showErr
    }
    
    func isValid() -> Bool {
        if rules.count == 0 {
            textField.hasErrorMessage = false
            return true
        }
        
        for rule in rules {
            let valid = rule.checkRule(on: textField)
            if !valid {
                textField.hasErrorMessage = !valid
                return false
            }
        }
        
//        if (textField.text ?? "").count != 0 {
//            for rule in rules {
//                let valid = rule.checkRule(on: textField)
//                if !valid {
//                    textField.hasErrorMessage = !valid
//                    return false
//                }
//            }
//        } else {
//
//            textField.hasErrorMessage = false
//            return false
//        }
        textField.hasErrorMessage = false
        return true
    }
    
    func getMaxLength() -> Int? {
        for rule in rules {
            if let length = rule.getMaxLength() {
                return length
            }
        }
        return nil
    }
    
    func hasExpirationRule() -> Bool {
        return rules.contains { $0.isExpiration() }
    }
    
    func hasCreditCardRule() -> Bool {
        return rules.contains { $0.isCreditCard() }
    }
    
    func hasPhoneNumberRule() -> Bool {
        return rules.contains { $0.isPhoneNumber() }
    }
}

extension UIScrollView {
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            let rect = CGRect(x: 0, y: childStartPoint.y-10, width: 1, height: self.frame.height)
            self.scrollRectToVisible(rect, animated: animated)
        }
    }
    
    func addPullToRefresh(title: String? = "Pull to refresh",
                          onRefresh: @escaping (_ control: UIRefreshControl) -> Void) {
        // Remove old one if it exists
        if let existingControl = self.refreshControl {
            existingControl.removeFromSuperview()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = title != nil ? NSAttributedString(string: title!) : nil
        if #available(iOS 14.0, *) {
            refreshControl.addAction(UIAction { _ in
                onRefresh(refreshControl)
            }, for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        
        self.refreshControl = refreshControl
    }
}

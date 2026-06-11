//
//  TextFieldExtension.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 1/20/26.
//

import UIKit
import ObjectiveC

private var __maxLengths = [UITextField: Int]()


extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else { return 150 }
            return l
        } set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        if let t = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat {
        get { return leftView?.frame.size.width ?? 0 }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRight: CGFloat {
        get { return rightView?.frame.size.width ?? 0 }
        set {
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height))
            rightViewMode = .always
        }
    }
    
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc fileprivate func doneButtonAction() {
        self.resignFirstResponder()
    }
}

extension UITextField {
    
    // MARK: - Picker Coordinator
    private class PickerCoordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

        var numberOfRows: (() -> Int)?
        var titleForRow: ((Int) -> String)?
        var didSelectRow: ((Int) -> Void)?
        var doneAction: (() -> Void)?
        var cancelAction: (() -> Void)?

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return numberOfRows?() ?? 0
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return titleForRow?(row)
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            didSelectRow?(row)
        }

        @objc func doneTapped() {
            doneAction?()
        }

        @objc func cancelTapped() {
            cancelAction?()
        }
    }

    // MARK: - Associated Object
    private static var coordinatorKey: UInt8 = 0

    private var pickerCoordinator: PickerCoordinator {
        if let coordinator = objc_getAssociatedObject(self, &Self.coordinatorKey) as? PickerCoordinator {
            return coordinator
        }

        let coordinator = PickerCoordinator()
        objc_setAssociatedObject(self, &Self.coordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return coordinator
    }

    // MARK: - Public API
    func setPickerInput(
        rows: @escaping () -> Int,
        title: @escaping (Int) -> String,
        didSelect: @escaping (Int) -> Void,
        onDone: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {

        let pickerView = UIPickerView()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        pickerCoordinator.numberOfRows = rows
        pickerCoordinator.titleForRow = title
        pickerCoordinator.didSelectRow = didSelect
        pickerCoordinator.doneAction = onDone
        pickerCoordinator.cancelAction = onCancel

        pickerView.delegate = pickerCoordinator
        pickerView.dataSource = pickerCoordinator

        let cancel = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: pickerCoordinator,
            action: #selector(PickerCoordinator.cancelTapped)
        )

        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let done = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: pickerCoordinator,
            action: #selector(PickerCoordinator.doneTapped)
        )

        toolbar.setItems([cancel, space, done], animated: false)

        inputView = pickerView
        inputAccessoryView = toolbar
    }
    
    func removeInputView() {
        inputView = nil
        inputAccessoryView = nil
//        objc_setAssociatedObject(self, &Self.pickerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        objc_setAssociatedObject(self, &Self.toolbarKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &Self.coordinatorKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}


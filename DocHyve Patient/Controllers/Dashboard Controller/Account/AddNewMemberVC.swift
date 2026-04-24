//
//  AddNewMemberVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 12/03/2024.
//

import UIKit

class AddNewMemberVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var txtFirstName: AuthTextField!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var txtLastName: AuthTextField!
    @IBOutlet weak var lblRelation: UILabel!
    @IBOutlet weak var txtRelation: AuthTextField!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet var imgUser: UIImageView!
    
    
    
    //MARK: Variable
    var validator: Validator!
    var isForEdit = false
    var memberData = MemberDetailModel()
    var isImageSelected = false
    
    var arrStatus = ["Spouse","Son","Daughter"]
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateTextField()
        if isForEdit{
            lblHeading.text = "Edit Member"
            btnAddMember.setTitle("Update", for: .normal)
            setScreenData()
        }
        setupPickerView()
    }
    
    //MARK: Functions
    func setScreenData(){
        if memberData.userImage != ""{
            let imageURL = Constants.URLs.imagePath + memberData.userImage
            imgUser.loadImage(from: imageURL)
            isImageSelected = true
        }
        txtFirstName.text = memberData.firstName
        txtLastName.text = memberData.lastName
        txtRelation.text = memberData.relationship
    }
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtFirstName, rules: [.minLength(1),.regex(.name)])
        validator.add(textField: txtLastName, rules: [.minLength(1),.regex(.name)])
        validator.add(textField: txtRelation, rules: [.minLength(1)])


        txtFirstName.errorText = Constants.TextFieldError.onlyAlphabets
        txtFirstName.emptyErrorText = Constants.TextFieldError.emptyString
        txtLastName.errorText = Constants.TextFieldError.onlyAlphabets
        txtLastName.emptyErrorText = Constants.TextFieldError.emptyString
        txtRelation.emptyErrorText = Constants.TextFieldError.emptyString

    }
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        txtRelation.delegate = self
        txtRelation.inputView = pickerView
        txtRelation.inputAccessoryView = toolbar
        // Toolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    @objc func doneTapped() {
         let row = pickerView.selectedRow(inComponent: 0)
        txtRelation.text = arrStatus[row]
        txtRelation.resignFirstResponder()
       
     }
     
     @objc func cancelTapped() {
         txtRelation.resignFirstResponder()
     }
    

    
    func callApi(){
        var endPoint = ""
        var param: [String: Any] = [
            "first_name": txtFirstName.text!,
            "last_name": txtLastName.text!,
            "relation": txtRelation.text!,
        ]
        if isForEdit{
            param["id"] = memberData.id
            endPoint =  Constants.URLs.editFamilyMembers
        }else{
            endPoint =  Constants.URLs.addFamilyMember
        }
        showLoadingView("")
        AddMemberService().addData(endPoint: endPoint,mimeType: "image/jpeg", image: imgUser.image!, parameters: param, paramName: "image") { reponse in
            self.removeLoadingView()
            if let data = reponse as? String
            {
                self.showAlertViewWithCompletion(message: data) {
                    DataManager.shared.isDataUpdated = true
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: error ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    

    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnAddMemberAction(_ sender: Any) {
       
        self.view.endEditing(true)
         if !isImageSelected{
            showAlertView(message: "Please select your picture.")
        }
        else{
            validator.validateNow { [weak self] valid in
                guard let strongSelf = self else { return }
                if valid {
                    strongSelf.callApi()
                    
                }
            }
        }
    }
    
    @IBAction func btnSelectRelationAction(_ sender: Any) {
        txtRelation.becomeFirstResponder()
    }
    

    @IBAction func btnUploadUserImageAction(_ sender: Any) {
        showImagePicker { [self] selectedImage, error in
            if let image = selectedImage {
                self.imgUser.image = image
                isImageSelected = true
                //uploadUserImage()
            } else {
                isImageSelected = false
                // Handle the case where no image was selected or an error occurred
            }
        }
    }
    
}


extension AddNewMemberVC: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UIPickerViewDataSource
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return arrStatus.count
     }

     // MARK: - UIPickerViewDelegate
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return  arrStatus[row]
     }
}
extension AddNewMemberVC : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtRelation{
            return false
        }
        return true
    }
}

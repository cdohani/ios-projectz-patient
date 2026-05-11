//
//  ProfileVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 26/02/2024.
//

import UIKit
import TagListView

class ProfileVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var txtFirstName: AuthTextField!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var txtLastName: AuthTextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: AuthTextField!
    @IBOutlet weak var lblPhoneNo: UILabel!
    @IBOutlet weak var txtPhoneNo: AuthTextField!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet var txtAddress: AuthTextField!
    @IBOutlet weak var lblDateofBirth: UILabel!
    @IBOutlet weak var txtDateofBirth: AuthTextField!
    @IBOutlet var vwGenderTag: TagListView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet var btnGender: [UIButton]!
    @IBOutlet var btnMoreGender: UIButton!
    @IBOutlet var lblUploadNic: UILabel!
    @IBOutlet var imgNic: UIImageView!
    @IBOutlet var btnRemoveImage: UIButton!
    
    
    
    //MARK: Variable
    var userProfile = UserProfileModel()
    var isImageSelected = false
    var selectedGender = "male"
    
    var arrState = [StateModel]()
    var selectedStateIndex = -1
    var arrFilter = [StateModel]()
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        getProfile()
        customization()
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated {
            getProfile()
            DataManager.shared.isDataUpdated = false  // Reset flag
        }
    }
    //MARK: Functions
    func customization(){
        txtEmail.isEnabled = false
        txtFirstName.isEnabled = false
        txtLastName.isEnabled = false
        btnRemoveImage.isHidden = true
        txtPhoneNo.delegate = self
    }
    

    
    func getProfile(){
        showLoadingView("")
        GetUserProfileService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? UserProfileReponseModel
                {
                    self.userProfile = data.userData
                    setScreenData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }

    func setScreenData(){
        imgUser.loadImage(from: userProfile.profileImage)
//        if userProfile.nicImage != ""{
//            imgNic.loadImage(from: userProfile.nicImage)
//            btnRemoveImage.isHidden = false
//            lblUploadNic.isHidden = true
//        }else{
//            btnRemoveImage.isHidden = true
//            lblUploadNic.isHidden = false
//        }
        
        lblUserName.text = userProfile.firstName + " " + userProfile.lastName
        txtFirstName.text = userProfile.firstName
        txtLastName.text = userProfile.lastName
        txtEmail.text = userProfile.email
        txtPhoneNo.text = userProfile.contactNumber
        txtDateofBirth.text = userProfile.dateOfBirth
        txtAddress.text = userProfile.address
        selectedGender = userProfile.gender
        
        for button in btnGender {
            if (button.tag == 0 && selectedGender == "male") ||
               (button.tag == 1 && selectedGender == "female") {

                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        
        vwGenderTag.removeAllTags()
        selectedStateIndex = userProfile.state.id
        for item in userProfile.extraGender{
            vwGenderTag.addTag(item.name)
        }
    }
    
    func callApi(){
        
        let param: [String: Any] = [
            "firstname": txtFirstName.text!,
            "lastname": txtLastName.text!,
            "email": txtEmail.text!,
            "contact_number": txtPhoneNo.text!,
            "date_of_birth": txtDateofBirth.text!,
            "address": txtAddress.text!,
            "gender": selectedGender
            
        ]
        
        let endPoint = Constants.URLs.saveUserProfile
        let images: [(key: String, image: UIImage)] = [
            (key: "profile_image", image: imgUser.image!)
//            (key: "nic_image", image: imgNic.image!)
        ]
        showLoadingView("")
        AddProfileService().addData(endPoint: endPoint,mimeType: "image/jpeg", images: images, parameters: param) { reponse in
            self.removeLoadingView()
            if let data = reponse as? String
            {
                self.showAlertViewWithCompletion(message: data) {
                    
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
    @IBAction func btnUpdateProfile(_ sender: Any) {
        showImagePicker { [self] selectedImage, error in
            if let image = selectedImage {
                self.imgUser.image = image
                isImageSelected.toggle()
                //uploadUserImage()
            } else {
                // Handle the case where no image was selected or an error occurred
            }
        }
    }
    @IBAction func btnUpdateAction(_ sender: Any) {
        callApi()
    }
    @IBAction func btnGenderAction(_ sender: UIButton) {
        for button in btnGender {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        selectedGender = sender.tag == 0 ? "male" : "female"
    }
    @IBAction func btnDateofBirthAction(_ sender: Any) {
        let calendar = Calendar.current
        let today = Date()
        let maxDOB = calendar.date(byAdding: .year, value: -18, to: today)!
        
        DatePickerUtility.showDatePicker(onViewController: self, mode: .date, maxDate: maxDOB) { [self] value in
            txtDateofBirth.text = value?.convertIntoStringUsingFormat(format: "MM-dd-yyyy") ?? ""
        }
    }
    @IBAction func btnSelectAddressAction(_ sender: Any) {
        let nextVC = getLocationSearchVC()
        nextVC.dataDelegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnAddMoreGenderAction(_ sender: Any) {
        let nextVC = getGenderMoreInfoVC()
        nextVC.userID = userProfile.id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnRemoveImageAction(_ sender: Any) {
        imgNic.image = nil
       // imgInsuranceCard.isHidden = true
        btnRemoveImage.isHidden = true
        lblUploadNic.isHidden = false
    }
    @IBAction func btnUploadImageAction(_ sender: Any) {
        showImagePicker { [self] selectedImage, error in
            if let image = selectedImage {
              
                btnRemoveImage.isHidden = false
                self.imgNic.image = image
                lblUploadNic.isHidden = true
            } else {
                // Handle the case where no image was selected or an error occurred
            }
        }
    }
    
    
    
}

extension ProfileVC:TransferDataDelegate{
    func sendData(_ data: Any) {
        
        if  let item = data as? GoogleLocationModel {
            txtAddress.text = item.placeAddress
            //            latitude = item.latitude
            //            longitude = item.longitude
        }
    }
}

extension ProfileVC: UITextFieldDelegate {
    
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

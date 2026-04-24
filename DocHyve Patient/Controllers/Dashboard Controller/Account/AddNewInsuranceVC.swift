//
//  AddNewInsuranceVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 29/04/2024.
//

import UIKit

class AddNewInsuranceVC: UIViewController {

    //MARK: Outlets
    @IBOutlet var btnChooseInsuracne: UIButton!
    @IBOutlet var btnInsurandeType: [UIButton]!
    @IBOutlet var lblPrimary: UILabel!
    @IBOutlet var btnPrimarySecondary: [UIButton]!
    @IBOutlet var lblSecondary: UILabel!
    @IBOutlet var lblAddMemberID: UILabel!
    @IBOutlet var txtMemberID: AuthTextField!
    @IBOutlet var imgInsuranceCard: UIImageView!
    @IBOutlet var lblUploadCardPic: UILabel!
    @IBOutlet var btnUploadPic: UIButton!
    @IBOutlet var btnRemoveImage: UIButton!
    
    //MARK: Variable
    var insuraneType = "Medical"
    var isPrimary = true
    
    var validator: Validator!
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        validateTextField()
        customization()
    }
    
    //MARK: Functions
    func customization(){
        btnRemoveImage.isHidden = true
      
    }
    func validateTextField() {
        validator = Validator(withView: self.view)
        
        validator.add(textField: txtMemberID, rules: [.minLength(1)])
        txtMemberID.emptyErrorText = Constants.TextFieldError.emptyString
    }
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnInsuranceTypeAction(_ sender: UIButton) {
        for button in btnInsurandeType {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        if sender.tag == 1{
            insuraneType = "Medical"
        }else if sender.tag == 2{
            insuraneType = "Dental"
        }else{
            insuraneType = "Vision"
        }
    }
    
    @IBAction func btnPrimarySecondaryAction(_ sender: UIButton) {
        
        for button in btnPrimarySecondary {
            if button.tag == sender.tag {
                button.setImage(UIImage(named: "iconRadioSelect"), for: .normal)
            } else {
                button.setImage(UIImage(named: "iconRadioUnSelect"), for: .normal)
            }
        }
        isPrimary = sender.tag == 1 ? true : false
    }
    @IBAction func btnUploadPicAction(_ sender: Any) {
        showImagePicker { [self] selectedImage, error in
            if let image = selectedImage {
              
                btnRemoveImage.isHidden = false
                self.imgInsuranceCard.image = image
                lblUploadCardPic.isHidden = true
                //uploadUserImage()
            } else {
                // Handle the case where no image was selected or an error occurred
            }
        }
    }
    
    @IBAction func btnRemoveImageAction(_ sender: Any) {
        imgInsuranceCard.image = nil
       // imgInsuranceCard.isHidden = true
        btnRemoveImage.isHidden = true
        lblUploadCardPic.isHidden = false
    }
    
    @IBAction func btnChooseInsuranceAction(_ sender: Any) {
        
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                let nextVC = strongSelf.getInsuranceVC()
                nextVC.isPrimary = strongSelf.isPrimary
                nextVC.insuranceType = strongSelf.insuraneType
                nextVC.memberID = strongSelf.txtMemberID.text ?? ""
                nextVC.cardImage = strongSelf.imgInsuranceCard.image
                strongSelf.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
       
    }
    
    
    
}

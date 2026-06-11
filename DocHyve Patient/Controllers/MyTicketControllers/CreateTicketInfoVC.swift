//
//  CreateTicketVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 30/07/2024.
//

import UIKit
import TagListView

class CreateTicketInfoVC: ParentViewController,TagListViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var lblTicket: UILabel!
    @IBOutlet var lblCategory: UILabel!
    @IBOutlet var txtCategory: AuthTextField!
    @IBOutlet var lblSubCategory: UILabel!
    @IBOutlet var txtSubCategory: AuthTextField!
    @IBOutlet var lblSubject: UILabel!
    @IBOutlet var txtSubject: AuthTextField!
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var tvDetail: UITextView!
    
    @IBOutlet var vwImgTags: TagListView!
    
    
    
    //MARK: Variable
    let categoryPickerView = UIPickerView()
    let subCategorypickerView = UIPickerView()
    let categoryToolbar = UIToolbar()
    let subCategoryToolbar = UIToolbar()
    var imagesToUpload: [(img:UIImage, imgName:String, type:String)] = []
    var arrCategory =  [CategoryDataModel]()
    var arrSubCategory =  [SubCategoryDataModel]()
    var selectedCategoryID = -1
    var selectedSubCategoryID = -1
    var validator: Validator!
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateTextField()
        getCategory()
        setupPickerView(for: txtCategory, pickerView: categoryPickerView, toolbar: categoryToolbar, doneSelector: #selector(doneCategoryTapped), cancelSelector: #selector(cancelCategoryTapped))
        setupPickerView(for: txtSubCategory, pickerView: subCategorypickerView, toolbar: subCategoryToolbar, doneSelector: #selector(doneSubCategoryTapped), cancelSelector: #selector(cancelSubCategoryTapped))
        vwImgTags.delegate = self
    }
    
    //MARK: Functions
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtCategory, rules: [.minLength(1)])
        validator.add(textField: txtSubCategory, rules: [.minLength(1)])
        validator.add(textField: txtSubject, rules: [.minLength(1)])
        txtCategory.emptyErrorText = Constants.TextFieldError.emptyString
        txtSubCategory.emptyErrorText = Constants.TextFieldError.emptyString
        txtSubject.emptyErrorText = Constants.TextFieldError.emptyString
    }
    func setupPickerView(for textField: UITextField, pickerView: UIPickerView, toolbar: UIToolbar, doneSelector: Selector, cancelSelector: Selector) {
        pickerView.delegate = self
        pickerView.dataSource = self
        textField.delegate = self
        textField.inputView = pickerView
        textField.inputAccessoryView = toolbar
        
        // Toolbar setup
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: doneSelector)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelSelector)
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    @objc func doneCategoryTapped() {
        let row = categoryPickerView.selectedRow(inComponent: 0)
        txtCategory.text = arrCategory[row].name
        selectedCategoryID = arrCategory[row].id
        arrSubCategory = arrCategory[row].arrSubCategory
        txtSubCategory.text = ""
        subCategorypickerView.reloadAllComponents()
        txtCategory.resignFirstResponder()
    }

    @objc func doneSubCategoryTapped() {
        let row = subCategorypickerView.selectedRow(inComponent: 0)
        txtSubCategory.text = arrSubCategory[row].name
        selectedSubCategoryID = arrSubCategory[row].id
        txtSubCategory.resignFirstResponder()
    }

    @objc func cancelCategoryTapped() {
        txtCategory.resignFirstResponder()
    }

    @objc func cancelSubCategoryTapped() {
        txtSubCategory.resignFirstResponder()
    }

    func getCategory(){
        showLoadingView("")
        GetSupportCategoryService().getData(completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? SupportCategoryResponseModel
                {
                    self?.arrCategory = data.arrCategory
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                self?.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        let index = imagesToUpload.firstIndex(where: { $0.imgName == title })
        imagesToUpload.remove(at: index!)
        vwImgTags.removeTag(title)
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSelectCategoryAction(_ sender: Any) {
        txtCategory.becomeFirstResponder()
    }
    @IBAction func btnSelectSubCategoryAction(_ sender: Any) {
        txtSubCategory.becomeFirstResponder()
    }
    
    @IBAction func btnUploadAttachmnets(_ sender: Any) {
        showImagePicker(allowsMultipleSelection: true) { [weak self] images, names in
            guard let selectedImages = images, let imageNames = names else {
                
                return
            }
            
            // Handle selected images and names
            for (index, image) in selectedImages.enumerated() {
                
                let imageName = imageNames[index]
                self?.imagesToUpload.append((image, imageName, "image/jpeg"))
                self?.vwImgTags.addTag(imageNames[index])
            }
        }
        
        
    }
    @IBAction func btnNextAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                if strongSelf.tvDetail.text == ""{
                    strongSelf.showAlertView(message: "Please write a description.")
                }else if strongSelf.imagesToUpload.isEmpty{
                    strongSelf.showAlertView(message: "Please upload attachment.")
                }else{
                    let nextVC = strongSelf.getCreateTicketContactInfoVC()
                    nextVC.categoryID = strongSelf.selectedCategoryID
                    nextVC.subcategoryID = strongSelf.selectedSubCategoryID
                    nextVC.subject = strongSelf.txtSubject.text!
                    nextVC.ticketDescription = strongSelf.tvDetail.text!
                    nextVC.images = strongSelf.imagesToUpload
                    strongSelf.navigationController?.pushViewController(nextVC, animated: true)
                }
                
            }
        }
        
    }
    
}
extension CreateTicketInfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == categoryPickerView ? arrCategory.count : arrSubCategory.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == categoryPickerView ? arrCategory[row].name : arrSubCategory[row].name
    }
}

extension CreateTicketInfoVC : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtCategory || textField == txtSubCategory{
            return false
        }
        return true
    }
}

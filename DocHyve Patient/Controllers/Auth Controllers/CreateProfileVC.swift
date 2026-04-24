//
//  CreateProfileVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit
import TagListView

class CreateProfileVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var txtFirstName: AuthTextField!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var txtLastName: AuthTextField!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var txtDOB: AuthTextField!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet var btnGender: [UIButton]!
    @IBOutlet weak var btnAddMoreGender: UIButton!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet var btnCheckAggrement: UIButton!
    @IBOutlet var vwSelectedGender: TagListView!
    
    
    //MARK: Variable
    var userId = -1
    var isAggrementCheck = false
    var gender = "male"
    var arrGender = [GenderInfo]()
    var arrSelectedGender = [Int]()
    var selectedGender = SelectedGenderResponseModel()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            getGenderData()
            DataManager.shared.isDataUpdated = false
        }
    }
    
    //MARK: Functions
    func getGenderData(){
        showLoadingView("")
        GetAllGenderService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? GenderResponseModel
                {
                    self.arrGender = data.arrGender
                    getUserSelectedGender()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getUserSelectedGender(){
        showLoadingView("")
        GetSelectedGenderService().getData(userID: userId, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? SelectedGenderResponseModel
                {
                    self.selectedGender = data
                    let otherGenderString = selectedGender.selectedGender.components(separatedBy: ",")
                    let otherGender: [Int] = otherGenderString.compactMap { Int($0) }
                    for item in arrGender{
                        if otherGender.contains(item.id){
                            vwSelectedGender.addTag(item.name)
                        }
                    }
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func createProfile(){
        let param: [String: Any] = [
            "user_id": userId,
            "firstname": txtFirstName.text!,
            "lastname": txtLastName.text!,
            "date_of_birth": txtDOB.text!,
            "gender": gender,
            "accepted_terms": isAggrementCheck
        ]
        showLoadingView("")
        let endPoint = Constants.URLs.registerProfile
        RegistrationService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? RegisterReponseModel
                {
                    if  data.response.status != 200 && data.response.status != 201{
                        self.showAlertView(message: data.response.message)
                    }
                    else{
                        self.showAlertViewWithCompletion(message: data.response.message) {
                            let nextVC = CreateProfileVC.getLoginVC()
                            self.navigationController?.pushViewController(nextVC, animated: true)
                        }
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
    @IBAction func btnGenderAction(_ sender: UIButton) {
        for button in btnGender {
            let imageName = (button.tag == sender.tag) ? "iconRadioSelect" : "iconRadioUnSelect"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        gender = (sender.tag == 1) ? "male" : "female"
    }
    @IBAction func btnSelectDOBAction(_ sender: Any) {
        let calendar = Calendar.current
        let today = Date()

        // User must be at least 18 years old
        let maxDOB = calendar.date(byAdding: .year, value: -18, to: today)!
        
        DatePickerUtility.showDatePicker(onViewController: self, mode: .date, maxDate: maxDOB) { [self] value in
            
            txtDOB.text = value?.convertIntoStringUsingFormat(format: "MM-dd-yyyy") ?? ""
        }
    }
    
    @IBAction func btnAddMoreGenderAction(_ sender: Any) {
        let nextVC = getGenderMoreInfoVC()
        nextVC.userID = self.userId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnContinueAction(_ sender: Any) {
        if isAggrementCheck{
            createProfile()
        }else{
            showAlertView(message: "Please accept the agreement.")
        }
       
    }
    @IBAction func btnCheckAgreement(_ sender: Any) {
        isAggrementCheck.toggle()
        let imageName = isAggrementCheck ? "iconCheck" : "uncheck"
        btnCheckAggrement.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func btnShowAgreementAction(_ sender: Any) {
    }
    
}

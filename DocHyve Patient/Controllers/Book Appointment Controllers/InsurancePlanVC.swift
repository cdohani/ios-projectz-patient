//
//  InsurancePlanVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 11/03/2024.
//

import UIKit

class InsurancePlanVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblInsurance: UILabel!
    @IBOutlet weak var txtSearch: AuthTextField!
    @IBOutlet weak var tblInsurance: UITableView!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var imgNoData: UIImageView!
    
    
    
    //MARK: Variable
    var isPrimary = false
    var insuranceType = ""
    var memberID = ""
    var cardImage : UIImage?
    
    var selectedInsurance = InsuranceModel()
    var arrPlan = [InsurancePlanModel]()
    var arrFilterPlan = [InsurancePlanModel]()
    
    var arrSelectedPlanID: [Int] = []
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInsurancePlan()
        txtSearch.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        txtSearch.addDoneButtonOnKeyboard()
    }
    
    //MARK: Functions
    @objc func searchTextChanged(_ textField: UITextField) {
        filterData(with: textField.text ?? "")
    }
    func filterData(with searchText: String) {
        if searchText.isEmpty {
           arrFilterPlan = arrPlan
        } else {
            arrFilterPlan = arrPlan.filter { insurance in
                insurance.name.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        tblInsurance.reloadData()
    }

    
    func getInsurancePlan(){
        showLoadingView("")
        InsuracePlanService().getData(insuranceID: selectedInsurance.id, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? InsurancePlanReponseModel
                {
                    self.arrPlan = data.arrPlan
                    self.arrFilterPlan = self.arrPlan
                    tblInsurance.reloadData()

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func saveInsurance(){
       
        
        
        let param: [String: Any] = [
            "is_primary": isPrimary ? 1 : 0,
            "insurance_id": selectedInsurance.id,
            "insurance_plan_ids": arrSelectedPlanID,
            "card_member_id": memberID
        ]
        let endPoint =  Constants.URLs.saveUserInsurance
        
        showLoadingView("")
        
        let imageToSend = cardImage != nil ? cardImage : nil
        AddMemberService().addData(endPoint: endPoint,mimeType: "image/jpeg", image: imageToSend, parameters: param, paramName: "card_picture") { reponse in
            self.removeLoadingView()
            if let data = reponse as? String
            {
                self.showAlertViewWithCompletion(message: data) {
                    if let navigationController = self.navigationController {
                        for viewController in navigationController.viewControllers {
                            if viewController is AddedInsurnaceVC { // Replace with your view controller class
                                DataManager.shared.isDataUpdated = true
                                navigationController.popToViewController(viewController, animated: true)
                                break
                            }
                        }
                    }
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
    @IBAction func btnSaveAction(_ sender: Any) {
        if arrSelectedPlanID.isEmpty{
            showAlertView(message: "Please select your plan")
        }else{
            saveInsurance()
        }
        
    }
    
}
extension InsurancePlanVC : UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasData = !arrFilterPlan.isEmpty
        tblInsurance.alpha = hasData ? 1 : 0
        imgNoData.alpha = hasData ? 0 : 1
        return arrFilterPlan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsuranceTCell") as! InsuranceTCell
        cell.lblName.text = arrFilterPlan[indexPath.row].name
        
        let isSelected = arrSelectedPlanID.contains(arrFilterPlan[indexPath.row].id)
        cell.imgSelection.image = isSelected ? UIImage(systemName: "checkmark") : nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlanID = arrFilterPlan[indexPath.row].id
        if let index = arrSelectedPlanID.firstIndex(of: selectedPlanID) {
            arrSelectedPlanID.remove(at: index)
        } else {
            arrSelectedPlanID.append(selectedPlanID)
        }
        tblInsurance.reloadData()
    }
    
}

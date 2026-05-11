//
//  SurgicalHistoryVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class SurgicalHistoryVC: ParentViewController {
    //MARK: Outlets
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet var txtSearch: AuthTextField!
    
    
    
    //MARK: Variable
    var arrSelectedIndex = [Int]()
    var arrData = [HealthCheckModel]()
    var arrFilter = [HealthCheckModel]()
    
    var histrotyType  = MedicalCondition.surgicalHistory
    var memberID : Int?
    var isOther = false
    var otherHistoryText = ""
    var currentUserName = ""
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeading.text = "\(currentUserName)'s \(histrotyType.heading)"
        lblDesc.text = histrotyType.descHeading
        getHealthData()
    }
    
    //MARK: Functions
    func getHealthData(){
        showLoadingView("")
        let endPoint = histrotyType.endpoint
        GetHealthCheckService().getData(memberID: memberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel
                {
                    self.arrData = data.arrData
                    self.arrFilter = self.arrData
                    isOther = arrFilter.contains { item in
                        item.name.localizedCaseInsensitiveContains("Other") && item.isSelected
                    }
                    tblHistory.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    
    func saveData(){
        let selectedIDs = arrData
            .filter { $0.isSelected }
            .map { $0.id }
        
        let finalSelectedIDs = selectedIDs.isEmpty ? [] : selectedIDs
        
        var  param: [String: Any] = [
            histrotyType.storeEndpointKey: finalSelectedIDs,
        ]
        if isOther{
            param["other_name"] = otherHistoryText
        }
        if memberID != nil{
            param["member_id"] = memberID
        }
        let  endPoint =  histrotyType.storeEndpoint
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popViewController(animated: true)
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
    @IBAction func btnSaveAction(_ sender: Any) {
        if isOther{
            let indexPath = IndexPath(row: arrFilter.count, section: 0)
            
            guard let cell = tblHistory.cellForRow(at: indexPath) as? OtherHistoryTCell else {
                return
            }
            
            cell.validateNow { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    otherHistoryText = cell.txtOther.text ?? ""
                    self.saveData()
                }
            }
        }else{
            saveData()
        }
        
    }
    @IBAction func btnSwitchAction(_ sender: UISwitch) {
        if let index = arrData.firstIndex(where: { $0.id == sender.tag }) {
            arrData[index].isSelected = sender.isOn
            
        }
        if let index = arrFilter.firstIndex(where: { $0.id == sender.tag }) {
            arrFilter[index].isSelected = sender.isOn
            if arrFilter[index].name.contains("Other") {
                isOther = sender.isOn
                tblHistory.reloadData()
            }
            
        }
    }
    @IBAction func txtChangedAction(_ sender: UITextField) {
        let searchText = sender.text?.lowercased() ?? ""
           
           if searchText.isEmpty {
               arrFilter = arrData
           } else {
               arrFilter = arrData.filter { member in
                   return member.name.lowercased().contains(searchText)
               }
           }
           tblHistory.reloadData()
    }
    
}
extension SurgicalHistoryVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isOther ? arrFilter.count + 1 : arrFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isOther, indexPath.row == arrFilter.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherHistoryTCell") as! OtherHistoryTCell
            cell.txtOther.text = arrFilter[indexPath.row - 1].otherValue
            return cell
        }
        
        // Default "AccountSetting" cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingTCell") as! AccountSettingTCell
        cell.setCell(item: arrFilter[indexPath.row])
        cell.btnSwitch.tag = arrFilter[indexPath.row].id
        return cell
    }
}
    


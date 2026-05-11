//
//  MedicalHistoryVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class MedicalHistoryVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblHealth: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet var txtSearch: AuthTextField!
    
    
    
    //MARK: Variable
    var arrData = [HealthCheckModel]()
    var arrFilterData = [HealthCheckModel]()
    var memberID : Int?
    var currentUserName = ""
    var isOther = false
    var otherHistoryText = ""
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getHealthData()
        lblHeading.text = "\(currentUserName)'s Medical History"
    }
    
    //MARK: Functions
    
    func getHealthData(){
        showLoadingView("")
        let endPoint = Constants.URLs.getMedicalHistory
        GetHealthCheckService().getData(memberID: memberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel
                {
                    self.arrData = data.arrData
                    self.arrFilterData = self.arrData
                    isOther = arrFilterData.contains { item in
                        item.name.localizedCaseInsensitiveContains("Other") && item.isSelected
                    }
                    tblHealth.reloadData()
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
        
        var param: [String: Any] = [
            "medical_history_ids": finalSelectedIDs
        ]
        
        if isOther{
            param["other_name"] = otherHistoryText
        }
        if memberID != nil{
            param["member_id"] = memberID
        }
       let  endPoint =  Constants.URLs.saveMedicalHistory
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
        DataManager.shared.isDataUpdated = true
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        if isOther{
            let indexPath = IndexPath(row: arrFilterData.count, section: 0)
            
            guard let cell = tblHealth.cellForRow(at: indexPath) as? OtherHistoryTCell else {
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
        if let index = arrFilterData.firstIndex(where: { $0.id == sender.tag }) {
            arrFilterData[index].isSelected = sender.isOn
            if arrFilterData[index].name.contains("Other") {
                isOther = sender.isOn
                tblHealth.reloadData()
            }
            
        }
    }
    @IBAction func txtSearchChanged(_ sender: UITextField) {
        let searchText = sender.text?.lowercased() ?? ""
           
           if searchText.isEmpty {
               arrFilterData = arrData
           } else {
               arrFilterData = arrData.filter { member in
                   return member.name.lowercased().contains(searchText)
               }
           }
           tblHealth.reloadData()
    }
    
}
extension MedicalHistoryVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isOther ? arrFilterData.count + 1 : arrFilterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isOther, indexPath.row == arrFilterData.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherHistoryTCell") as! OtherHistoryTCell
            cell.txtOther.text = arrFilterData[indexPath.row - 1].otherValue
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalHistoryTCell") as! MedicalHistoryTCell
        
        cell.setData(item: arrFilterData[indexPath.row])
        cell.btnSwitch.tag = arrFilterData[indexPath.row].id
        return cell
    }
   
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40
//    }
    
}

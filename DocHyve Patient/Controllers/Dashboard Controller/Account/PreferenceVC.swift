//
//  PreferenceVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 23/02/2024.
//

import UIKit

class PreferenceVC: ParentViewController {
    //MARK: Outlets
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblSetting: UITableView!
    
    //MARK: Variable
 
    
    var histrotyType  = MedicalCondition.preference
    var arrSelectedIndex = [Int]()
    var arrData = [HealthCheckModel]()
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getPreferenceData()
    }
    
    //MARK: Functions
    
    func getPreferenceData(){
        showLoadingView("")
        let endPoint = histrotyType.endpoint
        GetPreferenceService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel
                {
                    self.arrData = data.arrData
                   
                    tblSetting.reloadData()
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
        
        let  param: [String: Any] = [
            histrotyType.storeEndpointKey: finalSelectedIDs,
        ]
        
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
    
    @IBAction func btnSwitchAction(_ sender: UISwitch) {
        arrData[sender.tag].isSelected = sender.isOn
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        saveData()
    }
    
}
extension PreferenceVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingTCell") as! AccountSettingTCell
        cell.setCell(item: arrData[indexPath.row])
        cell.btnSwitch.tag = indexPath.row
        return cell
    }
    
}

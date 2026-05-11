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
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwInfo: UIView!
    @IBOutlet var lblInfo: UILabel!
    @IBOutlet var lblInfoDesc: UILabel!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnContinue: UIButton!
    
    //MARK: Variable
 
    
    var histrotyType  = MedicalCondition.preference
    var arrSelectedIndex = [Int]()
    var arrData = [HealthCheckModel]()
    var selectedSwitch: UISwitch?
    var pendingSwitchTag: Int = -1
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        vwOverlay.alpha = 0
        vwInfo.alpha = 0
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
        // Only show alert for switch 0 and 1 when turning OFF
         if (sender.tag == 0 || sender.tag == 1) && !sender.isOn {
             
             // Hold switch state until confirmation
             sender.setOn(true, animated: true)
             
             vwOverlay.alpha = 0.3
             vwInfo.alpha = 1
             
             selectedSwitch = sender
             pendingSwitchTag = sender.tag
             
         } else {
             // Directly update for other cases
             arrData[sender.tag].isSelected = sender.isOn
         }
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        saveData()
    }
    @IBAction func btnCancelAction(_ sender: UIButton) {
        
         vwOverlay.alpha = 0
         vwInfo.alpha = 0
         
         // Keep switch ON
         selectedSwitch?.setOn(true, animated: true)
         
         selectedSwitch = nil
         pendingSwitchTag = -1
    }
    @IBAction func btnContinueAction(_ sender: UIButton) {
        vwOverlay.alpha = 0
          vwInfo.alpha = 0
          
          guard let selectedSwitch = selectedSwitch,
                pendingSwitchTag != -1 else { return }
          
          // Turn OFF after confirmation
          selectedSwitch.setOn(false, animated: true)
          
          arrData[pendingSwitchTag].isSelected = false
          
          self.selectedSwitch = nil
          pendingSwitchTag = -1
          
          tblSetting.reloadData()
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

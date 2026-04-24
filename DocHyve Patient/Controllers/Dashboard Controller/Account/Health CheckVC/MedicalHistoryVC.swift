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
    
    
    
    //MARK: Variable
    var arrData = [HealthCheckModel]()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getHealthData()
    }
    
    //MARK: Functions
    
    func getHealthData(){
        showLoadingView("")
        let endPoint = Constants.URLs.getMedicalHistory
        GetHealthCheckService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel
                {
                    self.arrData = data.arrData
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
        
        let param: [String: Any] = [
            "medical_history_ids": finalSelectedIDs
        ]
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
        saveData()
    }
    
}
extension MedicalHistoryVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalHistoryTCell") as! MedicalHistoryTCell
        
        cell.setData(item: arrData[indexPath.row])

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrData[indexPath.row].isSelected.toggle()
        tblHealth.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

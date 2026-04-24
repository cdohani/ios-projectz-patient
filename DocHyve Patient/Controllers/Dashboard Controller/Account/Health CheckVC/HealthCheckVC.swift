//
//  HealthCheckVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class HealthCheckVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblHealth: UITableView!
    @IBOutlet weak var btnViewHealth: UIButton!
    @IBOutlet weak var vwContainer: UIView!
    
    
    
    //MARK: Variable
    var arrData = [HealthCheckModel]()
    var arrHealth = ["Medical History","Surgical History","Allergies","Medications","Family History","Social History"]
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customization()
    }
    override func viewWillAppear(_ animated: Bool) {
        if  DataManager.shared.isDataUpdated {
            DataManager.shared.isDataUpdated = false
            getHealthData()
        }
    }
  
    func customization(){
        if isUserLoggedIn(){
            vwContainer.isHidden = true
            tblHealth.isHidden = false
            btnViewHealth.isHidden = false
            getHealthData()
           
        }else{
            vwContainer.isHidden = false
            tblHealth.isHidden = true
            btnViewHealth.isHidden = true

        }
    }
    //MARK: Functions
    func getHealthData(){
    
        showLoadingView("")
        let endPoint = Constants.URLs.getHealthCheckHistory
        GetHealthCheckHistoryService().getData(apiEndPoint: endPoint, completion: { (response) in
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
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnViewHealthAction(_ sender: Any) {
        let nextVC = getAllHealthCheckVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnFindDoctorAction(_ sender: Any) {
//        if let parent = self.parent as? DashboardVC {
//            parent.selectTab(index: 0)
//        }
        let nextVC = getFindDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)

    }
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

}
extension HealthCheckVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthCheckTCell") as! HealthCheckTCell
        cell.setData(item: arrData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrData[indexPath.row]

        switch item.id {
        case 1:
            let nextVC = getMedicalHistoryVC()
            navigationController?.pushViewController(nextVC, animated: true)

        case 2:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .surgicalHistory
            navigationController?.pushViewController(nextVC, animated: true)

        case 3:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .allergyHistory
            navigationController?.pushViewController(nextVC, animated: true)

        case 4:
            let nextVC = getAddedMedicationVC()
            navigationController?.pushViewController(nextVC, animated: true)

        case 5:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .familyHistory
            navigationController?.pushViewController(nextVC, animated: true)

        case 6:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .socialHistory
            navigationController?.pushViewController(nextVC, animated: true)

        default:
            break
        }
    }
    
}

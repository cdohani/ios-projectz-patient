//
//  AddedMedicationVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 18/03/2024.
//

import UIKit

class AddedMedicationVC: ParentViewController {

    //MARK: Outlets
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblMedication: UILabel!
    @IBOutlet weak var vwMedicationTop: UIView!
    @IBOutlet weak var lblMedicationVal: UILabel!
    @IBOutlet weak var btnAddMedication: UIButton!
    @IBOutlet weak var vwNoData: UIView!
    @IBOutlet weak var lblAddMed: UILabel!
    @IBOutlet weak var btnAddMed: UIButton!
    @IBOutlet weak var tblMedication: UITableView!
    
    
    //MARK: Variable
 
    var arrData = [MedicineDetailModel]()
    var memberID : Int?
    var currentUserName = ""
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //e arrData = [1,2,3]
        lblHeading.text = "\(currentUserName)'s Medication"
        tblMedication.isHidden = true
        vwMedicationTop.isHidden = true
        getMedicineData()
    }
    
    //MARK: Functions
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated {
            DataManager.shared.isDataUpdated = false
            getMedicineData()
        }
    }
    func getMedicineData(){
        showLoadingView("")
        let endPoint = Constants.URLs.getMedicationHistory
        GetMedicationHistoryService().getData(memberID: memberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MedicationReponseModel
                {
                    self.arrData = data.arrData
                    tblMedication.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func deleteMedication(id:Int){
      
        let param: [String: Any] = [
            "id": id,
        ]
        let endPoint =  Constants.URLs.deleteMedicationHistory
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                        if let index = arrData.firstIndex(where: { $0.id == id }) {
                            arrData.remove(at: index)
                            tblMedication.reloadData()
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
    @IBAction func btnAddMedicationAction(_ sender: Any) {
        let nextVC = getAddNewMedicationVC()
        nextVC.memberID = memberID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnAddMedAction(_ sender: Any) {
        let nextVC = getAddNewMedicationVC()
        nextVC.memberID = memberID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnEditMedicationAction(_ sender: UIButton) {
        let nextVC = getAddNewMedicationVC()
        nextVC.memberID = memberID
        nextVC.isForEdit = true
        nextVC.medicineInfo = arrData[sender.tag]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnDeleteMedicationAction(_ sender: UIButton) {
        deleteMedication(id: arrData[sender.tag].id)
    }
    
}
extension AddedMedicationVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasData = !arrData.isEmpty

        tblMedication.isHidden = !hasData
        vwMedicationTop.isHidden = !hasData
        vwNoData.isHidden = hasData

        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationTCell") as! MedicationTCell
        cell.setData(item: arrData[indexPath.row])
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        return cell
    }
   
    
}

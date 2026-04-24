//
//  AddedInsurnaceVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 29/04/2024.
//

import UIKit

class AddedInsurnaceVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var vwAddInsurance: UIView!
    @IBOutlet weak var vwNoRecord: UIView!
    @IBOutlet weak var tblInsurance: UITableView!
    @IBOutlet weak var btnAddInsurance: UIButton!
    @IBOutlet weak var btnAddInsurance1: UIButton!
    
    //MARK: Variable
    var arrData = [UserInsuranceModel]()
    var isFromMemberScreen = false
    weak var dataDelegate: TransferDataDelegate?
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //arrData.append(1)
    
        customization()
        getInsurance()
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            getInsurance()
        }
    }
    //MARK: Functions
    func customization(){
        vwAddInsurance.alpha = 0
        vwNoRecord.alpha = 1
        tblInsurance.alpha = 0
    }
    func getInsurance(){
        showLoadingView("")
        GetUserInsuranceService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? UserInsuranceReponseModel
                {
                    self.arrData = data.arrData
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
    func deleteInsurance(id:Int){
      
        let param: [String: Any] = [
            "patient_insurance_id": id,
        ]
        let endPoint =  Constants.URLs.deleteInsurance
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                        if let index = arrData.firstIndex(where: { $0.id == id }) {
                            arrData.remove(at: index)
                            tblInsurance.reloadData()
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
    @IBAction func btnAddInsuranceAction(_ sender: Any) {
        let nextVC = getAddNewInsuranceVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnAddInsurance1Action(_ sender: Any) {
        let nextVC = getAddNewInsuranceVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnDeleteInsuranceAction(_ sender: UIButton) {
        deleteInsurance(id: arrData[sender.tag].id)
    }
}

extension AddedInsurnaceVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasData = !arrData.isEmpty

        vwAddInsurance.alpha = hasData ? 1 : 0
        vwNoRecord.alpha     = hasData ? 0 : 1
        tblInsurance.alpha   = hasData ? 1 : 0

        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddedInsuranceTCell") as! AddedInsuranceTCell
        cell.setData(data:arrData[indexPath.row] )
        cell.btnDelet.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromMemberScreen{
            dataDelegate?.sendData(arrData[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
    }
   
    
}

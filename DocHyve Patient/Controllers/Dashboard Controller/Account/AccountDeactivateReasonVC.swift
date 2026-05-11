//
//  AccountDeactivateReasonVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 04/05/2026.
//

import UIKit

class AccountDeactivateReasonVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var tblReason: UITableView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblReason: UILabel!
    @IBOutlet var btnDeactivate: UIButton!
    @IBOutlet var btnCancel: UIButton!
    
    
    
    //MARK: Variable
    var arrData = [DropDownModel]()
    var arrSelectedIDs = [Int]()
    var isOtherSelected: Bool = false
    var otherText: String = ""
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getDeactivateAccountReason()
    }
    
    //MARK: Functions
    func getDeactivateAccountReason(){
        showLoadingView("")
        GetDeactivateAccountService().getData( completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? DropDownResponseModel
                {
                    
                    arrData = data.arrData
                    tblReason.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func deactivateAccount(){
        let param: [String: Any] = [
            "reason_ids": arrSelectedIDs ,
            "custom_reason": otherText,
        ]
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.deactivateAccount,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                        let defaults = UserDefaults.standard
                        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setLandingScreen()
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
    @IBAction func btnDeactivateAction(_ sender: Any) {
        if arrSelectedIDs.isEmpty{
            showAlertView(message: "Please select reason for account deactivation.")
        }else{
            if isOtherSelected{
                let indexPath = IndexPath(row: arrData.count, section: 0)
                
                guard let cell = tblReason.cellForRow(at: indexPath) as? OtherHistoryTCell else {
                    return
                }
                
                cell.validateNow { [weak self] valid in
                    guard let self = self else { return }
                    if valid {
                        otherText = cell.txtOther.text ?? ""
                        self.deactivateAccount()
                    }
                }
            }else{
                deactivateAccount()
            }
        }
        
        
    }
    @IBAction func btnCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AccountDeactivateReasonVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOtherSelected ? arrData.count + 1 : arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Extra "Other" textfield cell
        if isOtherSelected && indexPath.row == arrData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherHistoryTCell", for: indexPath) as! OtherHistoryTCell
            return cell
        }
        
        // Normal reason cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDeactivateReasonTCell", for: indexPath) as! AccountDeactivateReasonTCell
        
        let item = arrData[indexPath.row]
        cell.setData(item: item)
        
        if arrSelectedIDs.contains(item.id) {
            cell.imgOption.image = UIImage(systemName: "checkmark.square.fill")
            cell.imgOption.tintColor = UIColor(named: "customBlueColor")
        } else {
            cell.imgOption.image = UIImage(systemName: "square")
            cell.imgOption.tintColor = UIColor.lightGray
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Prevent tapping extra textfield cell
        if isOtherSelected && indexPath.row == arrData.count {
            return
        }
        
        let item = arrData[indexPath.row]
        let id = item.id
        
        // Toggle selection
        if arrSelectedIDs.contains(id) {
            arrSelectedIDs.removeAll { $0 == id }
        } else {
            arrSelectedIDs.append(id)
        }
        
        // Handle "Other"
        if item.name.lowercased() == "other" || item.name.lowercased() == "others" {
            
            isOtherSelected = arrSelectedIDs.contains(id)
            
            // Clear text when removing Other
            if !isOtherSelected {
                otherText = ""
            }
        }
        
        tblReason.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isOtherSelected, indexPath.row == arrData.count {
            return 100
        }else{
            return 40
        }
        
    }
    
}



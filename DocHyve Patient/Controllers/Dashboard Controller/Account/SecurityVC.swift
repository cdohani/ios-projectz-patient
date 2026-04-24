//
//  SecurityVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 26/02/2024.
//

import UIKit

class SecurityVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet var btnSave: UIButton!
    
    
    
    //MARK: Variable
   
    var data = TwoFactorAuthReponseModel()
    var switchStatus: Bool = false
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSecurityData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            getSecurityData()
        }
    }
    
    //MARK: Functions
    func getSecurityData(){
        showLoadingView("")
        
        GetTwoFactorAuthService().getData(apiEndPoint: Constants.URLs.getSecurity, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? TwoFactorAuthReponseModel
                {
                    self.data = data
                    switchStatus = data.isTwoFactorAuthEnabled
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
    
    func sendSecurityCode(){
        let param: [String: Any] = [:]
        
        showLoadingView("")
        let endPoint =  Constants.URLs.sendPhoneVerificationCode
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if success is GeneralResponseModel
                {
                    let nextVC = getVerifyEmailVC()
                    nextVC.isPhoneVerify = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
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
        switchStatus = sender.isOn
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        sendSecurityCode()
    }
    
}
extension SecurityVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwoFATCell") as! TwoFATCell
        
        if indexPath.row == 0{
            cell.lblHeading.text = "Phone Number"
            cell.lblDesc.text =  data.phoneNum != "" ? data.phoneNum : "Required for notifications, reminders, and account access."
            cell.btnSwitch.isHidden = true
            cell.imgNext.isHidden = false
            if data.isVerifiedPhone{
                cell.imgNext.image = UIImage(named: "tick")
            }else{
                cell.imgNext.image = UIImage(named: "cross")
            }
        }else{
            cell.lblHeading.text = "Two Step Verification"
            cell.lblDesc.text = "Additional security layer for account access."
            cell.btnSwitch.isHidden = false
            cell.imgNext.isHidden = true
            cell.btnSwitch.isOn = data.isTwoFactorAuthEnabled
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
    }
    
}

//
//  SecurityVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 23/02/2024.
//

import UIKit

class PasswordSettingVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwDeactivateAccount: UIView!
    @IBOutlet var lblDeactivateHeading: UILabel!
    @IBOutlet var lblDesc: UILabel!
    
    //MARK: Variable
    var arrAccount :[(heading: String, desc: String)] = [("Update Password","Last update a month ago"),("Connected Accounts","You are connected with Google Account"),("Account","Deactivate your account")]
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vwOverlay.alpha = 0
        vwDeactivateAccount.alpha = 0
    }
    override func viewDidLayoutSubviews() {
        vwDeactivateAccount.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    //MARK: Functions
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnClose(_ sender: Any) {
        vwOverlay.alpha = 0
        vwDeactivateAccount.alpha = 0
    }
    
    @IBAction func btnDeactivateAction(_ sender: Any) {
        let nextVC = getAccountDeactivateReasonVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
}

extension PasswordSettingVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAccount.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecurityTCell") as! SecurityTCell
        cell.lblHeading.text = arrAccount[indexPath.row].heading
        cell.lblDesc.text = arrAccount[indexPath.row].desc
        cell.hideInfo(currentIndex: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let nextVC = getUpdatePasswordVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if indexPath.row == 2{
            vwOverlay.alpha = 0.3
            vwDeactivateAccount.alpha = 1
        }
       
    }
}

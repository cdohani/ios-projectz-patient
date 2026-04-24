//
//  SettingVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit

class SettingVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblSetting: UITableView!
    
    
    
    //MARK: Variable
    
    
    var arrAccount = ["Profile","Change Password","Security","Preferences"]
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Functions
    
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension SettingVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAccount.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingTCell") as! AccountSettingTCell
        cell.lblOption.text = arrAccount[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let nextVC = getProfileVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if indexPath.row == 1{
            let nextVC = getPasswordSettingVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if indexPath.row == 2{
            let nextVC = getSecurityVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if indexPath.row == 3{
            let nextVC = getPreferenceVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if indexPath.row == 4{
            let nextVC = getPermissionVC()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}

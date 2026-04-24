//
//  MyAccountVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit

class MyAccountVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet weak var vwContainer: UIView!
    
    
    //MARK: Variable
    var accountItems: [SettingItem] {
        [
            SettingItem(icon: "11", title: "Insurance") { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(getAddedInsurnaceVC(), animated: true)
            },
            SettingItem(icon: "1", title: "Settings") { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(getSettingVC(), animated: true)
            },
            SettingItem(icon: "10", title: "Members") { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(getAddedMemberVC(), animated: true)
            },
            SettingItem(icon: "4", title: "Contact Us") { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(getContactUsVC(), animated: true)
            }
        ]
    }
    
    var loginItems: [SettingItem] {
        [
            SettingItem(icon: "13", title: "Sign In") {
                [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(MyAccountVC.getLoginVC(), animated: true)
            },
            SettingItem(icon: "12", title: "Sign Up") {
                [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(MyAccountVC.getLoginVC(), animated: true)
            },
            SettingItem(icon: "4", title: "Contact Us") {
                [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(getContactUsVC(), animated: true)
            }
        ]
    }

    var privacyItems: [SettingItem] {
        [
            SettingItem(icon: "5", title: "Terms of Use") { [weak self] in
                guard let self = self else { return }
                self.showPrivacy()
            },
            SettingItem(icon: "6", title: "Privacy Choice") { [weak self] in
                guard let self = self else { return }
                self.showPrivacy()
            },
            SettingItem(icon: "7", title: "Privacy Policy") { [weak self] in
                guard let self = self else { return }
                self.showPrivacy()
            }
        ]
    }

    var otherItemsLoggedIn: [SettingItem] {
        [
            SettingItem(icon: "8", title: "Send App Feedback") {},
            SettingItem(icon: "9", title: "Share DocHyve") {},
            SettingItem(icon: "3", title: "Log Out") { [weak self] in
                self?.logOut()
            }
        ]
    }

    var otherItemsLoggedOut: [SettingItem] {
        [
            SettingItem(icon: "8", title: "Send App Feedback") {},
            SettingItem(icon: "9", title: "Share DocHyve") {}
        ]
    }

    // MARK: - Build Table Sections Based on Login
    var tableSections: [[SettingItem]] {
        if isUserLoggedIn() {
            return [
                accountItems,
                privacyItems,
                otherItemsLoggedIn
            ]
        } else {
            return [
                loginItems,
                privacyItems,
                otherItemsLoggedOut
            ]
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSetting.reloadData()
        customization()
    }

    func customization() {
        vwContainer.isHidden = true
        tblSetting.isHidden = false
    }

    // MARK: - Logout
    func logOut() {
        let defaults = UserDefaults.standard
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setLandingScreen()
    }
    
    func showPrivacy(){
        if let url = URL(string: "http://frontend.dochyve.com/en/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
        
    //MARK: ButtonActions
    @IBAction func btnFindDoctorAction(_ sender: Any) {
    }
    @IBAction func btnLoginAction(_ sender: Any) {
    }
    
}
extension MyAccountVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AccountSettingTCell",
            for: indexPath
        ) as! AccountSettingTCell

        let item = tableSections[indexPath.section][indexPath.row]

        cell.lblOption.text = item.title
        cell.imgOption.image = UIImage(named: item.icon)
        
        // Hide arrow ONLY for logout
        cell.imgNext.isHidden = (item.title == "Log Out")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = tableSections[indexPath.section][indexPath.row]
        item.action()   // Call the assigned action
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTCell") as! AccountHeaderTCell
 
        cell.lblHeader.text = [
            "Account",
            "Policies",
            "Other"
        ][section]

        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

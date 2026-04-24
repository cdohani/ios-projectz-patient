//
//  ContactUsVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 26/02/2024.
//

import UIKit

class ContactUsVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblGetinTouch: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblContact: UITableView!
    
    
    
    //MARK: Variable
    var arrAccount :[(icon:String,heading: String, desc: String)] = [("iconEmail","Email","support@dochyve.com"),("iconChat","Chat","Tap here to chat instantly!"),("iconPhone","Call","+012 23 45 678 952")]
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Functions
    
    func sendMail(){
        let email = "support@dochyve.com"

           if let url = URL(string: "mailto:\(email)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           }
    }
    func openDailer(){
        let phoneNumber = "+012 23 45 678 952"   // no spaces, no dashes

           if let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           }
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ContactUsVC : UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAccount.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactUsTCell") as! ContactUsTCell
        cell.imgOption.image = UIImage(named: arrAccount[indexPath.row].icon)
        cell.lblTitle.text = arrAccount[indexPath.row].heading
        cell.lblDesc.text = arrAccount[indexPath.row].desc
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            sendMail()
        }else if indexPath.row == 2{
            openDailer()
        }
    }
}

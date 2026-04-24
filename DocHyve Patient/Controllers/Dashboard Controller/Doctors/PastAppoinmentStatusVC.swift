//
//  PastAppoinmentVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 21/03/2024.
//

import UIKit
import Cosmos

class PastAppoinmentStatusVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    
    @IBOutlet weak var tblApptStatus: UITableView!
    
    //MARK: Variable
    var selectedProviderID = -1
    var docInfo = FavouriteProviderModel()
    var providerData = ProviderAppointmentDetail()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getAppointmentDetail()
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            getAppointmentDetail()
        }else{
            tblApptStatus.reloadData()
        }
    }
    
    //MARK: Functions
    
    func getAppointmentDetail(){
        showLoadingView("")
        GetProviderAppointmentService().getData(providerID: selectedProviderID, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? ProviderAppointmentReponseModel
                {
                    self.providerData = data.providerData
                    tblApptStatus.reloadData()
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
    
}
extension PastAppoinmentStatusVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerData.arrAppointment.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedDoctorTCell") as! SavedDoctorTCell
            cell.SetCellData(item: docInfo)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PastApptStatusTCell") as! PastApptStatusTCell
            cell.setData(item: providerData.arrAppointment[indexPath.row - 1])
            if providerData.arrAppointment[indexPath.row - 1].status == "completed" &&  !providerData.arrAppointment[indexPath.row - 1].isReviewed {
                cell.startBlinking()
            }
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            if providerData.arrAppointment[indexPath.row - 1].status == "completed" &&  !providerData.arrAppointment[indexPath.row - 1].isReviewed {
                
             
                let nextVC = getReviewDoctorVC()
                
                nextVC.appointmentID = providerData.arrAppointment[indexPath.row - 1].id
                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }else{
                let nextVC = DoctorVC.getDoctorDetailVC()
                nextVC.providerID = selectedProviderID
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }else{
            let nextVC = DoctorVC.getDoctorDetailVC()
            nextVC.providerID = selectedProviderID
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
            
       
    }
    
    
}

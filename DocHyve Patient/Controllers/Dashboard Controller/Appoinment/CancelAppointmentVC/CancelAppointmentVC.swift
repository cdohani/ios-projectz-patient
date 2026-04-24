//
//  CancelAppointmentReasonVC.swift
//  DocHyve Patient
//
//  Created by Adeel Ahmed on 10/30/25.
//

import UIKit

class CancelAppointmentReasonVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblCancelThisAppointment: UILabel!
    @IBOutlet weak var lblAppointmentInfo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblWhyCancelAppointment: UILabel!
    @IBOutlet weak var tblReason: UITableView!
    @IBOutlet weak var btnKeepAppointment: UIButton!
    @IBOutlet weak var btnContinueCancel: UIButton!
    
    
    //MARK: Variable
    var arrData = [CancelAppointmentReason]()
    var selectedReasonID = -1
    var appointmentID = -1
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getReasonData()
    }
    
    //MARK: Functions
    
    func getReasonData(){
        showLoadingView("")
        let endPoint = Constants.URLs.cancelAppointmentReason
        CancelAppointmentReasonService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? CancelAppointmentResponseModel
                {
                    self.arrData = data.arrReason
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
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnKeepAppointmentAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContinueCancelAction(_ sender: Any) {
        if selectedReasonID == -1{
            showAlertView(message: "Please select cancel reason.")
        }else{
            let nextVC = getCancelAppointmentQuestionVC()
            nextVC.appointmentid = appointmentID
            nextVC.cancelReasonID = selectedReasonID
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
       
    }
    
}
extension CancelAppointmentReasonVC :UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalHistoryTCell") as! MedicalHistoryTCell
        cell.lblName.text = arrData[indexPath.row].reason
        if arrData[indexPath.row].id == selectedReasonID{
            cell.imgSelect.image = UIImage(named: "iconRadioSelect")
        }else{
            cell.imgSelect.image = UIImage(named: "iconRadioUnSelect")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReasonID = arrData[indexPath.row].id
        tblReason.reloadData()
    }

}


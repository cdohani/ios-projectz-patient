//
//  CancelAppointmentQuestionVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 31/10/2025.
//

import UIKit

class CancelAppointmentQuestionVC: ParentViewController {
    
    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblQuestion1Heading: UILabel!
    @IBOutlet var lblQuestion1Decscription: UILabel!
    @IBOutlet var btnQuestion1: [UIButton]!
    @IBOutlet var lblQ1Yes: UILabel!
    @IBOutlet var lblQ1No: UILabel!
    
    
    @IBOutlet var lblQuestion2Heading: UILabel!
    @IBOutlet var lblQuestion2Desc: UILabel!
    
    
    @IBOutlet var btnQuestion2: [UIButton]!
    @IBOutlet var lblQ2Yes: UILabel!
    @IBOutlet var lblQ2No: UILabel!
    
    
    @IBOutlet var btnCancelAppointment: UIButton!
    //MARK: Variable
    var isCommunicatedDoc = true
    var isFindOutside = true
    var appointmentid  = -1
    var cancelReasonID = -1
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Functions
    
    func saveData(){
        
        let param: [String: Any] = [
            "primary_reason_id":cancelReasonID ,
            "communicated_with_provider": isCommunicatedDoc,
            "found_care_outside_platform": isFindOutside,
        ]
        let endPoint =   String(format: Constants.URLs.saveCancelAppointment, appointmentid)
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popToRootViewController(animated: true)
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
    @IBAction func btnQuestion1Action(_ sender: UIButton) {
        for button in btnQuestion1 {
            let imageName = (button.tag == sender.tag) ? "iconRadioSelect" : "iconRadioUnSelect"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        isCommunicatedDoc = (sender.tag == 1) ? true : false
    }
    
    @IBAction func btnQuestion2Action(_ sender: UIButton) {
        for button in btnQuestion2 {
            let imageName = (button.tag == sender.tag) ? "iconRadioSelect" : "iconRadioUnSelect"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        isFindOutside = (sender.tag == 1) ? true : false
    }
    
    @IBAction func btnCancelAppointmentAction(_ sender: Any) {
        saveData()
    }
    
}

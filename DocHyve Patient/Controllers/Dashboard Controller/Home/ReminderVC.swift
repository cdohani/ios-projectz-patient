//
//  ReminderVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 29/02/2024.
//

import UIKit

class ReminderVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPastApptDate: UILabel!
    @IBOutlet weak var txtPastAppt: AuthTextField!
    @IBOutlet weak var lblSelectTime: UILabel!
    @IBOutlet weak var txtStartTime: AuthTextField!
    @IBOutlet weak var txtEndTime: AuthTextField!
    @IBOutlet weak var lblReminderOption1: UILabel!
    @IBOutlet var btnReminder: [UIButton]!
    @IBOutlet weak var lblSms: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblBoth: UILabel!
    
    @IBOutlet var btnReminderSequence: [UIButton]!
    @IBOutlet weak var lblOneDay: UILabel!
    @IBOutlet weak var lblTwoDay: UILabel!
    @IBOutlet weak var lblThreeDay: UILabel!
    
    
    @IBOutlet weak var btnSave: UIButton!
    
    //MARK: Variable
    
    
    
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
    @IBAction func btnSwitchAction(_ sender: UISwitch) {
        if sender.isOn{
            vwContainer.isHidden = false
            vwContainerHeight.constant = 520
        }else{
            vwContainer.isHidden = true
            vwContainerHeight.constant = 0
        }
        
    }
    @IBAction func btnPastApptAction(_ sender: Any) {
    }
    @IBAction func btnSaveAction(_ sender: Any) {
    }
    
}

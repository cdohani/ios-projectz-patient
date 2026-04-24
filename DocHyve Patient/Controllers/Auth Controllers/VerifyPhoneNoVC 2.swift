//
//  VerifyEmailVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit
import PinCodeTextField

class VerifyPhoneNoVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblVerify: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var txtPin: PinCodeTextField!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet var lblCodeNotReceived: UILabel!
    @IBOutlet var lblTimer: UILabel!
    @IBOutlet var btnSendCodeAgain: UIButton!
    @IBOutlet var lblAttemptLeft: UILabel!
    
    
    
    //MARK: Variable
   
    var phone = ""
    var isFromBookingScreen = false
    
    var timer: Timer?
    var remainingSeconds = 60
    var maxAttempts = 3
    var currentAttempts = 0
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblVerify.text = "Verify Phone No"
        lblDesc.text = "Enter the code we have sent by email to \(phone)."
        
        lblAttemptLeft.text = "Attempts left: \(maxAttempts - currentAttempts)"
        startResendTimer()
    }
    
    //MARK: Functions
    
    func startResendTimer() {
        // Disable button
        btnSendCodeAgain.isEnabled = false
        btnSendCodeAgain.alpha = 0.5   // visually disabled

        remainingSeconds = 60
        lblTimer.text = "01:00"

        // Start Timer
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func updateTimer() {
        remainingSeconds -= 1

        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        lblTimer.text = String(format: "%02d:%02d", minutes, seconds)

        if remainingSeconds <= 0 {
            timer?.invalidate()
            timer = nil

            lblTimer.text = ""          // hide timer or set "00:00"
            btnSendCodeAgain.isEnabled = true
            btnSendCodeAgain.alpha = 1.0
        }
    }
    
    func sendCode(){
        let param: [String: Any] = [
            "Phone_number": phone,
        ]
        
        showLoadingView("")
        let endPoint =  Constants.URLs.addNewPhoneNo
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertView(message: data.message)
                }

            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    func callVerifyApi(){
        let param: [String: Any] = [
            "code": txtPin.text ?? ""
        ]
        showLoadingView("")
        let endPoint =  Constants.URLs.verifyPhoneNo
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    if  data.status != 200 && data.status != 201{
                        self.showAlertView(message: data.message)
                    }
                    else{
                        if isFromBookingScreen{
                            self.showAlertViewWithCompletion(message: data.message) {
                                if let navigationController = self.navigationController {
                                    for viewController in navigationController.viewControllers {
                                        if viewController is BookApptVC { // Replace with your view controller class
                                            DataManager.shared.isDataUpdated = true
                                            navigationController.popToViewController(viewController, animated: true)
                                            break
                                        }
                                    }
                                }
                            }
                        }else{
                            showAlertViewWithCompletion(message: data.message) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
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
    
    @IBAction func btnSendCodeAgainAction(_ sender: Any) {
        if currentAttempts >= maxAttempts {
            // User reached limit
            showAlertView(message: "You have reached the maximum resend attempts.")
            return
        }
        
        currentAttempts += 1
        
        lblAttemptLeft.text = "Attempts left: \(maxAttempts - currentAttempts)"
        // Start countdown timer
        startResendTimer()
        
        // Call API here
        sendCode()
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        self.view.endEditing(true)
        if txtPin.text == ""{
            showAlertView(message: "Please add verification code")
        }else{
            self.callVerifyApi()
        }
       
       
    }
    
}

//
//  PermissionVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 23/02/2024.
//

import UIKit

class PermissionVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var lblUseInfo: UILabel!
    @IBOutlet weak var btnDownloadInfo: UIButton!
    @IBOutlet weak var lblDownloadInfo: UILabel!
    @IBOutlet weak var btnSaveAction: UIButton!
    
    
    
    //MARK: Variable
    var status = 0
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getPremissionData()
    }
    
    //MARK: Functions
    
    func getPremissionData(){
        showLoadingView("")
        
        GetPermissionService().getData(apiEndPoint: Constants.URLs.getPremissionAutoComplete, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? Int
                {
                    status = data
                    changeImage()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func changeImage(){
        if status == 1{
            btnAgree.setImage(UIImage(named: "iconCheck"), for: .normal)
        }else{
            btnAgree.setImage(UIImage(named: "uncheck"), for: .normal)
        }
    }
    func saveData(){
        let  param: [String: Any] = [
            "status": status,
        ]
        
        let  endPoint =  Constants.URLs.savePremissionAutoComplete
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popViewController(animated: true)
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
    @IBAction func btnAgreeAction(_ sender: Any) {
        status = (status == 0) ? 1 : 0
        changeImage()
    }
    
    @IBAction func btnDownloadInfoAction(_ sender: Any) {
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        saveData()
    }
}

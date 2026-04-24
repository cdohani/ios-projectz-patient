//
//  SurvyVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 18/03/2024.
//

import UIKit

class SurvyVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblSurvy: UITableView!
    //MARK: Variable
    var arrData = [DropDownModel]()
    var selectedID = [Int]()
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getHeardAboutData()
    }
    
    //MARK: Functions
    func getHeardAboutData(){
        showLoadingView("")
        GetHeardAboutService().getData( completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? DropDownResponseModel
                {
                    self.arrData = data.arrData
                    tblSurvy.reloadData()

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func saveData(){
       
    
        let param: [String: Any] = [
            "heard_from_ids": selectedID
        ]
        let endPoint =  Constants.URLs.saveHeardAbout
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        if let navigationController = self.navigationController {
                            for viewController in navigationController.viewControllers {
                                if viewController is DashboardVC { // Replace with your view controller class
                                    HomeDataManager.shared.isHomeUpdated = true
                                    navigationController.popToViewController(viewController, animated: true)
                                    break
                                }
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
    
}

extension SurvyVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurvyTCell") as! SurvyTCell
        cell.lblOption.text = arrData[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID.append( arrData[indexPath.row].id)
        saveData()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTCell") as! AccountHeaderTCell
        return  cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

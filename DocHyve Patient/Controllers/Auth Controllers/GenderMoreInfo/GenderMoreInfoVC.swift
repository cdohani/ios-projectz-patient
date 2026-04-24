//
//  GenderMoreInfoVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit

class GenderMoreInfoVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblMoreGender: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblGenders: UITableView!
    
    
    //MARK: Variable
    var userID = -1
    var arrGenders = [GenderInfo]()
    var arrSelectedGender = [Int]()
    var selectedGender = SelectedGenderResponseModel()
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getGenderData()
    }
    
    //MARK: Functions
    
    func getGenderData(){
        showLoadingView("")
        GetAllGenderService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? GenderResponseModel
                {
                    
                    self.arrGenders = data.arrGender
                    getUserSelectedGender()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getUserSelectedGender(){
        showLoadingView("")
        GetSelectedGenderService().getData(userID: userID, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? SelectedGenderResponseModel
                {
                    self.selectedGender = data
                    let otherGenderString = selectedGender.selectedGender.components(separatedBy: ",")
                    let otherGender: [Int] = otherGenderString.compactMap { Int($0) }
                    for item in otherGender{
                        arrSelectedGender.append(item)
                    }
                    tblGenders.reloadData()
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
            "extra_genders": arrSelectedGender,
            "user_id": userID,
        ]
        let endPoint =  Constants.URLs.saveSelectedGender
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    if  data.status == 200 ||  data.status == 201 {
                        self.showAlertViewWithCompletion(message: data.message) { [self] in
                            DataManager.shared.isDataUpdated = true
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        self.showAlertViewWithCompletion(message: data.message) {
                            DataManager.shared.isDataUpdated = true
                            self.navigationController?.popViewController(animated: true)
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
    @IBAction func btnSaveAction(_ sender: Any) {
        if arrSelectedGender.isEmpty{
            self.navigationController?.popViewController(animated: true)
        }else{
            saveData()
        }
        
    }
    
}
extension GenderMoreInfoVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrGenders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenderInfoTCell") as! GenderInfoTCell
        cell.lblHeading.text = arrGenders[indexPath.row].name
        cell.lblDesc.text = arrGenders[indexPath.row].description
        if arrSelectedGender.contains( arrGenders[indexPath.row].id) {
            cell.imgSelection.image = UIImage(named: "iconCheck")
        }else{
            cell.imgSelection.image = UIImage(named: "uncheck")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrSelectedGender.contains( arrGenders[indexPath.row].id) {
            if let index = arrSelectedGender.firstIndex(of: arrGenders[indexPath.row].id) {
                arrSelectedGender.remove(at: index)
            }
        }else{
            arrSelectedGender.append(arrGenders[indexPath.row].id)
        }
        tblGenders.reloadData()
    }
}

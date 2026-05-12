//
//  AllHealthCheckVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 24/10/2025.
//

import UIKit

class AllHealthCheckVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var tblDetail: UITableView!
    
    //MARK: Variable
    var arrData = [AllHealthRecordDetail]()
    var selectedIndex = -1
    var memberID : Int?
    var currentUserName = ""
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeading.text = "\(currentUserName)'s Health Records"
        getHealthData()
    }
    
    //MARK: Functions
    func getHealthData(){
        showLoadingView("")
        let endPoint = Constants.URLs.allHealthHistory
        GetAllHealthRecordService().getData(memberID: memberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? AllHealthRecordReponseModel
                {
                    self.arrData = data.arrHealthRecord
                    tblDetail.reloadData()
                    
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

extension AllHealthCheckVC :UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllHealthCheckTCell") as! AllHealthCheckTCell
        cell.lblHeading.text = arrData[indexPath.row].name
        if selectedIndex == indexPath.row{
            cell.vwTags.removeAllTags()
            arrData[indexPath.row].arrData.forEach { (tag) in
                if tag.name.lowercased() == "other" || tag.name.lowercased() == "others"{
                    print(tag)
                    cell.vwTags.addTag(tag.otherValue)
                }else{
                    cell.vwTags.addTag(tag.name)
                }
                
            }
        }else{
            cell.vwTags.removeAllTags()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (selectedIndex == indexPath.row) ? -1 : indexPath.row
        
        tblDetail.reloadData()
    }
    
}

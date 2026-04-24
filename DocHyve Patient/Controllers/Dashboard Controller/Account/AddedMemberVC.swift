//
//  AddMemberVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 12/03/2024.
//

import UIKit

class AddedMemberVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblMembers: UITableView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblMember: UILabel!
    @IBOutlet weak var lblMemberAdded: UILabel!
    @IBOutlet weak var vwNoMembers: UIView!
    @IBOutlet weak var lblAddMembers: UILabel!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var btnAddMembers1: UIButton!
    
    
    
    //MARK: Variable
    
    var arrData = [MemberDetailModel]()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

       // arrData = [1,2,3]
        tblMembers.isHidden = true
        vwHeader.isHidden = true
        getMembers()
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            getMembers()
        }
    }
    //MARK: Functions
    func getMembers(){
        showLoadingView("")
        GetMemberService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MemberReponseModel
                {
                    self.arrData = data.arrMembers
                    tblMembers.reloadData()

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func deleteMember(id:Int){
      
        let param: [String: Any] = [
            "id": id,
        ]
        let endPoint =  Constants.URLs.deleteFamilyMembers
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [self] in
                        if let index = arrData.firstIndex(where: { $0.id == id }) {
                            arrData.remove(at: index)
                            tblMembers.reloadData()
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
    @IBAction func btnAddMemberAction(_ sender: Any) {
        let nextVC = getAddNewMemberVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnAddMember1Action(_ sender: Any) {
        let nextVC = getAddNewMemberVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnDeleteMemberAction(_ sender: UIButton) {
        deleteMember(id: arrData[sender.tag].id)
    }
    @IBAction func btnEditMemberAction(_ sender: UIButton) {
        let nextVC = getAddNewMemberVC()
        nextVC.isForEdit = true
        nextVC.memberData = arrData[sender.tag]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
extension AddedMemberVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasMembers = !arrData.isEmpty

        tblMembers.isHidden = !hasMembers
        vwHeader.isHidden = !hasMembers
        vwNoMembers.isHidden = hasMembers

        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTCell") as! AddMemberTCell
        cell.setData(item: arrData[indexPath.row])
        cell.btnDelete.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        return cell
    }
    
    
}

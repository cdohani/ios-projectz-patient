//
//  DoctorSearchVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 09/12/2025.
//

import UIKit

class SearchConditionVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var txtSearch: AuthTextField!
    @IBOutlet var tblSearch: UITableView!
    
    
    
    //MARK: Variable
    weak var dataDelegate: TransferDataDelegate?
    
    var searchTimer: Timer?
    
    var arrSpecility = [SearchConditionDataModel]()
    var arrProvider = [SearchDoctorDataModel]()
    var query = ""
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        txtSearch.text = query
        callSearchAPI(query: query)
    }
    
    //MARK: Functions
    func callSearchAPI(query:String){
        showLoadingView("")
      
        SearchConditionService().getData(queryText: query, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? SearchConditionResponseModel
                {
                    self.arrSpecility = data.arrCondition
                    self.arrProvider = data.arrDoctor
                    tblSearch.reloadData()
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
    @IBAction func txtSearchDidChange(_ sender: UITextField) {
        searchTimer?.invalidate()  // cancel previous timer
            
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.callSearchAPI(query: self!.txtSearch.text ?? "")
            }
    }
    
}

extension SearchConditionVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrSpecility.count
        }else{
            return arrProvider.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleSearchTCell") as! GoogleSearchTCell
            cell.lblPlacesName.text = arrSpecility[indexPath.row].name
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorSearchTCell") as! DoctorSearchTCell
            cell.setData(item: arrProvider[indexPath.row])
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let nextVC = SearchConditionVC.getDoctorDetailVC()
            nextVC.providerID = arrProvider[indexPath.row].id
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            self.dataDelegate?.sendData(arrSpecility[indexPath.row].name)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
}

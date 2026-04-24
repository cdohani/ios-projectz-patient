//
//  InsuranceVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 11/03/2024.
//

import UIKit

class InsuranceVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblInsurance: UILabel!
    @IBOutlet weak var txtSearch: AuthTextField!
    @IBOutlet weak var tblInsurance: UITableView!
    
    
    
    //MARK: Variable
    var isPrimary = false
    var insuranceType = ""
    var memberID = ""
    var cardImage : UIImage?
    
    var arrInsurance = [InsuranceModel]()
    var groupedInsurances = [String: [InsuranceModel]]()
    var sectionTitles = [String]()
    
    var filteredInsuranceArray: [InsuranceModel] = [] // Filtered data
    var isSearching = false
    
    var selectedInsuranceID = -1
    var searchQuery = ""
    weak var dataDelegate: TransferDataDelegate?
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getInsurance()
        txtSearch.text = searchQuery
        
        txtSearch.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        txtSearch.addDoneButtonOnKeyboard()
        
    }
 
    //MARK: Functions
    
        
    func getInsurance(){
        showLoadingView("")
        InsuraceService().getData(type: insuranceType, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? InsuranceReponseModel
                {
                    self.arrInsurance = data.arrInsurance
                    prepareInsuranceData(from: arrInsurance)
                    filterData(with: txtSearch.text!)

                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func prepareInsuranceData(from array: [InsuranceModel]) {
        let grouped = Dictionary(grouping: array) { insurance in
            return String(insurance.name.prefix(1).uppercased())
        }

        sectionTitles = grouped.keys.sorted()
        
        groupedInsurances = [:]
        for key in sectionTitles {
            groupedInsurances[key] = grouped[key]?.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        }
        tblInsurance.reloadData()
    }

    
    @objc func searchTextChanged(_ textField: UITextField) {
        filterData(with: textField.text ?? "")
    }
    
    func filterData(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            prepareInsuranceData(from: arrInsurance)
        } else {
            isSearching = true
            filteredInsuranceArray = arrInsurance.filter { insurance in
                insurance.name.range(of: searchText, options: .caseInsensitive) != nil
            }
            prepareInsuranceData(from: filteredInsuranceArray)
        }
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension InsuranceVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
         return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionTitles[section]
        return groupedInsurances[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTCell") as! AccountHeaderTCell
        cell.lblHeader.text = sectionTitles[section]
        return  cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsuranceTCell") as! InsuranceTCell
        let key = sectionTitles[indexPath.section]
        if let models = groupedInsurances[key] {
            let insurance = models[indexPath.row]
            cell.lblName.text = insurance.name
           
            cell.imgSelection.image = insurance.id == selectedInsuranceID ? UIImage(systemName: "checkmark") : nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isUserLoggedIn(){
            let key = sectionTitles[indexPath.section]
            if let models = groupedInsurances[key] {
                let insurance = models[indexPath.row]
                
                let nextVC = getInsurancePlanVC()
                nextVC.selectedInsurance = insurance
                nextVC.isPrimary = isPrimary
                nextVC.insuranceType = insuranceType
                nextVC.memberID = memberID
                nextVC.cardImage = self.cardImage
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }else{
            let key = sectionTitles[indexPath.section]
            if let models = groupedInsurances[key] {
                let insurance = models[indexPath.row]
                dataDelegate?.sendData(insurance)
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
      
    }
}

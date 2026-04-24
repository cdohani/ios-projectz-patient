//
//  PopularSpecialitiesVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 31/10/2025.
//

import UIKit

class PopularSpecialitiesVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var txtSearch: AuthTextField!
   
    @IBOutlet var lblPopularSpecialities: UILabel!
    @IBOutlet var cvPopularSpecialities: UICollectionView!
    @IBOutlet var lblOtherSpecialities: UILabel!
    @IBOutlet var tblSpecialities: UITableView!
    @IBOutlet var imgNoData: UIImageView!
    
    
    
    
    //MARK: Variable
    var arrSpeciality = [SpecialityResponseModel]()
    var arrPopular = [SpecialityResponseModel]()
    var arrOtherSpeciality = [SpecialityResponseModel]()
    
    var groupedSpecialities = [String: [SpecialityResponseModel]]()
    var sectionTitles = [String]()
    
    var filteredSpecialityArray: [SpecialityResponseModel] = []
    var arrFilterPopular = [SpecialityResponseModel]()// Filtered data
    var isSearching = false
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imgNoData.isHidden = true
        if let layout = cvPopularSpecialities.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
         arrPopular = arrSpeciality.filter { $0.isPopular == 1 }
         cvPopularSpecialities.reloadData()
         arrOtherSpeciality = arrSpeciality.filter { $0.isPopular != 1 }
        prepareInsuranceData(from: arrOtherSpeciality)
        txtSearch.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
    }
    
    //MARK: Functions
    @objc func searchTextChanged(_ textField: UITextField) {
        filterData(with: textField.text ?? "")
    }
    
    func filterData(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            prepareInsuranceData(from: arrOtherSpeciality)
        } else {
            isSearching = true
            filteredSpecialityArray = arrOtherSpeciality.filter { insurance in
                insurance.name.range(of: searchText, options: .caseInsensitive) != nil
            }
            prepareInsuranceData(from: filteredSpecialityArray)
        
        }
    }
    func prepareInsuranceData(from array: [SpecialityResponseModel]) {
        let grouped = Dictionary(grouping: array) { insurance in
            return String(insurance.name.prefix(1).uppercased())
        }

        sectionTitles = grouped.keys.sorted()
        
        groupedSpecialities = [:]
        for key in sectionTitles {
            groupedSpecialities[key] = grouped[key]?.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        }
        tblSpecialities.reloadData()
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PopularSpecialitiesVC :UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPopular.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvialableSlotCCell", for: indexPath) as! AvialableSlotCCell
        cell.lblTime.text = arrPopular[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = getFindDoctorVC()
        nextVC.searchQuery = arrPopular[indexPath.row].name
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
  
}
extension PopularSpecialitiesVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//            let collectionViewWidth = collectionView.bounds.width
//            return CGSize(width: collectionViewWidth/4.3, height:40)
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension PopularSpecialitiesVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
         return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionTitles[section]
        return groupedSpecialities[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTCell") as! AccountHeaderTCell
        cell.lblHeader.text = sectionTitles[section]
        return  cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsuranceTCell") as! InsuranceTCell
        let key = sectionTitles[indexPath.section]
        if let models = groupedSpecialities[key] {
            let insurance = models[indexPath.row]
            cell.lblName.text = insurance.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sectionTitles[indexPath.section]
        if let models = groupedSpecialities[key] {
            let insurance = models[indexPath.row]
            let nextVC = getFindDoctorVC()
            nextVC.searchQuery = insurance.name
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
        
    }
}

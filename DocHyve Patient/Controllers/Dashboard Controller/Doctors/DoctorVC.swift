//
//  DoctorVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 28/02/2024.
//

import UIKit

class DoctorVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblBookAppt: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnFindDoctor: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var vwData: UIView!
    @IBOutlet weak var vwSegment: UISegmentedControl!
    @IBOutlet weak var tblDoctors: UITableView!
    @IBOutlet var imgNoData: UIImageView!
    
    
    
    //MARK: Variable
    var isSavedDoc  = false
    var arrFavourite = [FavouriteProviderModel]()
    var arrBookedDoc = [FavouriteProviderModel]()
    var isShowLoading = true
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customization()
    }
    
    //MARK: Functions
    func customization(){
        vwSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        if isUserLoggedIn(){
            vwContainer.isHidden = true
            vwData.isHidden = false
            getBookedDoc()
        }else{
            vwContainer.isHidden = false
            vwData.isHidden = true
        }
        
        tblDoctors.addPullToRefresh(target: self, action: #selector(refreshData))

    }
    @objc func refreshData() {
        isShowLoading = false
        getBookedDoc()
    }
    
    func getFavouritDoc(){
        if isShowLoading{
            showLoadingView("")
        }
        GetFavouriteProviderService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                tblDoctors.stopRefreshing()
                if let data = response as? FavouriteProviderReponseModel
                {
                    self.arrFavourite = data.arrFavouriteProvider
                    tblDoctors.reloadData()
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.tblDoctors.stopRefreshing()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getBookedDoc(){
        if isShowLoading{
            showLoadingView("")
        }
        GetBookedProviderService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? FavouriteProviderReponseModel
                {
                    self.arrBookedDoc = data.arrFavouriteProvider
                    tblDoctors.reloadData()
                    getFavouritDoc()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func removeFavourite(providerID:Int){
      
        let param: [String: Any] = [
            "provider_id": providerID,
            "is_favorite" : false
        ]
        
       let  endPoint =  Constants.URLs.favouritUpdate
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    if let index = arrFavourite.firstIndex(where: { $0.providerID == providerID }) {
                        arrFavourite.remove(at: index)
                        tblDoctors.reloadData()
                    }
                    self.showToast(message: data.message, controller: self)
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
    @IBAction func btnFindDoctorAction(_ sender: Any) {
//        if let parent = self.parent as? DashboardVC {
//            parent.selectTab(index: 0)
//        }
        
        let nextVC = getFindDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnSegmentAction(_ sender: UISegmentedControl) {
        isSavedDoc = sender.selectedSegmentIndex == 0 ? false : true
        tblDoctors.reloadData()
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        
        let doctorId = arrFavourite[sender.tag].providerID
        let url = URL(string: "https://dochyve.com/en/patient/doctordetails/\(doctorId)")!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    @IBAction func btnFavouriteAction(_ sender: UIButton) {
        removeFavourite(providerID: arrFavourite[sender.tag].providerID)
    }
    
    @IBAction func btnShare2Action(_ sender: UIButton) {
        let doctorId = arrBookedDoc[sender.tag].providerID
        let url = URL(string: "https://dochyve.com/en/patient/doctordetails/\(doctorId)")!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    @IBAction func btnNextAction(_ sender: UIButton) {
    }
}
extension DoctorVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSavedDoc{
            imgNoData.isHidden = !arrFavourite.isEmpty
            return  arrFavourite.count
        }else{
            imgNoData.isHidden = !arrBookedDoc.isEmpty
            return arrBookedDoc.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSavedDoc {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedDoctorTCell") as! SavedDoctorTCell
            cell.setData(item: arrFavourite[indexPath.row])
            cell.btnFavourit.tag = indexPath.row
            cell.btnShare.tag = indexPath.row
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookedDoctorTCell") as! BookedDoctorTCell
            cell.setData(item: arrBookedDoc[indexPath.row])
            cell.btnShare.tag = indexPath.row
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSavedDoc{
            let nextVC = DoctorVC.getDoctorDetailVC()
            nextVC.providerID = arrFavourite[indexPath.row].providerID
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            let nextVC = getPastAppoinmentStatusVC()
            nextVC.selectedProviderID = arrBookedDoc[indexPath.row].providerID
            nextVC.docInfo = arrBookedDoc[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

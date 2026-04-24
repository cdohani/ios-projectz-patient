//
//  NotificationVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 28/02/2024.
//

import UIKit

class NotificationVC: ParentViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnFindDoctor: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var vwNotification: UIView!
    @IBOutlet weak var lblAllNotification: UILabel!
    @IBOutlet weak var lblNotiCount: UILabel!
    @IBOutlet weak var btnMarkRead: UIButton!
    @IBOutlet var imgNoData: UIImageView!
    
    
    
    //MARK: Variable
    var arrNotification = [NotificationModel]()
    var paginationInfo = PaginationInfoModel()
    var isLoadingMore = false
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getNotificationList()
        vwContainer.isHidden = true
    }
    
    //MARK: Functions
    func getNotificationList(){
        if !isLoadingMore{
            showLoadingView("")
        }
        GetNotificationService().getData(currentPage:paginationInfo.currentPage + 1,pageLimit: 30,completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? NotificationResponseModel
                {
                    
                    self.arrNotification.append(contentsOf: data.arrNotification)
                    self.paginationInfo = data.paginationInfo
                    tblNotification.reloadData()
                    let unreadNoti = self.arrNotification.filter({$0.isread == false}).count
                    lblNotiCount.text = "You have \(unreadNoti) unread notifications Today."
                    isLoadingMore = false
                    tblNotification.hideLoadingIndicator()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func markNotificationRead(isreadAll:Bool,notiId:Int = 0){
        let param: [String: Any] = [:]
        var endPoint =  ""
        if isreadAll{
            endPoint =  Constants.URLs.markAllReadNotification
        }else{
            endPoint =  String(format: Constants.URLs.markReadSingleNotification, notiId)
        }
        
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if success is GeneralResponseModel
                {
                        paginationInfo.currentPage = 0
                        arrNotification.removeAll()
                        self.getNotificationList()
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    func deleteNotification(notiId:Int){
        let param: [String: Any] = [:]
        let endPoint =  String(format: Constants.URLs.deleteNotification, notiId)
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    showAlertViewWithCompletion(message: data.message) { [weak self] in
                        self?.paginationInfo.currentPage = 0
                        self?.arrNotification.removeAll()
                        self?.getNotificationList()
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
    
    @IBAction func btnFindDoctorAction(_ sender: Any) {
        
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = NotificationVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnMarkReadAction(_ sender: Any) {
        markNotificationRead(isreadAll: true)
    }
    
    @IBAction func btnDeleteNotificationAction(_ sender: UIButton) {
        deleteNotification(notiId: arrNotification[sender.tag].id )
    }
}
extension NotificationVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrNotification.isEmpty{
            tblNotification.isHidden = true
            vwNotification.isHidden = true
            imgNoData.isHidden = false
        }else{
            tblNotification.isHidden = false
            vwNotification.isHidden = false
            imgNoData.isHidden = true
        }
        return arrNotification.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTCell") as! NotificationTCell
        cell.setNotificationData(data: arrNotification[indexPath.row])
        cell.btnDeleteNotification.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        markNotificationRead(isreadAll: false, notiId: arrNotification[indexPath.row].id)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == arrNotification.count - 1 {
            if paginationInfo.hasMoreRecord{
                isLoadingMore = true
                tblNotification.showLoadingIndicator()
                getNotificationList()
            }
           
            // Add a checkmark or apply any styling
        }
    }
}

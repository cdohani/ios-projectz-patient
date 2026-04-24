//
//  AppoinmentVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 28/02/2024.
//

import UIKit
import FSCalendar
import Fastis
class AppoinmentVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblBookyourFirstAppoinment: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnFindDoctor: UIButton!
    @IBOutlet weak var tblAppt: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var imgNoRecord: UIImageView!
    @IBOutlet var vwFilter: UIView!
    @IBOutlet var txtRangeDate: AuthTextField!
    @IBOutlet var txtAppointmentType: AuthTextField!

    
    
    
    //MARK: Variable
    var arrIndex = [Int]()
    var paginationInfo = PaginationInfoModel()
    var isLoadingMore = false
    
    var arrAppointment = [UserAppointmentDetail]()
    var isUpcomingAppointment = false
    var isPastAppointment = false
    
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var fromDate = ""
    var toDate = ""
    
    var arrStatus = [String]()
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    
    private var currentRequestID = UUID()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        arrStatus = AppointmentStatus.allCases.map { $0.rawValue.capitalized }
        customization()
        setupPickerView()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if DataManager.shared.isDataUpdated{
            DataManager.shared.isDataUpdated = false
            customization()
        }
    }
    //MARK: Functions
    func customization(){
        arrIndex.append(1)
        segmentControll.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        if isUserLoggedIn(){
            vwContainer.isHidden = true
            segmentControll.isHidden = false
            vwFilter.isHidden = false
            tblAppt.isHidden = false
            
            segmentControll.selectedSegmentIndex = 0
            isUpcomingAppointment = false
            isPastAppointment = false
            paginationInfo.currentPage = 0
            fromDate = ""
            toDate = ""
            txtAppointmentType.text = ""
            txtRangeDate.text = ""
            arrAppointment.removeAll()
            getAppointment(requestID: currentRequestID)
        }else{
            imgNoRecord.isHidden = true
            vwContainer.isHidden = false
            segmentControll.isHidden = true
            tblAppt.isHidden = true
            vwFilter.isHidden = true

        }
    }
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        txtAppointmentType.delegate = self
        txtAppointmentType.inputView = pickerView
        txtAppointmentType.inputAccessoryView = toolbar
        // Toolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    @objc func doneTapped() {
         let row = pickerView.selectedRow(inComponent: 0)
        txtAppointmentType.text = arrStatus[row]
        txtAppointmentType.resignFirstResponder()
        paginationInfo.currentPage = 0
        fromDate = ""
        toDate = ""
        isLoadingMore = false
        arrAppointment.removeAll()
        getAppointment(requestID: currentRequestID)
     }
     
     @objc func cancelTapped() {
         txtAppointmentType.resignFirstResponder()
     }
    func chooseDate() {
        
        let fastisController = FastisController(mode: .range)
        fastisController.title = "Choose range"
        
        fastisController.initialValue = FastisRange(from: selectedStartDate ?? Date(), to: selectedEndDate ?? Date())
        fastisController.allowToChooseNilDate = true
        
        fastisController.dismissHandler = { [self]  action in
            switch action {
            case .done(let resultRange):
                selectedStartDate = resultRange?.fromDate
                selectedEndDate = resultRange?.toDate
                fromDate = selectedStartDate?.dateString(format: "yyyy-MM-dd") ?? ""
                toDate = selectedEndDate?.dateString(format: "yyyy-MM-dd") ?? ""
                let tempFromDate = selectedStartDate?.dateString(format: "MMM-dd") ?? ""
                let tempToDate = selectedEndDate?.dateString(format: "MMM-dd") ?? ""
                txtRangeDate.text = "\(tempFromDate)    -    \(tempToDate)"
                paginationInfo.currentPage = 0
                arrAppointment.removeAll()
                getAppointment(requestID: currentRequestID) // resultRange is FastisRange
            case .cancel:
                print("cancel")
            }
        }

            fastisController.present(above: self)
        
    }
    
    func getAppointment(requestID: UUID){
        showLoadingView("")
        var param: [String: Any] = [
            "upcoming" : isUpcomingAppointment,
            "past" : isPastAppointment,
            "per_page" : 50,
            "page": paginationInfo.currentPage + 1
        ]
        if fromDate != "" {
            param["start_date"] = fromDate
        }
        if toDate != "" {
            param["end_date"] = toDate
        }
        if txtAppointmentType.text != ""{
            param["status"] = txtAppointmentType.text?.lowercased()
        }
        if !isLoadingMore{
            showLoadingView("")
        }
        GetUserAppointmentService().getData(parameters: param, completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // 🔴 Ignore stale responses
                guard requestID == self.currentRequestID else { return }

                self.removeLoadingView()
                
                if let data = response as? UserAppointmentReponseModel {
                    self.arrAppointment.append(contentsOf: data.arrAppointment)
                    self.paginationInfo = data.paginationInfo
                    self.tblAppt.reloadData()
                    self.tblAppt.hideLoadingIndicator()
                }
            }
        }, failure: { (failure) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // 🔴 Ignore stale error from old request
                guard requestID == self.currentRequestID else { return }
                
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        })

    }

    func showButtons(
        apptDate: String,
        apptTime: String,
        dateStatus: String,
        apptStatus: String
    ) -> Bool {

        // Appointment must not be cancelled
        if apptStatus.lowercased() == "cancelled" {
            return true
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current

        // Combine date + time
        let dateTimeString = "\(apptDate) \(apptTime)"

        guard let appointmentDate = formatter.date(from: dateTimeString) else {
            return false
        }

        let now = Date()

        switch dateStatus.lowercased() {
        case "past":
            return true

        case "future":
            return false

        case "today":
            // Allow only if appointment time is still in future
            return appointmentDate < now

        default:
            return true
        }
    }


    
    //MARK: ButtonActions
    
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = AppoinmentVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        currentRequestID = UUID()   // 🔴 invalidate previous requests
           
           isUpcomingAppointment = sender.selectedSegmentIndex == 1
           isPastAppointment = sender.selectedSegmentIndex == 2
           
           paginationInfo.currentPage = 0
           fromDate = ""
           toDate = ""
           txtAppointmentType.text = ""
           txtRangeDate.text = ""
           
           arrAppointment.removeAll()
           tblAppt.reloadData()
           
           isLoadingMore = false
           
           getAppointment(requestID: currentRequestID)
    }
    
    @IBAction func btnFindDoctorAction(_ sender: Any) {
//        if let parent = self.parent as? DashboardVC {
//            parent.selectTab(index: 0)
//        }
        
        let nextVC = getFindDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnDetailAction(_ sender: UIButton) {
        if arrIndex.contains(sender.tag){
            let idx = arrIndex.firstIndex(of:  sender.tag)
            arrIndex.remove(at: idx!)
        }else{
            arrIndex.append(sender.tag)
        }
        tblAppt.reloadData()
    }
    @IBAction func btnUploadCardAction(_ sender: UIButton) {
    }
    @IBAction func btnSelectRangeAction(_ sender: Any) {
        chooseDate()
    }
    @IBAction func btnSelectTypeAction(_ sender: Any) {
        txtAppointmentType.becomeFirstResponder()
    }
    @IBAction func btnPendingReviewAction(_ sender: UIButton) {
        let nextVC = getReviewDoctorVC()
        nextVC.providerInfo = arrAppointment[sender.tag].providerInfo
        nextVC.appointmentID = arrAppointment[sender.tag].appointmentID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
extension AppoinmentVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isUserLoggedIn(){
            imgNoRecord.isHidden = !arrAppointment.isEmpty
        }
        return  arrAppointment.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookedApptTCell") as! BookedApptTCell
        cell.setCell(item: arrAppointment[indexPath.row])
        cell.btnDetail.tag = indexPath.row
        cell.btnPendingReview.tag = indexPath.row

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       

        let hideInfo = showButtons(
            apptDate: arrAppointment[indexPath.row].date,
            apptTime: arrAppointment[indexPath.row].time,
            dateStatus: arrAppointment[indexPath.row].dateStatus,
            apptStatus: arrAppointment[indexPath.row].status
        )

        if arrAppointment[indexPath.row].bookingType == "in-person" {
            let nextVC = AppoinmentVC.getApptDoctorDetailVC()
            nextVC.appointmentID = arrAppointment[indexPath.row].appointmentID
            nextVC.hideButtons = hideInfo
            nextVC.appointmentStatus = arrAppointment[indexPath.row].status
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            let nextVC = AppoinmentVC.getVideoApptDetailVC()
            nextVC.appointmentID = arrAppointment[indexPath.row].appointmentID
            nextVC.hideButtons = hideInfo   // pass value
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == tblAppt{
            if indexPath.row == arrAppointment.count - 1 {
                if paginationInfo.hasMoreRecord{
                    isLoadingMore = true
                    tblAppt.showLoadingIndicator()
                    getAppointment(requestID: currentRequestID)
                }
            }
        }
    }
}


extension AppoinmentVC: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UIPickerViewDataSource
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return arrStatus.count
     }

     // MARK: - UIPickerViewDelegate
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return  arrStatus[row]
     }
}
extension AppoinmentVC : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAppointmentType{
            return false
        }
        return true
    }
}

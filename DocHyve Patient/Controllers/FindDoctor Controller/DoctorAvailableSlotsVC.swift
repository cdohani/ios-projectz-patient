//
//  DoctorAvailableSlots.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 11/03/2024.
//

import UIKit
import FSCalendar

class DoctorAvailableSlotsVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var vwScrollView: UIScrollView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblDocSpeciality: UILabel!
    @IBOutlet weak var lblSelectOffice: UILabel!
    @IBOutlet weak var vwOfficeLocations: UIView!
    @IBOutlet weak var lblOfficeAddress: UILabel!
    @IBOutlet weak var lblTotalOffice: UILabel!
    @IBOutlet weak var vwCalender: FSCalendar!
    @IBOutlet weak var vwCalenderHeight: NSLayoutConstraint!
    @IBOutlet weak var cvSlots: UICollectionView!
    @IBOutlet var lblNoRecordFound: UILabel!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwLocation: UIView!
    @IBOutlet var txtSearchLocation: UISearchBar!
    @IBOutlet var tblLocation: UITableView!
    @IBOutlet var vwBookAppointment: UIView!
    @IBOutlet var lblBookApptHeading: UILabel!
    @IBOutlet var lblBookApptDesc: UILabel!
    @IBOutlet var btnBookAppointment: UIButton!
    
    @IBOutlet var vwChangeAppt: UIView!
    @IBOutlet var imgProvider: UIImageView!
    @IBOutlet var lblProviderName: UILabel!
    @IBOutlet var lblProviderRole: UILabel!
    @IBOutlet var lblProviderSpeciality: UILabel!
    @IBOutlet var lblOldDate: UILabel!
    @IBOutlet var lblNewDate: UILabel!
    @IBOutlet var lblillness: UILabel!
    @IBOutlet var iconApptType: UIImageView!
    @IBOutlet var lblApptType: UILabel!
    @IBOutlet var lblOfficeLocationHeading: UILabel!
    @IBOutlet var lblOfficeAddressInfo: UILabel!
    @IBOutlet var lblApptDesc: UILabel!
    @IBOutlet var btnChangeAppt: UIButton!
    
    
    
    
    
    //MARK: Variable
    var arrProvider = [SearchDoctorModel]()
    var currentIndex = -1
    var arrAvailableSlot = [Slots]()
    
    var paginationInfo = PaginationInfoModel()
    var isLoadingMore = false
    
    var providerID = -1
    var currentDate = Date()
    
    var arrLocations =  [LocationDataModel]()
    var selectedLocationID = -1
    var selectedStateID = -1
    var selectedSlotID = -1
    var fullAddress = ""
    
    var availableDates = Set<Date>()
    
    var isForEditAppointment = false
    var isForFollowUp = false
    var appointmentData = SingleAppointmentDetail()
    var sendDateParam = false
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        vwScrollView.isHidden = true
        customization()
        searchDoctor()
        getLocations()
    }
    
    //MARK: Functions
    func customization(){
        vwCalender.scope = .week
        vwCalender.delegate = self
        vwCalender.dataSource = self
        vwCalenderHeight.constant = 350
        let highlightedDate = currentDate // Replace with your desired date
        vwCalender.select(highlightedDate)
        vwCalender.appearance.todayColor = nil
        vwCalender.appearance.titleTodayColor = vwCalender.appearance.titleDefaultColor
        
        lblNoRecordFound.isHidden = true
        
        self.vwOverlay.alpha = 0
        self.vwLocation.alpha = 0
        self.vwChangeAppt.alpha = 0
        vwBookAppointment.alpha = 0
        
        btnChangeAppt.setTitle(isForFollowUp ? "Book Follow up" : "Change Appointment", for: .normal)
    }
    func getLocations(){
        showLoadingView("")
        GetProviderLocationService().getData(providerID: providerID, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? LocationResponseModel
                {
                    self.arrLocations = data.arrLocations
                    tblLocation.reloadData()


//                    if let index = arrLocations.firstIndex(where: { $0.isDefault == 1 }) {
//                      selectedLocationID = arrLocations[index].id
//                        selectedStateID = arrLocations[index].stateID
//                        
//                        fullAddress = formattedAddress(from:arrLocations[index] )
//                        
//                    }
                    
                    lblTotalOffice.text = arrLocations.count > 1 ? "\(arrLocations.count - 1) More Location" : ""
                    
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func searchDoctor(){
     
        
        var param: [String: Any] = [
            "provider_id" : providerID,
        ]
        if sendDateParam{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: currentDate)
            
            param["date"] = formattedDate
        }
        if selectedLocationID != -1{
           
            param["address_id"] = selectedLocationID
        }
        
        if !isLoadingMore{
            showLoadingView("")
        }
        SearchDoctorService().searchData(parameters:param,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? SearchDoctorReponseModel
                {
                    if  data.response.status != 200 && data.response.status != 201{
                        self.showAlertView(message: data.response.message)
                    }
                    else{
                        arrProvider =  data.arrProvider
                        self.paginationInfo = data.paginationInfo
                        cvSlots.reloadData()
                        if !arrProvider.isEmpty{
                            setScreenData()
                            setAvailableDates(arrProvider[0].nextAvailableDates)
                            lblNoRecordFound.isHidden = true
                            cvSlots.isHidden = false
                            let highlightedDate = arrProvider[0].availableSlots.date.convertStringToDate(withFormat: "yyyy-MM-dd")
                            vwCalender.select(highlightedDate)
                            vwScrollView.isHidden = false
                            vwCalender.reloadData()
                        }else{
                            lblNoRecordFound.isHidden = false
                            cvSlots.isHidden = true
                            vwCalender.select(currentDate)
                          
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
    
    func setScreenData(){
        let item = arrProvider[0]
        let imageURL = Constants.URLs.imagePath + item.providerImage
        imgUser.loadImage(from: imageURL)
        lblDocName.text = item.firstName + " " + item.lastName
        lblDocSpeciality.text = item.specialities
        fullAddress = formattedAddress(from:item.slotAddress)
        lblOfficeAddress.text = fullAddress
        
        setChangeApptData()
    }
    func setChangeApptData(){
        let imageURL = Constants.URLs.imagePath + appointmentData.providerInfo.providerImage
        imgProvider.loadImage(from: imageURL)
        lblProviderName.text = "\(appointmentData.providerInfo.firstName)\(appointmentData.providerInfo.lastName)"
        
        lblProviderRole.text = appointmentData.providerInfo.specialization
        
        lblOldDate.attributedText = appointmentData.appointmentInfo.formattedDateTime.strikeThrough()
//        lblOldDate.isHidden = !isForEditAppointment
        lblillness.text = appointmentData.illnessInfo.name
        lblApptType.text = appointmentData.appointmentInfo.bookingType
       
    }
    func setAvailableDates(_ dates: [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        availableDates.removeAll()
        
        for string in dates {
            if let date = formatter.date(from: string) {
                availableDates.insert(date)
            }
        }

        vwCalender.reloadData()
    }
    
    func updateSlot(addOutNetwork:Bool){
        var param: [String: Any] = [
            "slot_id": selectedSlotID
        ]
        var endPoint = ""
        if isForEditAppointment{
             endPoint =   String(format: Constants.URLs.updateAppointmentSlot, appointmentData.appointmentID)
           
        }else{
            endPoint = Constants.URLs.bookfollowUp
            param["old_appointment_id"] = appointmentData.appointmentID
            if addOutNetwork {
                param["can_add_out_of_network"] = true
            }
        }
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }

            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if ((faliure?.contains("out-of-network")) != nil){
                    self.showAlertViewWithContine(message: faliure ?? "") {
                        self.updateSlot(addOutNetwork: true)
                    }
                }else{
                    self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
                }
                
            }
        }
        
    }
    
    func combineDateTime(from date: Date, with slot24: String) -> String {
        let calendar = Calendar.current

        // 1. Break selected date into components
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        // 2. Parse the 24h slot time ("15:30")
        let timeParts = slot24.split(separator: ":")
        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else { return "" }

        // 3. Build the final Date using LOCAL timezone
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = hour
        combined.minute = minute
        combined.timeZone = TimeZone.current

        guard let combinedDate = calendar.date(from: combined) else { return "" }

        // 4. Custom formatting
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US")
        outputFormatter.dateFormat = "E, dd MMM"   // Prefix part only
        let datePrefix = outputFormatter.string(from: combinedDate)

        // Handle time formatting manually (dot instead of colon)
        let hour12 = calendar.component(.hour, from: combinedDate) % 12
        let hourToShow = hour12 == 0 ? 12 : hour12
        let minuteToShow = String(format: "%02d", minute)

        let isPM = hour >= 12
        let ampm = isPM ? "pm" : "am"

        // FORMAT RULES:
        // - morning keep leading zero → 09:00 am
        // - afternoon remove leading zero → 3.30 pm
        let hourString =
            (!isPM && hourToShow < 10) ? String(format: "%02d", hourToShow) : "\(hourToShow)"

        let timeString = "\(hourString).\(minuteToShow) \(ampm)"

        return "\(datePrefix) \(timeString)"
    }

    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSelectOffice(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.vwOverlay.alpha = 0.3
            self.vwLocation.alpha = 1
            
        })
    }
    @IBAction func btnCloseLocationAction(_ sender: Any) {
        UIView.transition(with: view, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                self.vwOverlay.alpha =  0
                self.vwLocation.alpha = 0
        })
        currentDate = Date()
        sendDateParam = false
        searchDoctor()
        setAvailableDates([])
    }
    @IBAction func btnCloseAppoinmentAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwBookAppointment.alpha = 0
    }
    @IBAction func btnBookAppointmentAction(_ sender: Any) {
        
        vwOverlay.alpha = 0
        vwBookAppointment.alpha = 0
        let nextVC = getBookApptVC()
        nextVC.selectedProviderID = arrProvider[0].userId
        nextVC.selectedSlotID = self.selectedSlotID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnCloseChangeApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwChangeAppt.alpha = 0
    }
    
    @IBAction func btnChangeApptAction(_ sender: Any) {
        updateSlot(addOutNetwork: false)
    }
    
}
extension DoctorAvailableSlotsVC : FSCalendarDelegate,FSCalendarDataSource, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.vwCalenderHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  // IMPORTANT
        
        let dateString = formatter.string(from: date)
    
        currentDate = dateString.convertIntoDateUsingFormat(format: "yyyy-MM-dd") ?? Date()
        sendDateParam = true
        searchDoctor()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return availableDates.contains(date) ? 1 : 0
    }
    // 🔴 Change event dot color here
    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        if availableDates.contains(date) {
            return [UIColor(named: "customYellowColor") ?? .systemYellow]
        }
        
        return nil
    }
}


extension DoctorAvailableSlotsVC :UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !arrProvider.isEmpty{
            return arrProvider[0].availableSlots.slots.count
        }else{
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvialableSlotCCell", for: indexPath) as! AvialableSlotCCell
        if !arrProvider.isEmpty{
            cell.lblTime.text = arrProvider[0].availableSlots.slots[indexPath.row].time
            cell.lblTime.textColor = arrProvider[0].availableSlots.slots[indexPath.row].isBooked  ? UIColor(named: "customGreyColor") : UIColor.white
            cell.vwBackground.backgroundColor = arrProvider[0].availableSlots.slots[indexPath.row].isBooked ? UIColor(named: "customNavbarColor") : UIColor(named: "customGold")
        }
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isUserLoggedIn(){
            if !arrProvider[0].availableSlots.slots[indexPath.row].isBooked{
                if isForEditAppointment{
                    let slotTime = arrProvider[0].availableSlots.slots[indexPath.row].time
                    selectedSlotID = arrProvider[0].availableSlots.slots[indexPath.row].id
                    lblNewDate.text = combineDateTime(from: currentDate, with: slotTime)
                    lblOfficeAddressInfo.text = fullAddress
                    vwOverlay.alpha = 0.3
                    vwChangeAppt.alpha = 1
                }else if isForFollowUp{
                    let slotTime = arrProvider[0].availableSlots.slots[indexPath.row].time
                    selectedSlotID = arrProvider[0].availableSlots.slots[indexPath.row].id
                    lblNewDate.text = combineDateTime(from: currentDate, with: slotTime)
                    lblOfficeAddressInfo.text = fullAddress
                    vwOverlay.alpha = 0.3
                    vwChangeAppt.alpha = 1
                }
                else{
                    selectedSlotID = arrProvider[0].availableSlots.slots[indexPath.row].id
                    vwOverlay.alpha = 0.3
                    vwBookAppointment.alpha = 1
                }
             
            }
        }else{
            showAlertView(message: "Please Login or Register to Book Your Appointment.")
        }

       
    }
  
}
extension DoctorAvailableSlotsVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionViewWidth = collectionView.bounds.width
            return CGSize(width: collectionViewWidth/4.3, height:40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension DoctorAvailableSlotsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSpecialityTCell") as! SelectSpecialityTCell
            cell.lblTitle.text = formattedAddress(from: arrLocations[indexPath.row])
            if selectedLocationID == arrLocations[indexPath.row].id{
                cell.imgSelected.image = UIImage(systemName: "checkmark")
            }else{
                cell.imgSelected.image = nil
            }
            return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocationID = arrLocations[indexPath.row].id
        selectedStateID = arrLocations[indexPath.row].stateID
        fullAddress = formattedAddress(from: arrLocations[indexPath.row])
        lblOfficeAddress.text = fullAddress
        tblLocation.reloadData()
        
    }
    
    
}

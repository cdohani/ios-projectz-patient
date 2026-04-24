//
//  ApptDoctorDetailVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/04/2024.
//

import UIKit
import EventKit
import GoogleMaps
import MapKit
class ApptDoctorDetailVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet var vwScrollView: UIScrollView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgDoc: UIImageView!
    @IBOutlet weak var lblApptDesc: UILabel!
    @IBOutlet weak var lblMedicalType: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblIllness: UILabel!
    @IBOutlet weak var lblCallOffice: UILabel!
    @IBOutlet weak var lblAddToCalender: UILabel!
    @IBOutlet weak var lblGetDirection: UILabel!
    @IBOutlet weak var lblModifyAppt: UILabel!
    @IBOutlet weak var lblApptPrepare: UILabel!
    @IBOutlet weak var vwInsuranceAdded: UIView!
    @IBOutlet var lblInsuranceSendToProvider: UILabel!
    @IBOutlet var lblInsuranceDetail: UILabel!
    @IBOutlet weak var lblGuidelines: UILabel!
    @IBOutlet weak var tblGuidelines: UITableView!
    @IBOutlet weak var lblOfficeLocation: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnShowAddress: UIButton!
    @IBOutlet var vwMap: GMSMapView!
    @IBOutlet weak var lblWhatAfterAppt: UILabel!
    @IBOutlet weak var btnLearnHowBillingWork: UIButton!
    @IBOutlet weak var btnBookFollowup: UIButton!
    @IBOutlet var tblGuideHeight: NSLayoutConstraint!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwModifyAppointment: UIView!
    @IBOutlet var btnModifyAppointment: UIButton!
    @IBOutlet var btnCancelAppt: UIButton!
    @IBOutlet var btnKeepAppt: UIButton!
    @IBOutlet var vwButtonStack: UIStackView!
    @IBOutlet var btnDoctorOffice: UIButton!
    @IBOutlet var vwContainerHeight: NSLayoutConstraint!
    
    
    
    
    //MARK: Variable
    var appointmentID = -1
    var hideButtons = false
    var appointmentStatus = ""
    var appointmentData = SingleAppointmentDetail()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        vwScrollView.isHidden = true
        getApptData()
        customization()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
        vwModifyAppointment.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }

    
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwModifyAppointment.alpha = 0
    }
  
    func updateTableViewHeight() {
        tblGuidelines.layoutIfNeeded() // Ensure the contentSize is up to date
        tblGuideHeight.constant = tblGuidelines.contentSize.height
    }
    func getApptData(){
        showLoadingView("")
        let endPoint =  String(format: Constants.URLs.singleAppointmentDetail, appointmentID)
        SingleAppointmentDetailService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? SingleAppointmentResponseModel
                {
                    self.appointmentData = data.appointmentData
                    setScreenData()
                    vwScrollView.isHidden = false
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func setScreenData(){
        if appointmentData.providerInfo.providerImage != ""{
            let imageURL = Constants.URLs.imagePath + appointmentData.providerInfo.providerImage
            imgDoc.loadImage(from: imageURL)
        }
       
        lblApptDesc.text = "Your upcoming visit with Dr. \(appointmentData.providerInfo.firstName) \(appointmentData.providerInfo.lastName)"
        lblMedicalType.text = appointmentData.providerInfo.specialization
        lblDate.text = appointmentData.appointmentInfo.formattedDateTime
        lblIllness.text = appointmentData.illnessInfo.name
        lblAddress.text = formattedAddress(from:appointmentData.slotInfo.slotAddress )
        if appointmentData.preparationGuideline.insuranceSendToProvider{
            vwInsuranceAdded.isHidden = false
            lblInsuranceDetail.text = appointmentData.preparationGuideline.networkStatus
        }else {
            vwInsuranceAdded.isHidden = true
        }
        tblGuidelines.reloadData()
        tblGuidelines.layoutIfNeeded()
        updateTableViewHeight()
        
        let lat = Double(appointmentData.slotInfo.slotAddress.lat) ?? 0.0
        let long = Double(appointmentData.slotInfo.slotAddress.long) ?? 0.0
        addMapPin(lat: lat, long: long)
        
        if hideButtons{
            vwContainerHeight.constant = 140
            vwButtonStack.alpha = 0
            btnDoctorOffice.alpha = 0
        }else{
            vwButtonStack.alpha = 1
            btnDoctorOffice.alpha = 1
            vwContainerHeight.constant = 250
        }
        //vwContainerHeight.constant = appointmentData.showInOfficeButton ? 250 : 200
        btnDoctorOffice.isHidden = !appointmentData.showInOfficeButton 
    }

    
    func addMapPin(lat: Double, long: Double) {

        vwMap.clear()

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.icon = UIImage(named: "mappin")
        marker.map = vwMap

        let camera = GMSCameraUpdate.setCamera(
            GMSCameraPosition(latitude: lat, longitude: long, zoom: 12)
        )

        vwMap.animate(with: camera)
    }
    
    func combineEventDateTime(date: String, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let fullString = "\(date) \(time)"
        return formatter.date(from: fullString)
    }
    
    func addEventToCalender() {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { [self] granted, error in
            if granted && error == nil {

                let dateStr = appointmentData.appointmentInfo.date
                let timeStr = appointmentData.appointmentInfo.time

                guard let startDate = combineEventDateTime(date: dateStr, time: timeStr) else {
                    DispatchQueue.main.async {
                        self.showAlertView(message: "Invalid date or time")
                    }
                    return
                }

                let event = EKEvent(eventStore: eventStore)
                event.title = "Doctor Appointment"
                event.startDate = startDate
                event.endDate = startDate.addingTimeInterval(3600)   // 1 hour
                event.notes = "Your Appointment with doctor"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                let alarm = EKAlarm(relativeOffset: -30 * 60) // negative = before event
                event.addAlarm(alarm)
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    DispatchQueue.main.async {
                        self.showAlertView(message: "Event added to calendar")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlertView(message: "Error saving event: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertView(message: "Calendar access denied")
                }
            }
        }
    }
    
    func openDirections(){
        // Destination coordinates
        let destinationLatitude = Double(appointmentData.slotInfo.slotAddress.lat) ?? 0.0
        let destinationLongitude = Double(appointmentData.slotInfo.slotAddress.long) ?? 0.0
        let destinationName = "Clinic Address"

        // 1️⃣ Build Google Maps URL
        let googleMapsURLString = "comgooglemaps://?daddr=\(destinationLatitude),\(destinationLongitude)&directionsmode=driving"
        let googleMapsWebURLString = "https://www.google.com/maps/dir/?api=1&destination=\(destinationLatitude),\(destinationLongitude)&travelmode=driving"

        // 2️⃣ Try opening Google Maps first
        if let googleMapsURL = URL(string: googleMapsURLString),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            return
        }

        // 3️⃣ Otherwise, open Apple Maps as fallback
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude))
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = destinationName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func NotifyDoctor(){
        let param: [String: Any] = [
            "appointment_id": appointmentID,
        ]
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.notifyDoctor,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertView(message: data.message)
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
    @IBAction func btnCallAction(_ sender: Any) {
        let phoneNumber = appointmentData.officeInfo.phone
           if let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           } else {
               // Optional: Show alert if device cannot make calls
               showAlertView(message: "Your device cannot make calls.")
           }
    }
    @IBAction func btnAddCalenderAction(_ sender: Any) {
        addEventToCalender()
    }
    @IBAction func btnDirectionAction(_ sender: Any) {
        openDirections()
    }
    @IBAction func btnEditApptAction(_ sender: Any) {
        vwOverlay.alpha = 0.3
        vwModifyAppointment.alpha = 1
    }
    @IBAction func btnShowAddressAction(_ sender: Any) {
        openDirections()
    }
    
    
    @IBAction func btnLearnBillingAction(_ sender: Any) {
    }
    @IBAction func btnBookFollowupAction(_ sender: Any) {
        let nextVC = getDoctorAvailableSlotsVC()
        nextVC.providerID = appointmentData.providerInfo.id
        nextVC.isForFollowUp = true
        nextVC.appointmentData = self.appointmentData
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnCloseModifyApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwModifyAppointment.alpha = 0
    }
    @IBAction func btnModifyApptAction(_ sender: Any) {
        let nextVC = getDoctorAvailableSlotsVC()
        nextVC.providerID = appointmentData.providerInfo.id
        nextVC.isForEditAppointment = true
        nextVC.appointmentData = self.appointmentData
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnCancelApptAction(_ sender: Any) {
        let nextVC = getCancelAppointmentReasonVC()
        nextVC.appointmentID = self.appointmentID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnKeepApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwModifyAppointment.alpha = 0
    }
    @IBAction func btnDoctorOfficeAction(_ sender: Any) {
        NotifyDoctor()
    }
    
}
extension ApptDoctorDetailVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentData.preparationGuideline.guidelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuidelineTCell") as! GuidelineTCell
        cell.lblGuideline.text = " \(indexPath.row + 1). \(appointmentData.preparationGuideline.guidelines[indexPath.row])"
       
        return cell
    }
    
}

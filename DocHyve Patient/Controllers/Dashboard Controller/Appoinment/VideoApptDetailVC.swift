//
//  VideoApptDetailVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 20/11/2025.
//

import UIKit
import EventKit
//import JitsiMeetSDK
class VideoApptDetailVC: ParentViewController {

    //MARK: Outlets
    
    @IBOutlet var vwScrollView: UIScrollView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var imgDoc: UIImageView!
    @IBOutlet var lblUpcomingAppt: UILabel!
    @IBOutlet var lblDocRole: UILabel!
    @IBOutlet var lblDateTime: UILabel!
    @IBOutlet var lblIllness: UILabel!
    @IBOutlet var lblCallOffice: UILabel!
    @IBOutlet var lblAddToCalender: UILabel!
    @IBOutlet var lblModify: UILabel!
    @IBOutlet var lblApptLinkHeading: UILabel!
    @IBOutlet var btnApptLink: UIButton!
    @IBOutlet var lblClickToJoin: UILabel!
    @IBOutlet var lblGuidelines: UILabel!
    @IBOutlet var tblGuidelines: UITableView!
    @IBOutlet var lblWhatCanDoAfterAppt: UILabel!
    @IBOutlet var btnHowBillingWork: UIButton!
    @IBOutlet var btnBookFollowup: UIButton!
    @IBOutlet var tblGuideHeight: NSLayoutConstraint!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwModifyAppt: UIView!
    @IBOutlet var btnShareLink: UIButton!
    @IBOutlet var lblMeetingUrl: UILabel!
    @IBOutlet var vwStack: UIStackView!
    @IBOutlet var vwTopContainerHeight: NSLayoutConstraint!
    @IBOutlet var vwAppointmentInfo: UIView!
    @IBOutlet var vwAppointmentInfoHeight: NSLayoutConstraint!
    
    //MARK: Variable
    var appointmentID = -1
    var hideButtons = false
    var appointmentData = SingleAppointmentDetail()
   // var jitsiView: JitsiMeetView!
    
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
        vwModifyAppt.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }

    
    //MARK: Functions
    func customization(){
        vwOverlay.alpha = 0
        vwModifyAppt.alpha = 0
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
        let imageURL = Constants.URLs.imagePath + appointmentData.providerInfo.providerImage
        imgDoc.loadImage(from: imageURL)
        lblUpcomingAppt.text = "Your upcoming visit with Dr. \(appointmentData.providerInfo.firstName) \(appointmentData.providerInfo.lastName)"
        lblDocRole.text = appointmentData.providerInfo.specialization
        lblDateTime.text = appointmentData.appointmentInfo.formattedDateTime
        lblIllness.text = appointmentData.illnessInfo.name
        
        lblMeetingUrl.text = appointmentData.videoInfo.joinUrl
       
        tblGuidelines.reloadData()
        tblGuidelines.layoutIfNeeded()
        updateTableViewHeight()
        
        if hideButtons{
            vwTopContainerHeight.constant = 140
            vwStack.alpha = 0
            vwAppointmentInfo.alpha = 0
            vwAppointmentInfoHeight.constant = 0
        }else{
            vwTopContainerHeight.constant = 250
            vwStack.alpha = 1
            vwAppointmentInfo.alpha = 1
            vwAppointmentInfoHeight.constant = 100
        }
    }
    func addEventToCalemder(){
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { [self] granted, error in
            if granted && error == nil {
                let eventDate = appointmentData.appointmentInfo.date.convertIntoDateUsingFormat(format: "YYYY-MM-dd")
                let event = EKEvent(eventStore: eventStore)
                event.title = "Doctor Appointment"
                event.startDate = eventDate
                event.endDate = eventDate?.addingTimeInterval(3600)
                event.notes = "Your Appointment with doctor"
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event added!")
                } catch let err {
                    print("Error saving event: \(err)")
                }
            }
        }
    }
    
    
//    func startCall() {
//        
//        let options = JitsiMeetConferenceOptions.fromBuilder { builder in
//            builder.serverURL = URL(string: "https://meet.dochyve.com")
//            builder.room = "call_64C35ACE-FEE6-4F49-B78A-4E1F6E36FEFF"//self.appointmentData.videoCallMeetingID
//            builder.setFeatureFlag("lobby.enabled", withBoolean: false)
//        }
//
//        jitsiView = JitsiMeetView(frame: self.view.bounds)
//        jitsiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        // 🔥 IMPORTANT FIX
//        jitsiView.delegate = self
//        
//        view.addSubview(jitsiView)
//
//        jitsiView.join(options)
//    }
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCallDocAction(_ sender: Any) {
        let phoneNumber = appointmentData.officeInfo.phone
           if let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           } else {
               // Optional: Show alert if device cannot make calls
               showAlertView(message: "Your device cannot make calls.")
           }
        
        //startCall()
//        let nextVC = VideoApptDetailVC.getVideoCallVC()
//        self.navigationController?.pushViewController(nextVC, animated: true)
        
//        let vc = VideoCallWebVC()
//        vc.roomID = "call_64C35ACE-FEE6-4F49-B78A-4E1F6E36FEFF"
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
    }
    @IBAction func btnAddToCalenderAction(_ sender: Any) {
        addEventToCalemder()
    }
    @IBAction func btnModifyApptAction(_ sender: Any) {
        vwOverlay.alpha = 0.3
        vwModifyAppt.alpha = 1
    }
    @IBAction func btnApptLinkAction(_ sender: Any) {
        
        if let url = URL(string: appointmentData.videoInfo.joinUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func btnShareLinkAction(_ sender: Any) {
        let url = URL(string: appointmentData.videoInfo.joinUrl)
        let activityVC = UIActivityViewController(activityItems: [url ?? ""], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @IBAction func btnHowBillingWorkAction(_ sender: Any) {
    }
    @IBAction func btnBookFollowupAction(_ sender: Any) {
        let nextVC = getDoctorAvailableSlotsVC()
        nextVC.providerID = appointmentData.providerInfo.id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnCloseModifyApptAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwModifyAppt.alpha = 0
    }
    @IBAction func btnEditApptAction(_ sender: Any) {
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
        vwModifyAppt.alpha = 0
    }
 
    
}

extension VideoApptDetailVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentData.preparationGuideline.guidelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuidelineTCell") as! GuidelineTCell
        cell.lblGuideline.text = " \(indexPath.row + 1). \(appointmentData.preparationGuideline.guidelines[indexPath.row])"
       
        return cell
    }
    
}

//extension VideoApptDetailVC:JitsiMeetViewDelegate{
//    func conferenceJoined(_ data: [AnyHashable : Any]!) {
//          print("Conference Joined")
//      }
//
//      func conferenceTerminated(_ data: [AnyHashable : Any]!) {
//          print("Conference Ended")
//          DispatchQueue.main.async {
//                self.jitsiView?.leave()
//                self.jitsiView?.removeFromSuperview()
//                self.jitsiView = nil
//            }
//      }
//}

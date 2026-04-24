//
//  ReviewDoctorVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/01/2026.
//

import UIKit
import Cosmos

class ReviewDoctorVC: ParentViewController {
    
    //MARK: Outlets

    @IBOutlet var vwContainer: UIView!
    @IBOutlet weak var lblShareFeedback: UILabel!
    @IBOutlet weak var imgDoc: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblDocSpeciality: UILabel!
    @IBOutlet weak var vwRatingMain: CosmosView!
    @IBOutlet weak var lblHowWasAppt: UILabel!
    @IBOutlet weak var vwRateWaitTime: CosmosView!
    @IBOutlet weak var lblWaitTime: UILabel!
    @IBOutlet weak var vwRateCommunication: CosmosView!
    @IBOutlet weak var lblCommunication: UILabel!
    @IBOutlet weak var vwRateCleanliness: CosmosView!
    @IBOutlet weak var lblCleanliness: UILabel!
    @IBOutlet weak var vwRateBooking: CosmosView!
    @IBOutlet weak var lblBooking: UILabel!
    @IBOutlet weak var lblTotalRating: UILabel!
    @IBOutlet weak var lblLeaveComment: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet var lblBedsideManner: UILabel!
    @IBOutlet var vwRateBedsideManner: CosmosView!
    
    
    //MARK: Variable
    var totalScore = 0.0
    var punctualityRating = 0.0
    var commRating = 0.0
    var treatmentGuidenceRating = 0.0
    var satisfactionRating = 0.0
    var behaviourRating = 0.0
    
    var providerInfo = ProviderInfoModel()
    var appointmentID = -1
    
    var appointmentData = SingleAppointmentDetail()
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTotalRating.text = "Total Score: \(totalScore/5)"
        customization()
        
        getApptData()
    }
    
    //MARK: Functions
    
    func getApptData(){
        showLoadingView("")
        let endPoint =  String(format: Constants.URLs.singleAppointmentDetail, appointmentID)
        SingleAppointmentDetailService().getData(apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? SingleAppointmentResponseModel
                {
                    self.appointmentData = data.appointmentData
                    setScreenInfo()
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func setScreenInfo(){
        let imageURL = Constants.URLs.imagePath + appointmentData.providerInfo.providerImage
        imgDoc.loadImage(from: imageURL)
        lblDocName.text = "\(appointmentData.providerInfo.firstName) \(appointmentData.providerInfo.lastName)"
        lblDocSpeciality.text = appointmentData.providerInfo.specialities.map { $0.name }.joined(separator: ", ")
        
        vwContainer.alpha = 1
    }
    
    func customization(){
        vwContainer.alpha = 0
        
        vwRatingMain.settings.fillMode = .precise

        vwRateWaitTime.didFinishTouchingCosmos = { [self] wait in
            
            updateRating(for: wait, with: &punctualityRating, label: lblTotalRating, totalRatingView: vwRateWaitTime)
        }
        vwRateCommunication.didFinishTouchingCosmos = { [self] comm in
            
            updateRating(for: comm, with: &commRating, label: lblTotalRating, totalRatingView: vwRateCommunication)
        }
        vwRateCleanliness.didFinishTouchingCosmos = { [self] clean in
            
            updateRating(for: clean, with: &treatmentGuidenceRating, label: lblTotalRating, totalRatingView: vwRateCleanliness)
        }
        vwRateBooking.didFinishTouchingCosmos = { [self] booking in
            
            updateRating(for: booking, with: &satisfactionRating, label: lblTotalRating, totalRatingView: vwRateBooking)
        }
        vwRateBedsideManner.didFinishTouchingCosmos = { [self] bedsideManner in
            
            updateRating(for: bedsideManner, with: &behaviourRating, label: lblTotalRating, totalRatingView: vwRateBedsideManner)
        }
      
    }
    
    func updateRating(for rating: Double, with oldRating: inout Double, label: UILabel, totalRatingView: CosmosView) {
        totalScore -= oldRating
        totalScore += rating
        oldRating = rating
        lblTotalRating.text = "Total Score: \(totalScore/5)"
        vwRatingMain.rating = totalScore/5
    }
    
    func submitReview(){
        
        let param: [String: Any] = [
            "provider_id": appointmentData.providerInfo.id,
            "appointment_id":appointmentID,
            "punctuality_rating":punctualityRating,
            "communication_rating":commRating,
            "behavior_rating":behaviourRating,
            "treatment_guidance_rating":treatmentGuidenceRating,
            "satisfaction_rating":satisfactionRating,
            "review":txtComment.text!,
            "rating":vwRatingMain.rating,
        ]
        
        let endPoint =  Constants.URLs.saveAppointmentReview
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) {
                        DataManager.shared.isDataUpdated = true
                        self.navigationController?.popViewController(animated: true)
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
    @IBAction func btnSubmitAction(_ sender: Any) {
        submitReview()
    }
    
}

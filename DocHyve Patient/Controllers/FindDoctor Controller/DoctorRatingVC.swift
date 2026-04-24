//
//  DoctorRatingVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 04/03/2024.
//

import UIKit
import Cosmos

class DoctorRatingVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTotalRating: UILabel!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var tblRating: UITableView!
    @IBOutlet weak var tblRatingHeight: NSLayoutConstraint!
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var lblTotalReview: UILabel!
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var vwFilterView: UIView!
    @IBOutlet  var btnFilter: [UIButton]!
    @IBOutlet var lblMostRecent: UILabel!
    @IBOutlet var lblHighestRated: UILabel!
    @IBOutlet var lblLowestRated: UILabel!
    @IBOutlet var imgTick1: UIImageView!
    @IBOutlet var imgTick2: UIImageView!
    @IBOutlet var imgTick3: UIImageView!
    @IBOutlet var lblFilterType: UILabel!
    
    
    //MARK: Variable
    var providerID = -1
    var providerName = ""
    
    var reviewData = ReviewInfo()
    var selectedSortType = "most_recent"
    var newSelection = "most_recent"
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        vwRating.settings.fillMode = .precise
        getReviews()
        
        imgTick2.isHidden = true
        imgTick3.isHidden = true
        vwOverlay.alpha = 0
        vwFilterView.alpha = 0
    }
    override func viewDidLayoutSubviews() {
        vwFilterView.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    //MARK: Functions
    func getReviews(){
        showLoadingView("")
        GetAllReviewService().getData(providerID: providerID, sortBy: selectedSortType, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? ReviewReponseModel
                {
                    reviewData = data.reviewData
                    tblRating.reloadData()
                    tblReview.reloadData()
                    setData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func setData(){
        lblTotalRating.text = "\(reviewData.overallRating)"
        vwRating.rating = reviewData.overallRating
        lblTotalReview.text = "\(reviewData.totalReviews) Reviews"
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnShowFilterAction(_ sender: Any) {
        vwOverlay.alpha = 0.3
        vwFilterView.alpha = 1
        
    }
    
    @IBAction func btnCloseReviewAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwFilterView.alpha = 0
        if newSelection != selectedSortType{
            selectedSortType = newSelection
            getReviews()
        }
    }
    
    @IBAction func btnFilterAction(_ sender: UIButton) {
        let sortOptions = ["Most Recent", "Highest Rated", "Lowest Rated"]
        let sortOptions2 = ["most_recent", "highest_rating", "lowest_rating"]
        let tickImages = [imgTick1, imgTick2, imgTick3]

        if sender.tag >= 1 && sender.tag <= sortOptions.count {
            lblFilterType.text = sortOptions[sender.tag - 1]
            newSelection = sortOptions2[sender.tag - 1]
        }

        for (index, tick) in tickImages.enumerated() {
            tick?.isHidden = (index + 1 != sender.tag)
        }
        
    }
    
}
extension DoctorRatingVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblRating{
            return reviewData.arrRating.count
        }else{
            return reviewData.arrReview.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblRating{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTCell") as! RatingTCell
            cell.setCell(item: reviewData.arrRating[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTCell") as! ReviewsTCell
            cell.setReviewData(item: reviewData.arrReview[indexPath.row])
            return cell
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 30
//    }
    
}

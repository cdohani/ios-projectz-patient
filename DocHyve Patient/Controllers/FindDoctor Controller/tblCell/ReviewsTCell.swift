//
//  ReviewsTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 04/03/2024.
//

import UIKit
import Cosmos

class ReviewsTCell: UITableViewCell {
    @IBOutlet weak var lblReviewName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var lblReviewStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setReviewData(item:ReviewModel){
        lblReviewName.text = item.patientName
        lblState.text = item.patientState
        vwRating.rating = item.rating
        lblReview.text = item.comment
        lblTime.text = item.timeAgo
        lblReviewStatus.text = item.verifiedPatinet ? "Verified Patient" : "Not Verified Patient"
    }

}

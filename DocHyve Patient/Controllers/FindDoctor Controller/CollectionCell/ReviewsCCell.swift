//
//  ReviewsCCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 06/03/2024.
//

import UIKit
import Cosmos

class ReviewsCCell: UICollectionViewCell {
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    
    func setData(item: ReviewModel){
        lblName.text = item.patientName
        lblState.text = item.patientState
        lblReview.text = item.comment
        vwRating.rating = item.rating
        lblTime.text = timeAgo(from: item.createdAt)
    }
    
}

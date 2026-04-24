//
//  RecommendedDoctorCCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 27/02/2024.
//

import UIKit

class RecommendedDoctorCCell: UICollectionViewCell {
    
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var imgDoctor: UIImageView!
    @IBOutlet weak var vwRecommended: UIView!
    @IBOutlet weak var lblRecommended: UILabel!
    @IBOutlet weak var imgRecommended: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblDocType: UILabel!
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var imgBoosted: UIImageView!
    
    
    
    func setUpCell(with model: RecommendedDoctorModel) {
        
        let imageURL = Constants.URLs.imagePath + model.providerImage
        imgDoctor.loadImage(from: imageURL)
        lblDocName.text = "\(model.firstName) \(model.lastName)"
        lblReviewCount.text = "\(model.avgRating) (\(model.totalReviews) reviews)"
        lblDocType.text = model.specialities
        if model.isBoosted{
            imgBoosted.isHidden = false
            imgBoosted.image = UIImage(named: "iconBoost")
            imgRecommended.image = UIImage(named: "iconBoost")
            vwRecommended.backgroundColor = UIColor(named: "customBlueColor")
            lblRecommended.text = "Super Provider"
        }else{
            imgBoosted.isHidden = true
            vwRecommended.backgroundColor = UIColor(named: "customGreenColor")
            lblRecommended.text = "Recommended"
            imgRecommended.image = UIImage(systemName: "star.fill")
        }
    }
}

//
//  PastApptStatusTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 21/03/2024.
//

import UIKit

class PastApptStatusTCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet var lblPendingReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    }
    override func prepareForReuse() {
           super.prepareForReuse()
        lblPendingReview.layer.removeAnimation(forKey: "blink")
           
       }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item :AppointmentDetail){
        lblCategory.text = item.illness
        let dateText = "\(item.date) - \(item.time)"
        lblDate.attributedText = item.status == "cancelled"
            ? dateText.strikeThrough()
            : NSAttributedString(string: dateText)
        lblStatus.text = "- \(item.status.capitalized)"
        let statusColor = AppointmentStatus.getDarkColor(for: item.status)
        lblStatus.textColor = statusColor
        lblPendingReview.isHidden = !(item.status == "completed" && !item.isReviewed)
        imgStatus.image = UIImage(named: item.status == "cancelled" ? "cross_x" : "tick")
        
    }
    
    func startBlinking() {
        lblPendingReview.layer.removeAnimation(forKey: "blink")

         let animation = CABasicAnimation(keyPath: "opacity")
         animation.fromValue = 1
         animation.toValue = 0
         animation.duration = 0.8
         animation.autoreverses = true
         animation.repeatCount = .infinity

        lblPendingReview.layer.add(animation, forKey: "blink")
     }
    
    func stopBlinking(label: UILabel) {
        label.layer.removeAllAnimations()
        label.alpha = 1
    }

}

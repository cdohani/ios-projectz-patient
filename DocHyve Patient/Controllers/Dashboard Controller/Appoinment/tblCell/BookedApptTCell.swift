//
//  BookedApptTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 19/03/2024.
//

import UIKit

class BookedApptTCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgDoc: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblDocCategory: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblApptStatus: UILabel!
    @IBOutlet weak var lblIlness: UILabel!
    @IBOutlet weak var vwVideoVisit: UIView!
    @IBOutlet weak var imgBookingType: UIImageView!
    @IBOutlet weak var lblBookingType: UILabel!
    
    @IBOutlet weak var vwAddCard: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnUploadCard: UIButton!
    @IBOutlet weak var vwContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet var btnPendingReview: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vwAddCard.isHidden = true
        vwContainerHeight.constant = 180
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setCell (item:UserAppointmentDetail) {
        imgDoc.loadImage(from: item.providerInfo.providerImage)
        lblDocName.text = item.providerInfo.firstName  + " " + item.providerInfo.lastName
        lblDocCategory.text = item.providerInfo.specialities.map({$0.name}).joined(separator: ", ")
        lblTime.text = formatDate(item.date, item.time)
        lblApptStatus.text = item.status.capitalized
        lblIlness.text = item.illness.name
        let systemName = (item.bookingType == "in-person") ? "person.circle.fill" : "video.circle.fill"
        imgBookingType.image = UIImage(systemName: systemName)
        lblBookingType.text = item.bookingType.capitalized
        
        let cardColor = AppointmentStatus.getLightColor(for: item.status)
        vwContainer.backgroundColor = cardColor
        
        let lblColor = AppointmentStatus.getDarkColor(for: item.status)
        lblApptStatus.textColor = lblColor
        
        if item.status == AppointmentStatus.completed.rawValue && !item.isPendingReview{
            btnPendingReview.isHidden = false
            vwContainerHeight.constant = 180
            btnPendingReview.startBlinking()
        }else{
            btnPendingReview.isHidden = true
            vwContainerHeight.constant = 150
            btnPendingReview.stopBlinking()
        }
        
        //        if arrIndex.contains(indexPath.row){
        //            cell.vwAddCard.isHidden = false
        //            cell.vwContainerHeight.constant = 250
        //        }else{
        //            cell.vwAddCard.isHidden = true
        //            cell.vwContainerHeight.constant = 140
        //        }
        
    }
    
    func formatDate(_ date: String, _ time: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let d = f.date(from: "\(date) \(time)") else { return "" }
        f.dateFormat = "E, d MMM HH:mm a"
        return f.string(from: d)
    }
}
 

//
//  NotificationTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 29/02/2024.
//

import UIKit

class NotificationTCell: UITableViewCell {

    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblNotiText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet var btnDeleteNotification: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setNotificationData(data: NotificationModel) {
        lblNotiText.text = data.message
        lblTime.text = timeAgo(from: data.createdAt ,format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'")
        vwBackground.backgroundColor = data.isread ? UIColor.white : UIColor(named: "customNavbarColor")
        
    }

}

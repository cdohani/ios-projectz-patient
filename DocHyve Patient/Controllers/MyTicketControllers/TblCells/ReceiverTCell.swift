//
//  ReceiverTCell.swift
//  DocHyve
//
//  Created by MacBook Pro on 30/07/2024.
//

import UIKit

class ReceiverTCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblMsg: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(data:TicketReplyModel){
        lblMsg.text = data.message
        lblName.text = data.user.name
        lblTime.text = data.createdDiff
        imgUser.loadImage(from: data.user.image)
    }
}

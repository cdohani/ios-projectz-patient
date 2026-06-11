//
//  TicketInquiryTCell.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/08/2024.
//

import UIKit

class TicketInquiryTCell: UITableViewCell {

    @IBOutlet weak var vwInquiry: UIView!
    @IBOutlet weak var vwInquiryHeight: NSLayoutConstraint!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnSeeMore: UIButton!
    @IBOutlet weak var btnAddComment: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

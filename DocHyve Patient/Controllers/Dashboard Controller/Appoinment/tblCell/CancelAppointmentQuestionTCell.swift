//
//  CancelAppointmentQuestionTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 31/10/2025.
//

import UIKit

class CancelAppointmentQuestionTCell: UITableViewCell {

    @IBOutlet var vwContainer: UIView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var btnYes: UIButton!
    @IBOutlet var lblYes: UILabel!
    @IBOutlet var btnNO: UIButton!
    @IBOutlet var lblNo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

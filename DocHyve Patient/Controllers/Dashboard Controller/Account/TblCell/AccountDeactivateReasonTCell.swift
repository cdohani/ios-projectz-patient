//
//  AccountDeactivateReasonTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 04/05/2026.
//

import UIKit

class AccountDeactivateReasonTCell: UITableViewCell {

 
    @IBOutlet weak var imgOption: UIImageView!
    @IBOutlet weak var lblOption: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item:DropDownModel){
        lblOption.text = item.name
       
    }

}

//
//  SecurityTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 23/02/2024.
//

import UIKit

class SecurityTCell: UITableViewCell {
    
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var btnDeactivate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func hideInfo(currentIndex:Int){
        btnDeactivate.isHidden = currentIndex == 0 || currentIndex == 1
        imgNext.isHidden = currentIndex == 1 || currentIndex == 2
    }

}

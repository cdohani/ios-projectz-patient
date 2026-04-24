//
//  RatingTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 04/03/2024.
//

import UIKit

class RatingTCell: UITableViewCell {

    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var vwProgress: UIProgressView!
    @IBOutlet var lblRating: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setCell(item:RatingInfo){
        lblHeading.text = item.name.capitalized
        lblRating.text = "\(item.rating)"
        vwProgress.progress = Float(item.rating) / 5.0
    }
}

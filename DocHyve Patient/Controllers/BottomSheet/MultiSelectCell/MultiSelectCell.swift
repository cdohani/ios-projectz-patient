//
//  MultiSelectCell.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 12/29/25.
//

import UIKit

class MultiSelectCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

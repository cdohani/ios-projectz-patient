//
//  HealthCheckTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class HealthCheckTCell: UITableViewCell {
    @IBOutlet weak var lblMedicalHistoryName: UILabel!
    @IBOutlet weak var lblLastUpdated: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item: HealthCheckModel){
        lblMedicalHistoryName.text = item.name
        let modifiedDate = item.lastModifiedAt.convertToDate(format: "MMM-dd-yyyy", inputFormate: "yyyy-mm-dd HH:mm:ss")
        lblLastUpdated.text = "Last Updated: \(modifiedDate ?? "")"
        imgStatus.image = item.isSelected ? UIImage(named: "tick") : UIImage(systemName: "exclamationmark.triangle.fill")
    }

}

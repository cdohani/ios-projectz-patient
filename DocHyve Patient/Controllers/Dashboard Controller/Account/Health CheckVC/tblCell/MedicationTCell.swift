//
//  MedicationTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 18/03/2024.
//

import UIKit

class MedicationTCell: UITableViewCell {
    @IBOutlet weak var lblMedName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblFrequencyHeading: UILabel!
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDurationVal: UILabel!
    @IBOutlet weak var lblReasonHeading: UILabel!
    @IBOutlet weak var lblReasonDesc: UILabel!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item: MedicineDetailModel){
        lblMedName.text = item.medication
        lblQty.text = item.dosage
        lblFrequency.text = item.frequency
        lblDurationVal.text = item.duration
        lblReasonDesc.text = item.reason
    }

}

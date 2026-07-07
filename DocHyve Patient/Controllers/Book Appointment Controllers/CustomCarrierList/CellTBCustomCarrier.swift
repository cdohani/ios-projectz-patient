//
//  CellTBCustomCarrier.swift
//  DocHyve
//
//  Created by MeshSq on 23/06/2026.
//

import UIKit
import TagListView


class CellTBCustomCarrier: UITableViewCell {

    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbState: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tagPlan: TagListView!
    
    var data: CustomCarrier? {
        didSet {
            setData()
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    private func setData() {
        lbName.text = data?.insurance_name
        lbState.text = data?.state?.name
        lbDate.text = data?.created_at?.indate(.utc)?.dateString(.MM_DD_YY_Slach_HH_mm_a)
        lbStatus.text = data?.status?.capitalized
        tagPlan.removeAllTags()
        for plan in data?.plans ?? [] {
            tagPlan.addTag(plan)
        }
    }
}

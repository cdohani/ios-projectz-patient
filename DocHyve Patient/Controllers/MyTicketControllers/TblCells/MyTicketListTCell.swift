//
//  MyTicketListTCell.swift
//  DocHyve
//
//  Created by MacBook Pro on 29/07/2024.
//

import UIKit

class MyTicketListTCell: UITableViewCell {

    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblTicketNoHeading: UILabel!
    @IBOutlet weak var lblTicketNo: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var lblSubjectHeading: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet var lblTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setdata(data:TicketDataModel){
        lblTicketNo.text = "\(data.id)"
        lblStatus.text = data.status
        lblSubject.text = data.subject
       
        if let result = formatLastActivity(data.lastActivity) {
            lblDate.text = result.date
            lblTime.text = result.time
        }
        let statusColor = TicketStatus.getLightColor(for: data.status)
        vwBackground.backgroundColor = statusColor
        let borderColor = TicketStatus.getDarkColor(for: data.status)
        vwStatus.backgroundColor = borderColor
        vwBackground.layer.borderColor = borderColor.cgColor
        lblStatus.textColor = borderColor
    }
    
    func formatLastActivity(_ lastActivity: String) -> (date: String, time: String)? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = isoFormatter.date(from: lastActivity) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        return (
            date: dateFormatter.string(from: date),
            time: timeFormatter.string(from: date)
        )
    }

}

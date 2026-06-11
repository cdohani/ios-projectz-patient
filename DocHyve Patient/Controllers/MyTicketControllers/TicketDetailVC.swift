//
//  TicketDetailVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 30/07/2024.
//

import UIKit

class TicketDetailVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblHeading: UIButton!
    @IBOutlet weak var tblTicketInfo: UITableView!
    @IBOutlet weak var vwTicketInfo: UIView!
    @IBOutlet weak var vwSupport: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnSendMessage: UIButton!
    
    
    
    //MARK: Variable
    var isExpanded = false
    var ticketData =  TicketDataModel()
    var arrMessages =  [TicketReplyModel]()
    var ticketID = -1
    var currentUserID = -1
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userID = UserDefaults.standard.object(forKey: "userID") as? Int {
            currentUserID = userID
            print(currentUserID)
        }
        //currentUserID = UserDefaults.standard.object(forKey: Constants.Const.userIDKey) as? Int ?? -1
        vwSupport.alpha = 0
        txtMessage.alpha = 0
        btnSendMessage.alpha = 0
        vwTicketInfo.alpha = 1
        txtMessage.setLeftPaddingPoints(10)
        getMyTickets()
        getTicketReply()
    }
    
    //MARK: Functions
    func scrolltable(){
        if !arrMessages.isEmpty {
            let lastRow = arrMessages.count - 1
            tblChat.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
        }
       
    }
    
    func getMyTickets(){
        showLoadingView("")
        GetTicketDetialService().getData(ticketId: ticketID, completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? TicketDetailResponseModel
                {
                    self?.ticketData = data.ticketData
                    self?.tblTicketInfo.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                self?.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func getTicketReply(){
        showLoadingView("")
        GetTicketMessageService().getData(ticketId: ticketID, completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? TicketMessageResponseModel
                {
                    self?.arrMessages = data.arrMessages
                    self?.tblChat.reloadData()
                    self?.scrolltable()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                self?.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func addReply(){
       
        let param: [String: Any] = [
            "message": txtMessage.text!,
        ]
        showLoadingView("")
        let endPoint =  String(format: Constants.URLs.addReplyToTicket, ticketID)
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    if  data.status == 201{
                        self?.getTicketReply()
                        self?.txtMessage.text = ""
                    }
                    else{
                        self?.showAlertView(message: data.message)
                    }
                }

            }
        }) { (faliure) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                self?.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    private func shouldShowMoreButton(text: String,descLabel:UILabel) -> Bool {
         let label = descLabel
            let maxLines = 2
            let maxSize = CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude)

            let fullTextHeight = text.boundingRect(
                with: maxSize,
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: label.font!],
                context: nil
            ).height

            let oneLineHeight = "A".size(withAttributes: [NSAttributedString.Key.font: label.font!]).height
            let maxAllowedHeight = oneLineHeight * CGFloat(maxLines)

            return fullTextHeight > maxAllowedHeight
        }
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            vwSupport.alpha = 0
            txtMessage.alpha = 0
            btnSendMessage.alpha = 0
            vwTicketInfo.alpha = 1
        }else{
            vwSupport.alpha = 1
            txtMessage.alpha = 1
            btnSendMessage.alpha = 1
            vwTicketInfo.alpha = 0
        }
    }
    @IBAction func btnSendMessageAction(_ sender: Any) {
        if txtMessage.text != ""{
            addReply()
        }
    }
    @IBAction func btnSeeMoreAction(_ sender: UIButton) {
        isExpanded.toggle()
        tblTicketInfo.reloadData()
        sender.setTitle(isExpanded ? "Show Less" : "Show More", for: .normal)
    }
    @IBAction func btnAddCommentAction(_ sender: Any) {
        segmentControl.selectedSegmentIndex = 1
        vwSupport.alpha = 1
        txtMessage.alpha = 1
        btnSendMessage.alpha = 1
        vwTicketInfo.alpha = 0
    }
    
}
extension TicketDetailVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblChat{
            return arrMessages.count
        }else{
            return 10
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblChat{
            if arrMessages[indexPath.row].user.id != currentUserID{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTCell") as! ReceiverTCell
                cell.setData(data: arrMessages[indexPath.row])
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderTCell") as! SenderTCell
                cell.setData(data: arrMessages[indexPath.row])
                return cell
            }
        }
        else{
            if indexPath.row == 9 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TicketInquiryTCell", for: indexPath) as! TicketInquiryTCell
                cell.lblDesc.text = ticketData.description
                cell.lblDesc.numberOfLines = isExpanded ? 0 : 2
                cell.btnSeeMore.isHidden = !shouldShowMoreButton(text: ticketData.description , descLabel: cell.lblDesc)
                cell.btnSeeMore.setAttributedTitle(NSAttributedString(string: isExpanded ? "Show Less" : "Show More"), for: .normal)
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketDetailTCell", for: indexPath) as! TicketDetailTCell

            let ticketDetails: [(String, String?)] = [
                ("Ticket No", "\(ticketData.id)"),
                ("Priority", nil),
                ("Created By", nil),
                ("Open Date", ticketData.lastActivity.components(separatedBy: " ").first),
                ("Close Date", nil),
                ("Name", ticketData.name),
                ("Status", ticketData.status),
                ("Category", ticketData.categoryInfo.name),
                ("Sub-Category", ticketData.subCategoryInfo.name)
            ]

            let detail = ticketDetails[indexPath.row]
            cell.lblHeading.text = detail.0
            cell.lblDesc.text = detail.1 ?? ""

            return cell
        }
           
    }
    
}

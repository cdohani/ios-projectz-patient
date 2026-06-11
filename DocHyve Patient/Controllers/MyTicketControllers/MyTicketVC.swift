//
//  MyTicketVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/07/2024.
//

import UIKit

class MyTicketVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblMyTicket: UILabel!
    @IBOutlet weak var lblNoRequest: UILabel!
    @IBOutlet weak var lblCreateNewTicket: UILabel!
    @IBOutlet weak var btnCreateNewTicket: UIButton!
    @IBOutlet weak var vwNoRequest: UIView!
    @IBOutlet weak var vwMyRequest: UIView!
    @IBOutlet weak var lblMy: UILabel!
    @IBOutlet weak var lblRequest: UILabel!
    @IBOutlet weak var btnCreateNewTicket2: UIButton!
    @IBOutlet weak var lblTicketList: UILabel!
    @IBOutlet weak var tblTicket: UITableView!
    @IBOutlet var txtStatusFilter: AuthTextField!
    
    
    
    //MARK: Variable
    var arrTickets =  [TicketDataModel]()
    var arrFilterTickets =  [TicketDataModel]()
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    var arrFilter = ["All","Open","Closed","In Progress"]
    var availabilty = "All"
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyTickets()
        setupPickerView()
        txtStatusFilter.text = "All"
    }
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.shared.isDataUpdated{
            getMyTickets()
            DataManager.shared.isDataUpdated = false
        }
    }
    
    //MARK: Functions
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        txtStatusFilter.delegate = self
        txtStatusFilter.inputView = pickerView
        txtStatusFilter.inputAccessoryView = toolbar
        // Toolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    @objc func doneTapped() {
         let row = pickerView.selectedRow(inComponent: 0)
        txtStatusFilter.text = arrFilter[row]
        txtStatusFilter.resignFirstResponder()
        availabilty = arrFilter[row]
        if availabilty != "All"{
            arrFilterTickets = arrTickets.filter { $0.status == availabilty }
        }else{
            arrFilterTickets = arrTickets
        }
        tblTicket.reloadData()
     }
     
     @objc func cancelTapped() {
         txtStatusFilter.resignFirstResponder()
     }
    func getMyTickets(){
        showLoadingView("")
        GetTicketService().getData(completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? TicketResponseModel
                {
                    self?.arrTickets = data.arrTickets
                    self?.arrFilterTickets = data.arrTickets
                    self?.tblTicket.reloadData()
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                self?.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCreateNewTicketAction(_ sender: Any) {
        let nextVC = getCreateTicketCategoryVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnCreateTicket2Action(_ sender: Any) {
        let nextVC = getCreateTicketCategoryVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
 
    
}
extension MyTicketVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilterTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTicketListTCell") as! MyTicketListTCell
        cell.setdata(data: arrFilterTickets[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = getTicketDetailVC()
        nextVC.ticketID = arrFilterTickets[indexPath.row].id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension MyTicketVC: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UIPickerViewDataSource
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return arrFilter.count
     }

     // MARK: - UIPickerViewDelegate
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return  arrFilter[row]
     }
}
extension MyTicketVC : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtStatusFilter{
            return false
        }
        return true
    }
}

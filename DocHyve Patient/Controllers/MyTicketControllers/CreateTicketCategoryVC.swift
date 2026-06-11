//
//  CreateTicketCategoryVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 29/07/2024.
//

import UIKit

class CreateTicketCategoryVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet var lblHello: UILabel!
    @IBOutlet var lblHowCanHelp: UILabel!
    @IBOutlet var lblGetinTouch: UILabel!
    @IBOutlet var vwGetInTouch: UIView!
    @IBOutlet var lblStillQuestion: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var vwSearch: UIView!
    @IBOutlet var txtSearch: AuthTextField!
    @IBOutlet var btnSearch: UIButton!
    
    
    
    //MARK: Variable
    var arrCategory =  [CategoryDataModel]()
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblCategory.showsVerticalScrollIndicator = false
        tblCategory.showsHorizontalScrollIndicator = false
        getCategory()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Functions
    
    func getCategory(){
        showLoadingView("")
        GetSupportCategoryService().getData(completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? SupportCategoryResponseModel
                {
                    self?.arrCategory = data.arrCategory
                    self?.tblCategory.reloadData()
                    
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
    @IBAction func btnGetContact(_ sender: Any) {
        let nextVC = getCreateTicketInfoVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
extension CreateTicketCategoryVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        arrCategory.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrCategory[section].arrSubCategory.count
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTicketCategoryHeaderTCell") as! CreateTicketCategoryHeaderTCell
        cell.lblTitle.text = arrCategory[section].name
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTicketCategorySubTypeTCell") as! CreateTicketCategorySubTypeTCell
        cell.lblSubtype.text = arrCategory[indexPath.section].arrSubCategory[indexPath.row].name

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = getCreateTicketQuestionVC()
        nextVC.categoryID = arrCategory[indexPath.section].arrSubCategory[indexPath.row].id
        nextVC.arrSubCategory = arrCategory[indexPath.section].arrSubCategory
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
   
}

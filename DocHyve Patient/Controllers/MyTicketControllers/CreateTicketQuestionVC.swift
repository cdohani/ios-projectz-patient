//
//  CreateTicketQuestionVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 29/07/2024.
//

import UIKit

class CreateTicketQuestionVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblTicket: UILabel!
    @IBOutlet weak var cvCategory: UICollectionView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var tblQuestions: UITableView!
    
    
    
    //MARK: Variable
    var expandedCell = -1
    var categoryID = -1
    var arrSubCategory =  [SubCategoryDataModel]()
    var arrFaqs =  [CategoryFaqDataModel]()
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getFaqs()
    }
    
    //MARK: Functions
    func getFaqs(){
        showLoadingView("")
        GetCategoryFaqService().getData(categoryID: categoryID, completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.removeLoadingView()
                if let data = response as? FAQResponseModel
                {
                    self?.arrFaqs = data.arrFaq
                    self?.tblQuestions.reloadData()
                    self?.cvCategory.reloadData()
                    
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
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContactUsAction(_ sender: Any) {
        let nextVC = getCreateTicketInfoVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
}
extension CreateTicketQuestionVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSubCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCCell", for: indexPath) as! CategoryCCell
        cell.lblTitle.text = arrSubCategory[indexPath.item].name
        if arrSubCategory[indexPath.item].id == categoryID{
            cell.vwBackground.backgroundColor = .customBlue
            cell.lblTitle.textColor = .white
        }else{
            cell.vwBackground.backgroundColor = .white
            cell.lblTitle.textColor = .customBlue
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categoryID = arrSubCategory[indexPath.item].id
        getFaqs()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height:20)
    }
    
}
extension CreateTicketQuestionVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFaqs.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionHeaderTCell") as! QuestionHeaderTCell
        
        cell.setData(data: arrFaqs[indexPath.row])
        if indexPath.row == expandedCell{
            cell.vwDrop.isHidden = false
            cell.imgDrop.image = UIImage(named: "iconDropupBlue")
        }else{
            
            cell.vwDrop.isHidden = true
            cell.imgDrop.image = UIImage(named: "iconDropBlue")
        }
        // self.tblFaqHeightConstraint.constant = tblFaqs.contentSize.height
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

           //Do tap on providerInfo table
            if indexPath.row == expandedCell{
                expandedCell = -1
            }else{
                expandedCell = indexPath.row
            }
            tblQuestions.reloadData()
    }
}

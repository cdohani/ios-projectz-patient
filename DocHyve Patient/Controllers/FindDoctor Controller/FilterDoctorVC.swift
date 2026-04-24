//
//  FilterDoctorVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 06/03/2024.
//

import UIKit

class FilterDoctorVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var lblVisitType: UILabel!
    @IBOutlet weak var segmentVisit: UISegmentedControl!
    @IBOutlet weak var tblFilters: UITableView!
    //MARK: Variable
    
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        customization()
    }
    
    //MARK: Functions
    func customization(){
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentVisit.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentGenderAction(_ sender: Any) {
    }
    @IBAction func segmentVisitAction(_ sender: Any) {
    }
}
extension FilterDoctorVC :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTCell") as! AccountHeaderTCell
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 6
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTCell") as! FilterTCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

//
//  HealthCheckVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit

class HealthCheckVC: ParentViewController {

    //MARK: Outlets
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblHealth: UITableView!
    @IBOutlet weak var btnViewHealth: UIButton!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet var txtMember: AuthTextField!
    @IBOutlet var btnClear: UIButton!
    @IBOutlet var vwConsent: UIView!
    @IBOutlet var btnAgree: UIButton!
    @IBOutlet var lblConsent: UILabel!
    @IBOutlet var lblSelectMember: UILabel!
    @IBOutlet var vwInfo: UIView!
    
    //MARK: Variable
    var arrData = [HealthCheckModel]()
    var arrMember = [MemberDetailModel]()
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    var currentMemberID : Int?
    var isAggrementCheck = false
    var accountUserName = UserDefaults.standard.string(forKey: "userName") ?? ""
    var currentSelectedName = ""
    private let healthRiskScoreView = HealthRiskScoreView()
    private let recommendedDoctorsView = HealthCheckRecommendedDoctorsView()
    private var recommendedDoctorsHeightConstraint: NSLayoutConstraint?
    private var recommendedDoctorsTopConstraint: NSLayoutConstraint?
    private let tableHeaderContainer = UIView()
    private var didSetupSingleScrollLayout = false
    private var lastSizedHeaderWidth: CGFloat = 0
    private var isUpdatingTableHeader = false
    private var latestGaugeData: HealthRiskScoreData?
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSelectedName = accountUserName
        customization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataManager.shared.isDataUpdated {
            DataManager.shared.isDataUpdated = false
            getHealthData(memberId: currentMemberID)
            getHealthRiskGauge(animated: true)
            guard isUserLoggedIn(), !healthRiskScoreView.isHidden else { return }
            sizeTableHeaderIfNeeded(force: false)
            if let gaugeData = latestGaugeData {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.healthRiskScoreView.configure(with: gaugeData, animated: true)
                    self?.applySuggestedDoctors(from: gaugeData)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
  
    func customization(){
        if isUserLoggedIn(){
            txtMember.text = accountUserName + " (Self)"
            vwContainer.isHidden = true
            txtMember.isHidden = false
            tblHealth.isHidden = false
            btnViewHealth.isHidden = false
            vwConsent.isHidden = false
            lblSelectMember.isHidden = false
            vwInfo.isHidden = false
            healthRiskScoreView.isHidden = false
            // Suggested doctors stay hidden until gauge API returns recommendations.
            recommendedDoctorsView.isHidden = true
            setupSingleScrollLayoutIfNeeded()
            getMembers()
        } else {
            vwContainer.isHidden = false
            tblHealth.isHidden = true
            btnViewHealth.isHidden = true
            txtMember.isHidden = true
            vwConsent.isHidden = true
            lblSelectMember.isHidden = true
            vwInfo.isHidden = true
            healthRiskScoreView.isHidden = true
            recommendedDoctorsView.isHidden = true
        }
        setupPickerView()
    }
    
    /// Puts member + info + meter in the table header so the whole page scrolls together.
    private func setupSingleScrollLayoutIfNeeded() {
        guard !didSetupSingleScrollLayout else { return }
        didSetupSingleScrollLayout = true
        guard let navBar = lblHeading.superview else { return }
        
        view.constraints.filter {
            let first = $0.firstItem as? UIView
            let second = $0.secondItem as? UIView
            return first === tblHealth
                || first === lblSelectMember
                || first === txtMember
                || first === vwInfo
                || first === btnClear
                || second === tblHealth
                || second === lblSelectMember
                || second === txtMember
                || second === vwInfo
                || second === btnClear
                || (first === btnViewHealth && $0.firstAttribute == .top && second === tblHealth)
        }.forEach { $0.isActive = false }
        
        [lblSelectMember, txtMember, btnClear, vwInfo].forEach { $0.removeFromSuperview() }
        
        tableHeaderContainer.backgroundColor = .clear
        healthRiskScoreView.translatesAutoresizingMaskIntoConstraints = false
        lblSelectMember.translatesAutoresizingMaskIntoConstraints = false
        txtMember.translatesAutoresizingMaskIntoConstraints = false
        btnClear.translatesAutoresizingMaskIntoConstraints = false
        vwInfo.translatesAutoresizingMaskIntoConstraints = false
        
        tableHeaderContainer.addSubview(lblSelectMember)
        tableHeaderContainer.addSubview(txtMember)
        tableHeaderContainer.addSubview(btnClear)
        tableHeaderContainer.addSubview(vwInfo)
        tableHeaderContainer.addSubview(healthRiskScoreView)
        tableHeaderContainer.addSubview(recommendedDoctorsView)
        
        recommendedDoctorsView.translatesAutoresizingMaskIntoConstraints = false
        recommendedDoctorsView.delegate = self
        
        let doctorsHeight = recommendedDoctorsView.heightAnchor.constraint(equalToConstant: 0)
        recommendedDoctorsHeightConstraint = doctorsHeight
        let doctorsTop = recommendedDoctorsView.topAnchor.constraint(equalTo: healthRiskScoreView.bottomAnchor, constant: 0)
        recommendedDoctorsTopConstraint = doctorsTop
        
        NSLayoutConstraint.activate([
            lblSelectMember.topAnchor.constraint(equalTo: tableHeaderContainer.topAnchor, constant: 10),
            lblSelectMember.leadingAnchor.constraint(equalTo: tableHeaderContainer.leadingAnchor, constant: 20),
            lblSelectMember.trailingAnchor.constraint(equalTo: tableHeaderContainer.trailingAnchor, constant: -20),
            
            txtMember.topAnchor.constraint(equalTo: lblSelectMember.bottomAnchor, constant: 10),
            txtMember.leadingAnchor.constraint(equalTo: lblSelectMember.leadingAnchor),
            txtMember.trailingAnchor.constraint(equalTo: lblSelectMember.trailingAnchor),
            txtMember.heightAnchor.constraint(equalToConstant: 45),
            
            btnClear.centerYAnchor.constraint(equalTo: txtMember.centerYAnchor),
            btnClear.trailingAnchor.constraint(equalTo: txtMember.trailingAnchor, constant: -10),
            btnClear.widthAnchor.constraint(equalToConstant: 20),
            btnClear.heightAnchor.constraint(equalToConstant: 20),
            
            vwInfo.topAnchor.constraint(equalTo: txtMember.bottomAnchor, constant: 10),
            vwInfo.leadingAnchor.constraint(equalTo: txtMember.leadingAnchor),
            vwInfo.trailingAnchor.constraint(equalTo: txtMember.trailingAnchor),
            vwInfo.heightAnchor.constraint(equalToConstant: 65),
            
            healthRiskScoreView.topAnchor.constraint(equalTo: vwInfo.bottomAnchor, constant: 14),
            healthRiskScoreView.leadingAnchor.constraint(equalTo: tableHeaderContainer.leadingAnchor, constant: 20),
            healthRiskScoreView.trailingAnchor.constraint(equalTo: tableHeaderContainer.trailingAnchor, constant: -20),
            
            doctorsTop,
            recommendedDoctorsView.leadingAnchor.constraint(equalTo: tableHeaderContainer.leadingAnchor, constant: 20),
            recommendedDoctorsView.trailingAnchor.constraint(equalTo: tableHeaderContainer.trailingAnchor, constant: -20),
            doctorsHeight,
            recommendedDoctorsView.bottomAnchor.constraint(equalTo: tableHeaderContainer.bottomAnchor, constant: -8)
        ])
        
        tblHealth.translatesAutoresizingMaskIntoConstraints = false
        vwConsent.translatesAutoresizingMaskIntoConstraints = false
        btnViewHealth.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tblHealth.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tblHealth.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tblHealth.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tblHealth.bottomAnchor.constraint(equalTo: vwConsent.topAnchor, constant: -8),
            
            vwConsent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            vwConsent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            vwConsent.bottomAnchor.constraint(equalTo: btnViewHealth.topAnchor, constant: -10),
            
            btnViewHealth.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            btnViewHealth.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            btnViewHealth.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        tblHealth.alwaysBounceVertical = true
        
        // Size once after bounds are ready — do NOT resize from viewDidLayoutSubviews.
        DispatchQueue.main.async { [weak self] in
            self?.sizeTableHeaderIfNeeded(force: true)
        }
    }
    
    private func sizeTableHeaderIfNeeded(force: Bool = false) {
        guard !isUpdatingTableHeader else { return }
        let targetWidth = tblHealth.bounds.width
        guard targetWidth > 1 else { return }
        if !force,
           abs(targetWidth - lastSizedHeaderWidth) < 0.5,
           tblHealth.tableHeaderView === tableHeaderContainer {
            return
        }
        
        isUpdatingTableHeader = true
        defer { isUpdatingTableHeader = false }
        lastSizedHeaderWidth = targetWidth
        
        // Prefer fixed content height for meter (+ suggested doctors when present).
        let doctorsBlockHeight: CGFloat = recommendedDoctorsView.isHidden
            ? 0
            : (16 + HealthCheckRecommendedDoctorsView.preferredHeight)
        let headerHeight: CGFloat = 10 + 18 + 10 + 45 + 10 + 65 + 14
            + HealthRiskScoreView.preferredHeight
            + doctorsBlockHeight + 8
        
        tableHeaderContainer.translatesAutoresizingMaskIntoConstraints = true
        tableHeaderContainer.frame = CGRect(x: 0, y: 0, width: targetWidth, height: headerHeight)
        tblHealth.tableHeaderView = tableHeaderContainer
    }
    
    private func applySuggestedDoctors(from gaugeData: HealthRiskScoreData) {
        let doctors = gaugeData.suggestedDoctors
        recommendedDoctorsView.configure(doctors: doctors)
        recommendedDoctorsHeightConstraint?.constant = doctors.isEmpty
            ? 0
            : HealthCheckRecommendedDoctorsView.preferredHeight
        recommendedDoctorsTopConstraint?.constant = doctors.isEmpty ? 0 : 16
        sizeTableHeaderIfNeeded(force: true)
    }
    
    //MARK: Functions
    func getHealthData(memberId: Int?){
        showLoadingView("")
        let endPoint = Constants.URLs.getHealthCheckHistory
        GetHealthCheckHistoryService().getData(memberID: currentMemberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? HealthCheckReponseModel {
                    self.arrData = data.arrData
                    isAggrementCheck = data.healthConsentInfo.consentGiven
                    let imageName = isAggrementCheck ? "iconCheck" : "uncheck"
                    btnAgree.setImage(UIImage(named: imageName), for: .normal)
                    tblHealth.reloadData()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func getHealthRiskGauge(animated: Bool) {
        let endPoint = Constants.URLs.getHealthRiskScoreGauge
        GetHealthRiskScoreService().getData(memberID: currentMemberID, apiEndPoint: endPoint, completion: { (response) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let data = response as? HealthRiskScoreResponseModel {
                    self.latestGaugeData = data.data
                    self.healthRiskScoreView.configure(with: data.data, animated: animated)
                    self.applySuggestedDoctors(from: data.data)
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                // Keep silent on gauge errors so health history still works; log for debug.
                print("Health risk gauge error: \(failure ?? "")")
            }
        }
    }
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        txtMember.delegate = self
        txtMember.inputView = pickerView
        txtMember.inputAccessoryView = toolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    
    @objc func doneTapped() {
        let row = pickerView.selectedRow(inComponent: 0)
        txtMember.text = arrMember[row].firstName + " " + arrMember[row].lastName
        currentMemberID = row == 0 ? nil : arrMember[row].id
        txtMember.resignFirstResponder()
        getHealthData(memberId: currentMemberID)
        getHealthRiskGauge(animated: true)
        btnClear.isUserInteractionEnabled = false
        currentSelectedName = row == 0 ? accountUserName : txtMember.text!
    }
     
    @objc func cancelTapped() {
        txtMember.resignFirstResponder()
    }
    
    func getMembers(){
        showLoadingView("")
        GetMemberService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                
                if let data = response as? MemberReponseModel {
                    self.arrMember = data.arrMembers
                    var adminUser = MemberDetailModel()
                    adminUser.firstName = accountUserName
                    adminUser.lastName = "(Self)"
                    adminUser.relationship = "Self"
                    arrMember.insert(adminUser, at: 0)
                    pickerView.reloadAllComponents()
                    getHealthData(memberId: currentMemberID)
                    getHealthRiskGauge(animated: true)
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    func saveHealthConsent(){
        let param: [String: Any] = [
            "consent_type" : "share_medical_info",
            "consent_given" : isAggrementCheck,
        ]
        let endPoint = Constants.URLs.saveHealthConsent
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel {
                    showToast(message: data.message, controller: self)
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnViewHealthAction(_ sender: Any) {
        let nextVC = getAllHealthCheckVC()
        nextVC.memberID = currentMemberID
        nextVC.currentUserName = currentSelectedName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnFindDoctorAction(_ sender: Any) {
        let nextVC = getFindDoctorVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        let nextVC = DoctorVC.getLoginVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnClearAction(_ sender: UIButton) {
        txtMember.text = ""
        currentMemberID = nil
        currentSelectedName = accountUserName
        getHealthData(memberId: currentMemberID)
        getHealthRiskGauge(animated: true)
        btnClear.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        btnClear.isUserInteractionEnabled = false
    }
    
    @IBAction func btnAgreeAction(_ sender: Any) {
        isAggrementCheck.toggle()
        let imageName = isAggrementCheck ? "iconCheck" : "uncheck"
        btnAgree.setImage(UIImage(named: imageName), for: .normal)
        saveHealthConsent()
    }
    
    @IBAction func btnViewPolicyAction(_ sender: Any) {
    }
}

extension HealthCheckVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthCheckTCell") as! HealthCheckTCell
        cell.setData(item: arrData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrData[indexPath.row]

        switch item.id {
        case 1:
            let nextVC = getMedicalHistoryVC()
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 2:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .surgicalHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 3:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .allergyHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 4:
            let nextVC = getAddedMedicationVC()
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 5:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .familyHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        case 6:
            let nextVC = getSurgicalHistoryVC()
            nextVC.histrotyType = .socialHistory
            nextVC.memberID = currentMemberID
            nextVC.currentUserName = currentSelectedName
            navigationController?.pushViewController(nextVC, animated: true)

        default:
            break
        }
    }
}

extension HealthCheckVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrMember.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arrMember[row].firstName) \(arrMember[row].lastName)"
    }
}

extension HealthCheckVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtMember {
            return false
        }
        return true
    }
}

extension HealthCheckVC: HealthCheckRecommendedDoctorsViewDelegate {
    func recommendedDoctorsViewDidSelectDoctor(_ doctor: RecommendedDoctorModel) {
        let nextVC = HomeVC.getDoctorDetailVC()
        nextVC.providerID = doctor.id
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

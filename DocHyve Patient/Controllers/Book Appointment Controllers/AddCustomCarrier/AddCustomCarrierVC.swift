//
//  AddCustomCarrierVC.swift
//  DocHyve
//
//  Created by MeshSq on 18/06/2026.
//

import UIKit
import Combine
import TagListView

class AddCustomCarrierVC: ParentViewController {

    @IBOutlet weak var txtState: AuthTextField!
    @IBOutlet weak var tagSelectedState: TagListView!
    @IBOutlet weak var txtCarrierName: AuthTextField!
    @IBOutlet weak var txtInsuranceType: AuthTextField!
    @IBOutlet weak var txtPlan: AuthTextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var widthBtnAdd: NSLayoutConstraint!
    
    @IBOutlet weak var tagSelectedPlan: TagListView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    var selectedStatesIds = [Int]()
    private var cancellables = Set<AnyCancellable>()
    
    private var vm = AddCustomCarrierViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPlan.delegate = self
        txtCarrierName.delegate = self
        
        addButton(show: false)
        checkStateTag()
        
        
        
        
        txtInsuranceType.setPickerInput { [weak self] in
            self?.vm.type.count ?? 0
        } title: {  [weak self] row in
            self?.vm.type[row] ?? ""
        } didSelect: { row in
            
        } onDone: { [weak self] in
            let picker = self?.txtInsuranceType.inputView as! UIPickerView
            let row = picker.selectedRow(inComponent: 0)
            self?.vm.insuranceType =  self?.vm.type[row] ?? ""
            self?.txtInsuranceType.text = self?.vm.type[row] ?? ""
            self?.txtInsuranceType.resignFirstResponder()
            self?.vm.isEnable()
        } onCancel: { [weak self] in
            self?.txtInsuranceType.resignFirstResponder()
        }
        
        tagSelectedPlan.delegate = self
        tagSelectedState.delegate = self
        tagSelectedPlan.enableRemoveButton = true
        tagSelectedState.enableRemoveButton = true
        
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                output ? self?.showLoadingView("") : self?.removeLoadingView()
            }
            .store(in: &cancellables)
        
        vm.$plans
            .receive(on: DispatchQueue.main)
            .sink { [weak self] plans in
                self?.tagSelectedPlan.removeAllTags()
                for plan in (self?.vm.plans ?? []) {
                    self?.tagSelectedPlan.addTag(plan)
                }
                self?.vm.isEnable()
            }
            .store(in: &cancellables)
        
        vm.$isEnableButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnable in
                self?.btnSubmit.set(isEnable: isEnable)
            }
            .store(in: &cancellables)
        
        vm.$isSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSussess in
                guard isSussess else {return}
                self?.alert(title: self?.vm.title, message: self?.vm.message) { [weak self] in
                    self?.popController()
                }
            }
            .store(in: &cancellables)
        
        vm.$message
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                self?.showAlertView(title: "Error", message: msg)
            }
            .store(in: &cancellables)
        
        
        
        vm.getData()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        popController()
    }
    
    @IBAction func btnStateAction(_ sender: Any) {
        let vc = BottomSheetMultiSelectionVC()
        vc.fromBottom()
        vc.type = .state
        vc.isMultiSelection = false
        vc.states = vm.states
        vc.arrSelectedIndex = vm.selectedSateIds
        vc.handler = { arrSelectedIndex in
            DispatchQueue.main.async { [weak self] in
                self?.tagSelectedState.removeAllTags()
                self?.vm.selectedSateIds = arrSelectedIndex
                arrSelectedIndex.forEach { index in
                    if let state = self?.vm.states.first(where: { $0.id == index }) {
                        self?.tagSelectedState.addTag(state.name ?? "")
                    }
                }
                self?.txtState.placeholder = arrSelectedIndex.count > 0 ? "" : "Select State"
                self?.vm.isEnable()
                self?.checkStateTag()
            }
        }
        present(vc, animated: true)
    }
 
    
    @IBAction func btnAddPlanAction(_ sender: Any) {
        if let text = txtPlan.text, !text.isEmpty {
            vm.plans.append(text)
            txtPlan.text = ""
        }
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        vm.submit()
    }
    
    private func addButton(show: Bool) {
        widthBtnAdd.constant = show ? 60 : 0
        btnAdd.alpha = show ? 1 : 0
        animateView()
    }
    
    private func checkStateTag() {
        tagSelectedState.isUserInteractionEnabled = !vm.selectedSateIds.isEmpty
    }

}

extension AddCustomCarrierVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtPlan {
            addButton(show: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtPlan {
            addButton(show: false)
        } else if textField == txtCarrierName {
            vm.carrierName = textField.text ?? ""
        } else if textField == txtInsuranceType {
            vm.insuranceType = textField.text ?? ""
        }
        vm.isEnable()
    }
    
}


extension AddCustomCarrierVC: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("tagPressed \(title)")
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("tagRemoveButtonPressed \(title)")
        if sender == tagSelectedPlan {
            if let index = vm.plans.firstIndex(where: { $0 == title }) {
                vm.plans.remove(at: index)
                tagSelectedPlan.removeTag(title)
            }
        } else if sender == tagSelectedState {
            vm.selectedSateIds.removeAll()
            tagSelectedState.removeAllTags()
            checkStateTag()
        }
    }
    
    func showAlertView(title: String? = nil, message: String) {
        
        let alertController = UIAlertController(title: title ?? Constants.GenericStrings.alertTitle, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.GenericStrings.ok, style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

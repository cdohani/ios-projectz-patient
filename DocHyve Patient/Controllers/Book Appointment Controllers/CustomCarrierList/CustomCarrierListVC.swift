//
//  CustomCarrierListVC.swift
//  DocHyve
//
//  Created by MeshSq on 23/06/2026.
//

import UIKit
import SwiftUI
import Combine

class CustomCarrierListVC: ParentViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var vm = CustomCarrierListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register("CellTBCustomCarrier")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setViewModel()
    }

    @IBAction func btnAddBack(_ sender: Any) {
        push(getAddCustomCarrierVC())
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func setViewModel() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoadingView("") : self?.removeLoadingView()
            }
            .store(in: &cancellables)
        
        vm.$customCarriers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        vm.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message {
                    self?.showAlertView(message: message)
                }
            }
            .store(in: &cancellables)
        
        vm.getData()
    }
    
    
}

extension CustomCarrierListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        (vm.customCarriers?.count == 0) ? tableView.setEmptyView(image: .nodata) : tableView.restoreEmptyView()
        return vm.customCarriers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellTBCustomCarrier", for: indexPath) as? CellTBCustomCarrier else {  return UITableViewCell() }
        cell.data = vm.customCarriers?[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height - 100 {
            guard !vm.isLoading else { return }
            if vm.pagination?.has_more_pages == true {
               vm.getData()
            }
        }
    }
    
    
}

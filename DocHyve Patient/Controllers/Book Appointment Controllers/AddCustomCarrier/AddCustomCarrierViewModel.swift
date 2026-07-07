//
//  AddCustomCarrierViewModel.swift
//  DocHyve
//
//  Created by MeshSq on 18/06/2026.
//

import Combine
import Foundation

final class AddCustomCarrierViewModel: ObservableObject {

    @Published var states: [CountryState] = []
    @Published var selectedSateIds: [Int] = []
    
    var carrierName = ""
    var insuranceType = ""
    @Published var plans : [String] = []
    
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var title: String?
    @Published var message: String?
    @Published var isEnableButton = false

    var type = ["Medical", "Dental", "Vision"]

    //@Published var serviceTypeSelected: ServiceTypes?
    

    func getData() {
        isLoading = true
        Task {
            do {
                let response: GenericAPIResponse<StateResponse> = try await APIService.shared.get(endpoint: Constants.URLs.getStates)
                await MainActor.run { [weak self] in
                    self?.states = response.data?.states ?? []
                    self?.isLoading = false
                }
            } catch let error {
                await MainActor.run { [weak self] in
                    self?.message = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    func isEnable() {
        isEnableButton = !carrierName.isEmpty && !plans.isEmpty && !selectedSateIds.isEmpty
    }
    
    func submit() {
        Task {
            let params = [
                "plans": plans,
                "insurance_name": carrierName,
                "insurance_type": insuranceType,
                "state_id": selectedSateIds.compactMap({ String($0) }).joined(separator: ", "),
            ]
            do {
                let response: GenericAPIResponse<EmptyBody> = try await APIService.shared.post(endpoint: Constants.URLs.customInsuranceRequest, body: params)
                await MainActor.run { [weak self] in
                    if response.status == 201 {
                        self?.isSuccess = true
                    }
                    self?.title = response.status == 201 ? "Success" : "Error"
                    self?.message = response.message
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.title = "Error"
                    self?.message = error.localizedDescription
                }
            }
        }
    }

    
}


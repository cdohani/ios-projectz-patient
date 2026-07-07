//
//  CustomCarrierListViewModel.swift
//  DocHyve
//
//  Created by MeshSq on 23/06/2026.
//

import Combine
import Foundation

final class CustomCarrierListViewModel: ObservableObject {
    
    
    @Published var customCarriers: [CustomCarrier]?
    @Published var pagination: Pagination?
    
    @Published var isLoading = false
    @Published var isLoadingMore = false
    
    
    @Published var title: String?
    @Published var message: String?
    @Published var isEnableButton = false

    
    func getData() {
        var currentPage = pagination?.current_page ?? 0
        currentPage += 1
        isLoading = true
        Task {
            let model: GenericAPIResponse<CustomCarrierResponse> = try await APIService.shared.get(endpoint: Constants.URLs.customInsuranceList, queryItems: ["per_page": 30, "page" : currentPage])
            await MainActor.run { [weak self] in
                self?.pagination = model.data?.pagination
                if let customCarriers = model.data?.data {
                    if self?.customCarriers?.count ?? 0 == 0 {
                        self?.customCarriers = customCarriers
                    } else {
                        for item in customCarriers {
                            if self?.customCarriers?.first(where: { $0.id == item.id }) == nil {
                                self?.customCarriers?.append(item)
                            }
                        }
                    }
                } else {
                    self?.message = model.message ?? ""
                }
                self?.isLoading = false
            }
        }
    }
    
}


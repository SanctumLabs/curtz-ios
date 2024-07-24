//
//  DashboardViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 22/07/2024.
//

import Foundation
import Curtz

enum DashboardViewState {
    case loading
    case loaded([ShortenedURL])
    case hasError(Error)
}


extension DashboardViewModel {
    @objc func didTapRefresh() {
        getAllShortenedUrls()
    }
    
    @objc func didTapAdd() {
        print("I am adding")
    }
}

final class DashboardViewModel: ObservableObject {
    
    @Published var state: DashboardViewState = .loading
    
    private let coreService: CoreService
    
    init(coreService: CoreService) {
        self.coreService = coreService
    }
    
    func load() {
        getAllShortenedUrls()
    }
    
    private func getAllShortenedUrls() {
        state = .loading
        coreService.fetchAll { result in
            switch result  {
            case let .success(responseItems):
                DispatchQueue.main.async {[weak self] in
                    self?.state = .loaded(responseItems.map {$0.asShortenedURL()})
                }
            case let .failure(error):
                DispatchQueue.main.async {[weak self] in
                    self?.state = .hasError(error)
                }
            }
        }
    }
}

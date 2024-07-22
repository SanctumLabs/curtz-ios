//
//  DashboardViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 22/07/2024.
//

import Foundation
import Curtz

protocol DashboardViewDelegate {
    
}

enum DashboardViewState {
    case idle
    case loaded([ShortenedURL])
    case hasError(Error)
}

final class DashboardViewModel: ObservableObject {
    
    @Published var state: DashboardViewState = .idle
    
    private let coreService: CoreService
    private let delegate: DashboardViewDelegate
    
    init(coreService: CoreService, delegate: DashboardViewDelegate) {
        self.coreService = coreService
        self.delegate = delegate
    }
    
    func getAllShortenedUrls() {
        
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

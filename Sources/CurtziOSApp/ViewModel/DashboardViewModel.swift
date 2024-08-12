//
//  DashboardViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 22/07/2024.
//

import Foundation
import Curtz
import UIKit

enum DashboardViewState {
    case loading
    case loaded([ShortenedURL])
    case hasError(Error)
}

protocol DashboardViewDelegate {
    func didTapAddNewLink()
    func didFinishAddNewLink()
    func didTapLink(id: String, shortenedURL: ShortenedURL)
}


extension DashboardViewModel {
    @objc func didTapRefresh() {
        getAllShortenedUrls()
    }
    
    @objc func didTapAdd() {
        delegate?.didTapAddNewLink()
    }
}

final class DashboardViewModel: ObservableObject {
    
    @Published var state: DashboardViewState = .loading
    
    private let coreService: CoreService
    var delegate: DashboardViewDelegate? = nil
    var didTapEdit: ((UINavigationController) -> Void)?
    
    init(coreService: CoreService) {
        self.coreService = coreService
    }
    
    func load() {
        getAllShortenedUrls()
    }
    
    func delete(_ shortedURL: ShortenedURL) {
        coreService.deleteURL(with: shortedURL.id) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                DispatchQueue.main.async {[weak self] in
                    self?.state = .hasError(error.localizedDescription)
                }
            }
        }
    }
    
    func edit(_ shortedURL: ShortenedURL) {
        delegate?.didTapLink(id: shortedURL.id, shortenedURL: shortedURL)
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

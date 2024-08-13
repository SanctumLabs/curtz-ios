//
//  LinkDetailsViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 07/08/2024.
//

import Foundation
import Combine
import Curtz

enum LinkDetailsViewState {
    case processing
    case idle
    case editing
    case hasError
}

extension LinkDetailsViewState: Equatable {}

struct LinkDetailsFormState {
    var id: String
    var originalUrl: String
    var customAlias: String
    var expiryDate: Date
    init(id: String, originalUrl: String, customAlias: String, expiryDate: Date) {
        self.id = id
        self.originalUrl = originalUrl
        self.customAlias = customAlias
        self.expiryDate = expiryDate
    }
    
    init(_ shortenedURL: ShortenedURL) {
        self.id = shortenedURL.id
        self.originalUrl = shortenedURL.url
        self.customAlias = shortenedURL.alias
        self.expiryDate = shortenedURL.expiresOn.toISODate()
        
    }
    
    func isEmpty() -> Bool {
        originalUrl.isEmpty && customAlias.isEmpty
    }
}

extension String {
    func toISODate() -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self) ?? .now
    }
}

final class LinkDetailsViewModel: ObservableObject {
    var delegate: LinkDetailsDelegate?
    @Published var viewState: LinkDetailsViewState = .idle
    @Published var formState: LinkDetailsFormState
    @Published var showSuccessSheet: Bool = false
    
    private var service: CoreService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: CoreService, shortenedURL: ShortenedURL) {
        self.service = service
        self.formState = LinkDetailsFormState(shortenedURL)
    }
    
    func tapClose() {
        delegate?.didFinishTapped()
    }
    
    func tapEdit() {
        viewState = .editing
    }
    
    func cancelEdit() {
        viewState = .idle
    }
    
    func save(){
        viewState = .processing
        let editLinkRequest = URLEditRequest(
            customAlias: formState.customAlias,
            expiresOn: formState.expiryDate.ISO8601Format()
        )
        
        service.editURL(with: formState.id, urlEditRequest: editLinkRequest) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .idle
                    self?.showSuccessSheet = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                    self?.showSuccessSheet = false
                }
            case let .failure(error):
                dump(error)
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .hasError
                }
            }
        }
    }
}


//
/*
 Show success notifications
 */

//
//  EditLinkViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 07/08/2024.
//

import Foundation
import Combine
import Curtz

enum EditLinkViewState {
    case processing
    case idle
    case hasError
}

extension EditLinkViewState: Equatable {}

struct EditLinkFormState {
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

final class EditLinkViewModel: ObservableObject {
    var delegate: EditLinkDelegate?
    @Published var viewState: EditLinkViewState = .idle
    @Published var formState: EditLinkFormState
    @Published var showSuccessSheet: Bool = false
    
    private var service: CoreService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: CoreService, shortenedURL: ShortenedURL) {
        self.service = service
        self.formState = EditLinkFormState(shortenedURL)
    }
    
    func tapClose() {
        delegate?.didFinishEditingLink()
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

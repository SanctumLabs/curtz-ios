//
//  EditLinkViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 07/08/2024.
//

import Foundation
import Curtz

enum EditLinkViewState {
    case processing
    case idle
    case hasError
}

struct EditLinkFormState {
    var id: String
    var originalUrl: String
    var customAlias: String
    var expiryDate: Date
    var keyWords: String
    init(id: String, originalUrl: String, customAlias: String, expiryDate: Date, keyWords: String) {
        self.id = id
        self.originalUrl = originalUrl
        self.customAlias = customAlias
        self.expiryDate = expiryDate
        self.keyWords = keyWords
    }
    
    func isEmpty() -> Bool {
        originalUrl.isEmpty && customAlias.isEmpty && keyWords.isEmpty
    }
}

final class EditLinkViewModel: ObservableObject {
    var delegate: EditLinkDelegate?
    @Published var viewState: EditLinkViewState = .idle
    @Published var formState: EditLinkFormState
    @Published var showSuccessSheet: Bool = false
    
    private var service: CoreService
    
    init(service: CoreService, formState:EditLinkFormState ) {
        self.formState = formState
        self.service = service
    }
    
    func tapClose() {
        delegate?.didTapClose()
    }
    
    func save(){
        viewState = .processing
        let editLinkRequest = URLEditRequest(customAlias: formState.customAlias, keywords: formState.keyWords.components(separatedBy: .whitespaces), expiresOn: formState.expiryDate.ISO8601Format())
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
            case .failure:
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .hasError
                }
            }
        }
    }
}

//
//  AddNewLinkViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 30/07/2024.
//

import Foundation
import Curtz

enum AddNewLinkViewState {
    case processing
    case idle
    case hasError
}


final class AddNewLinkViewModel: ObservableObject{
    var delegate: AddNewLinkDelegate?
    @Published var viewState: AddNewLinkViewState = .idle
    @Published var formState: AddNewLinkFormState = .init()
    @Published var showSuccessSheet: Bool = false
    @Published var showConfirmationSheet: Bool = false
    private var service: CoreService
    
    init(coreService: CoreService) {
        self.service = coreService
    }
    
    func tapClose() {
        // Check if state is empty before proceeding
        if formState.isEmpty() {
            delegate?.didTapClose()
        } else {
            // show alert
            showConfirmationSheet = true
        }
    }
    
    func closeConfirmed() {
        showConfirmationSheet = false
        delegate?.didTapClose()
    }
    
    func clearAll() {
        formState = .init()
    }
    
    func save(_ formState: AddNewLinkFormState){
        viewState = .processing
        let shortenRequest = ShortenRequest(originalUrl: formState.originalUrl, customAlias: formState.customAlias, keywords: formState.keyWords.components(separatedBy: .whitespaces), expiresOn: formState.expiryDate.ISO8601Format())
        
        service.shorten(shortenRequest) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .idle
                    self?.clearAll()
                    self?.showSuccessSheet.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                    self?.showSuccessSheet.toggle()
                }
                
            case let .failure(error):
                DispatchQueue.main.async {[weak self] in
                    print(error.localizedDescription)
                    self?.viewState = .hasError
                }
            }
        }
        
    }
}

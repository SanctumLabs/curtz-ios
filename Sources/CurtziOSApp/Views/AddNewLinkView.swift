//
//  AddNewLinkView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 30/07/2024.
//

import SwiftUI

protocol AddNewLinkDelegate {
    func didTapClose()
}

final class AddNewLinkViewModel: ObservableObject{
    var delegate: AddNewLinkDelegate?
    
    func tapClose() {
        delegate?.didTapClose()
    }
}

struct AddNewLinkView: View {
    @ObservedObject var vm: AddNewLinkViewModel
    @State var formState: FormState = .init()
    
    init(vm: AddNewLinkViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            navigationBar()
            addNewLinkForm()
            Spacer()
        }
    }
}
//"original_url": "http://example.com/please/shortenme",
//  "custom_alias": "shortenme",
//  "expires_on": "2022-08-12T17:18:18.553Z",
//  "keywords": [
//    "string"
//  ]

struct FormState {
    var originalUrl: String = ""
    var customAlias: String = ""
    var expiryDate: Date = .now
    var keyWords: String = ""
}

// MARK: - form
extension AddNewLinkView {
    @ViewBuilder
    private func addNewLinkForm() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Original url")
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Original url", text: $formState.originalUrl)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            
            VStack(alignment: .leading) {
                Text("Custom alias")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Custom alias", text: $formState.customAlias)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            
            VStack(alignment: .leading) {
                Text("Keywords")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Keywords", text: $formState.keyWords)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            DatePicker("Expiry date", selection: $formState.expiryDate)
        }
        .padding()
    }
}

// MARK: - navigationBar
extension AddNewLinkView {
    @ViewBuilder
    private func navigationBar() -> some View {
        HStack(alignment: .center) {
            Button {
                vm.tapClose()
            } label: {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
            Spacer()
            Text("Add new link")
            Spacer()
            Button {
                vm.tapClose()
            } label: {
                Image(systemName: "trash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
        .padding([.leading, .trailing, .top], 18)
    }
}

#Preview {
    AddNewLinkView(vm: AddNewLinkViewModel())
}

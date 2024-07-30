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

struct AddNewLinkView: View {
    @ObservedObject var vm: AddNewLinkViewModel
    
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

struct AddNewLinkFormState {
    var originalUrl: String = ""
    var customAlias: String = ""
    var expiryDate: Date = Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now
    var keyWords: String = ""
    
    func isEmpty() -> Bool {
        originalUrl.isEmpty && customAlias.isEmpty && keyWords.isEmpty
    }
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
                    TextField("Original url", text: $vm.formState.originalUrl)
                        .textInputAutocapitalization(.never)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            
            VStack(alignment: .leading) {
                Text("Custom alias")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Custom alias", text: $vm.formState.customAlias)
                        .textInputAutocapitalization(.never)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            
            VStack(alignment: .leading) {
                Text("Keywords")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Keywords", text: $vm.formState.keyWords)
                        .textInputAutocapitalization(.never)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            DatePicker("Expiry date", selection: $vm.formState.expiryDate)
                .padding([.bottom], 24)
            Button(action: {
                vm.save(vm.formState)
            }, label: {
                if vm.viewState == .processing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Text("Save")
                        .font(.headline)
                }
            })
            .frame(width: 360, height: 50)
            .background(vm.viewState == .processing || vm.formState.originalUrl.isEmpty ? .gray : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .sheet(isPresented: $vm.showSuccessSheet, content: {
            successView()
        })
        .confirmationDialog(
            Text("Navigation"),
            isPresented: $vm.showConfirmationSheet
        ) {
            Button("Yes", role: .destructive) {
                vm.closeConfirmed()
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("Your form is not empty. Are you sure you want to proceed")
        }
    }
}

extension AddNewLinkView {
    @ViewBuilder
    private func successView() -> some View {
        if #available(iOS 16.0, *) {
            VStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundStyle(.green)
                Text("Hooray! Your link has been created")
                    .font(.title2)
                Text("Time to share it with the world")
                    .font(.callout)
            }
            .padding()
            .presentationDetents([.height(120)])
        }
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
                vm.clearAll()
            } label: {
                Image(systemName: "trash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(vm.formState.isEmpty() ? .gray : .blue)
            }
        }
        .padding([.leading, .trailing, .top], 18)
    }
}

//#Preview {
////    AddNewLinkView(vm: AddNewLinkViewModel())
//}

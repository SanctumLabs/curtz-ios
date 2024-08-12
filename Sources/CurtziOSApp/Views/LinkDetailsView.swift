//
//  LinkDetailsView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 07/08/2024.
//

import SwiftUI

protocol LinkDetailsDelegate {
    func didFinishTapped()
}

struct LinkDetailsView: View {
    @ObservedObject var vm: LinkDetailsViewModel
    
    init(vm: LinkDetailsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        navigationBar()
        editLinkForm()
        Spacer()
    }
    
    // MARK: - NavigationBar
    @ViewBuilder
    private func navigationBar() -> some View {
        HStack(alignment: .center, content: {
            Button {
                vm.tapClose()
            } label: {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
            Spacer()
            Text("Edit link")
            Spacer()
        })
        .padding([.horizontal], 18)
    }
    
    // MARK: - EditLinkForm
    @ViewBuilder
    private func editLinkForm() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Original url")
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Original url", text: $vm.formState.originalUrl)
                        .textInputAutocapitalization(.never)
                        .disabled(true)
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
                        .disabled(vm.viewState == .processing)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            DatePicker("Expiry date", selection: $vm.formState.expiryDate)
                .padding([.bottom], 24)
                .disabled(vm.viewState == .processing)
            Button(action: {
                vm.save()
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
            .background(vm.viewState == .processing || $vm.formState.expiryDate.wrappedValue < .now ? .gray : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled($vm.formState.expiryDate.wrappedValue < .now)
        }
        .padding()
        
    }
    
    // MARK: - SuccessView
    @ViewBuilder
    private func successView() -> some View {
        if #available(iOS 16.0, *) {
            VStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundStyle(.green)
                Text("Hooray! Your link has been updated")
                    .font(.title2)
                Text("Time to share it with the world")
                    .font(.callout)
            }
            .padding()
            .presentationDetents([.height(120)])
        }
    }
}

//#Preview {
//    EditLinkView()
//}

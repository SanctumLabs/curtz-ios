//
//  LinkDetailsView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 07/08/2024.
//

import SwiftUI

struct LinkDetailsView: View {
    @ObservedObject var vm: LinkDetailsViewModel
    
    init(vm: LinkDetailsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        navigationBar()
        if vm.viewState == .editing {
            editLinkForm()
        } else {
            detailsView()
        }
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
            Text(vm.viewState == .editing ? "Edit link" : "Link details")
            Spacer()
            if vm.viewState == .editing {
                Button {
                    vm.cancelEdit()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
                .disabled(vm.viewState == .processing)
            } else {
                Button {
                    vm.tapEdit()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }.disabled(vm.viewState == .processing)
            }
            
        })
        .padding([.horizontal], 18)
    }
    // MARK: - DetailsView
    @ViewBuilder
    private func detailsView() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Original URL")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.originalUrl)
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Custom alias")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.customAlias)
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Creation Date")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.createdAt.formatted())
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Expiry date")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.expiryDate.formatted())
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Short Code")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.shortCode)
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Keywords")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.keywords.joined(separator: " "))
            }
            .padding([.vertical], 8)
            
            VStack(alignment: .leading) {
                Text("Hits")
                    .font(.footnote)
                    .opacity(0.5)
                Text(vm.formState.hits.formatted())
            }
            .padding([.vertical], 8)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
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
                        .autocorrectionDisabled()
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
        .sheet(isPresented: $vm.showSuccessSheet, content: {
            successView()
        })
        
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

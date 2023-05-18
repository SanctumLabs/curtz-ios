//
//  DashboardView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 13/04/2023.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    @State private var successFullyLogout = false
    
    let urls: [CurtzURL] = [CurtzURL(id: "cbujla6g26udrae2rez", originalUrl: "http://georgenyakundi.com", customAlias: "", expiresOn: Date(timeIntervalSince1970: 1598627222), keywords: [], userId: "", shortCode: "blw94Z", createdAt: Date(timeIntervalSince1970: 1598627222), updatedAt: Date(timeIntervalSince1970: 1598627222), hits: 1)]
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                List {
                    ForEach(urls, id: \.id) { url in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Short Code: \(url.shortCode)")
                                Spacer()
                                Text("Hits: \(url.hits)")
                                    .font(.title)
                            }.padding([.top])
                            Text("Expires on: \(url.expiresOn.formatted())")
                                .padding([.top, .bottom])
                            Text("Original URL:\(url.originalUrl)")
                                .font(.footnote)
                            Text("Created: \(url.createdAt.formatted())")
                                .font(.footnote)
                            Text("Updated: \(url.updatedAt.formatted())")
                                .font(.footnote)
                        }
                        .padding([.bottom])
                    }
                }
            }
            
            Button("Logout") {
                vm.logout()
                successFullyLogout = true
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            // Floating button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {}, label: {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.system(.largeTitle))
//                            .padding()
//                    })
//                    .padding([.trailing])
//                }
//            }
        }
        .navigationTitle("Dashboard")
        .navigate(to: LoginView(), when: $successFullyLogout)
       
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
    }
}

struct CurtzURL: Equatable {
    let id: String
    let originalUrl: String
    let customAlias: String
    let expiresOn: Date
    let keywords: [String]
    let userId: String
    let shortCode: String
    let createdAt: Date
    let updatedAt: Date
    let hits: Int
}

extension DashboardView_Previews {
    
    static func sampleUrls() -> [CurtzURL] {
        let dummyCurtzUrl = CurtzURL(id: "cbujla6g26udrae2rez", originalUrl: "http://georgenyakundi.com", customAlias: "", expiresOn: Date(timeIntervalSince1970: 1598627222), keywords: [], userId: "", shortCode: "blw94Z", createdAt: Date(timeIntervalSince1970: 1598627222), updatedAt: Date(timeIntervalSince1970: 1598627222), hits: 1)
        
        return [dummyCurtzUrl]
    }
}

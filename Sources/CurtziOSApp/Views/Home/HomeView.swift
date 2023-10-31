//
//  HomeView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 26/10/2023.
//

import SwiftUI

struct HomeView: View {
    var allLinks = sampleUrls()
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .padding([.leading, .top], 18)
                Spacer()
            }
            
            List {
                ForEach(allLinks, id: \.id){ link in
                    ListItemView(item: link)
                        .listRowSeparator(.hidden)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(Color.DarkIcon, lineWidth: 0.2)
                        }
                }
            }
            .listStyle(.plain)
        }
    }
}

extension HomeView {
    static func sampleUrls() -> [ListItem] {
        var result = [ListItem]()
        for i in 100..<150 {
            result.append(ListItem(shortCode: "https://bit.ly/scd\(i)", createdAt: "2022/08/08", hits: "\(i)", keywords: ["first", "second", "third", "\(i)"], expiryDate: "2022/08/08"))
        }
        return result
    }
}

struct ListItemView: View {
    @State var item: ListItem
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text("ShortCode")
                        .font(.caption)
                        .foregroundStyle(Color.DarkBackground)
                    Text(item.shortCode)
                        .font(.title2)
                    
                    
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Hits")
                        .font(.bold(.caption)())
                        .foregroundStyle(Color.DarkBackground)
                    Text(item.hits)
                        .font(.title3)
                    
                }
            }
            .padding([.bottom], 8)
            
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text("Expiry date")
                        .font(.caption)
                        .foregroundStyle(Color.DarkBackground)
                    Text(item.expiryDate)
                        .font(.subheadline)
                    
                }
                Spacer()
                HStack {
                    ForEach(item.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption2)
                            .padding([.leading, .trailing], 6)
                            .overlay {
                                Capsule().stroke(Color.DarkBackground, lineWidth: 0.2)
                            }
                    }
                }
            }
        }
        .padding([.all], 1)
    }
}


struct ListItem {
    let id = UUID()
    let shortCode: String
    let createdAt: String
    let hits: String
    let keywords: [String]
    let expiryDate: String
    
    init(shortCode: String = "", createdAt: String = "" , hits: String = "", keywords: [String] = [], expiryDate: String = "" ) {
        self.shortCode = shortCode
        self.createdAt = createdAt
        self.hits = hits
        self.keywords = keywords
        self.expiryDate = expiryDate
    }
}

#Preview {
    HomeView()
}

//
//  DashboardListView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 31/07/2024.
//

import SwiftUI

struct DashboardListView: View {
    @State var items: [ShortenedURL]
    var body: some View {
        List {
            ForEach(items, id: \.id) {item in
                HStack(alignment: .center) {
                    VStack {
                        Text(item.hits.formatted())
                            .font(.headline.bold())
                        Text("Hits")
                            .font(.caption)
                    }
                    .frame(width: 70)
                    VStack(alignment: .leading) {
                        VStack {
                            Text("Short code")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            Text(item.shortCode)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Original URL")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            Text(item.url)
                                .font(.callout)
                        }
                        .padding([.top], 0.3)
                        
                        VStack(alignment: .leading) {
                            Text("Expiry date")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            Text(item.expiresOn)
                                .font(.subheadline)
                        }
                        .padding([.top], 0.5)
                    }
                }
                
            }
        }.listStyle(.plain)
    }
}

func dummyItems() -> [ShortenedURL] {
    [
        .init(id: "1", alias: "apple", url: "https://www.apple.com", expiresOn: Calendar.current.date(byAdding: .day, value: 5, to: .now)?.ISO8601Format() ?? "", keywords: ["apple", "tech", "giant"], shortCode: "3sxs89", createdAt: Date.now.ISO8601Format(), hits: 9),
        .init(id: "2", alias: "facebook", url: "https://www.facebook.com", expiresOn: Calendar.current.date(byAdding: .day, value: 5, to: .now)?.ISO8601Format() ?? "", keywords: ["facebook", "tech", "giant"], shortCode: "3x7s89", createdAt: Date.now.ISO8601Format(), hits: 19)
    ]
}

#Preview {
    DashboardListView(items: dummyItems())
}

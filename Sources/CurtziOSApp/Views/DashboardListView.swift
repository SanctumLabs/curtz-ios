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
                VStack(alignment: .leading) {
                    Text(item.url)
                        .font(.callout)
                    Text(item.shortCode)
                        .font(.title)
                        .padding([.top, .bottom])
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(item.expiresOn)
                                .font(.footnote)
                            Text(item.createdAt)
                                .font(.footnote)
                            HStack {
                                ForEach(item.keywords, id: \.self) {keyword in
                                    Text(keyword)
                                        .font(.footnote)
                                }
                            }
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "\(item.hits.formatted()).circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .foregroundColor(.green)
                        }
                    }
                }.padding()
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

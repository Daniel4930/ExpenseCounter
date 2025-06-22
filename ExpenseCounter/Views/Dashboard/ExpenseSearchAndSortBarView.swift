//
//  ExpenseSearchAndSortBarView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/21/25.
//

import SwiftUI

struct ExpenseSearchAndSortBarView: View {
    @Binding var searchText: String
    @Binding var isAscending: Bool
    
    var body: some View {
        HStack {
            HStack {
                ZStack {
                    if searchText == "" {
                        HStack(spacing: 0) {
                            Image(systemName: "magnifyingglass")
                            Text("Search an expense")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("CustomGrayColor"))
                    }
                    TextField("", text: $searchText)
                        .foregroundStyle(.black)
                }
                Spacer()
                Button {
                    searchText = ""
                    hideKeyboard()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundStyle(Color("CustomGrayColor"))
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            
            Spacer()
            
            Button(action: {
                isAscending.toggle()
            }, label: {
                Image(systemName: "arrow.up")
            })
        }
    }
}

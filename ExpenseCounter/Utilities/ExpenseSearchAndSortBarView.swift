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
    @State private var showPopOver = false
    
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
                showPopOver = true
            }, label: {
                Image(systemName: "arrow.up.arrow.down")
            })
            .popover(isPresented: $showPopOver, attachmentAnchor: .point(.center), arrowEdge: .top) {
                VStack {
                    Button("Newest date") {
                        isAscending = false
                        showPopOver = false
                    }
                    
                    Divider()
                        .frame(height: 10)
                    
                    Button("Oldest date") {
                        isAscending = true
                        showPopOver = false
                    }
                }
                .font(AppFont.customFont(.title3))
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
    }
}

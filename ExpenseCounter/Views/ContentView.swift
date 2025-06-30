//
//  ContentView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

enum Tabs {
    case dashboard
    case settings
    case reports
    case category
}

struct ContentView: View {
    @State private var selectedTab: Tabs = .dashboard
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .settings:
                    Text("Settings")
                case .reports:
                    ReportView()
                case .category:
                    CategoryGridView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                TabbarButton(selectedTab: $selectedTab, tab: Tabs.dashboard, tabIcon: "house", tabTitle: "Home")
//                TabbarButton(selectedTab: $selectedTab, tab: Tabs.reports, tabIcon: "list.bullet.clipboard", tabTitle: "Reports")
                TabbarButton(selectedTab: $selectedTab, tab: Tabs.category, tabIcon: "rectangle.stack", tabTitle: "Category")
//                TabbarButton(selectedTab: $selectedTab, tab: Tabs.settings, tabIcon: "gear", tabTitle: "Settings")
                Spacer()
            }
            .padding(.top)
            .background(.white)
            .overlay (
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color("CustomGrayColor"))
                    .opacity(0.5),
                alignment: .top
            )
        }
        .font(AppFont.customFont())
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabbarButton: View {
    @Binding var selectedTab: Tabs
    let tab: Tabs
    let tabIcon: String
    let tabTitle: String
    
    var body: some View {
        VStack {
            Button(action: {
                selectedTab = tab
            }) {
                VStack {
                    Image(systemName: tabIcon)
                        .foregroundStyle(selectedTab == tab ? Color("CustomGreenColor") : Color("CustomGrayColor"))
                    Text(tabTitle)
                        .font(AppFont.customFont(.subheadline))
                        .foregroundStyle(selectedTab == tab ? Color("CustomGreenColor") : Color("CustomGrayColor"))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

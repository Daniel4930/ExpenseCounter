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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                TabbarButton(selectedTab: $selectedTab, tab: Tabs.dashboard, tabIcon: "house", tabTitle: "Home")
                TabbarButton(selectedTab: $selectedTab, tab: Tabs.settings, tabIcon: "gear", tabTitle: "Settings")
            }
            .padding(.top)
            .background(Color(.systemGray6))
        }
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
                        .foregroundStyle(selectedTab == tab ? Color("MainColor") : .gray)
                    Text(tabTitle)
                        .foregroundStyle(selectedTab == tab ? Color("MainColor") : .gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}

//
//  MainTabView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // First Tab - HomeView
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")  // Home Icon
                Text("Home")
            }

            // Second Tab - Example View
            NavigationView {
                ExampleView1()
            }
            .tabItem {
                Image(systemName: "person.2.fill")  // Second Tab Icon
                Text("Tab 2")
            }

            // Third Tab - Another Example View
            NavigationView {
                ExampleView2()
            }
            .tabItem {
                Image(systemName: "star.fill")  // Third Tab Icon
                Text("Tab 3")
            }

            // Fourth Tab - Another Example View
            NavigationView {
                ExampleView3()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")  // Fourth Tab Icon
                Text("Tab 4")
            }

            // Fifth Tab - Another Example View
            NavigationView {
                ExampleView4()
            }
            .tabItem {
                Image(systemName: "ellipsis.circle.fill")  // Fifth Tab Icon
                Text("Tab 5")
            }
        }
    }
}

// Example views for other tabs
struct ExampleView1: View {
    var body: some View {
        Text("Content for Tab 2")
            .navigationTitle("Tab 2")
    }
}

struct ExampleView2: View {
    var body: some View {
        Text("Content for Tab 3")
            .navigationTitle("Tab 3")
    }
}

struct ExampleView3: View {
    var body: some View {
        Text("Content for Tab 4")
            .navigationTitle("Tab 4")
    }
}

struct ExampleView4: View {
    var body: some View {
        Text("Content for Tab 5")
            .navigationTitle("Tab 5")
    }
}

// Preview for MainTabView
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserViewModel())  // Assuming you pass environment objects
            .environmentObject(AuthViewModel())
    }
}

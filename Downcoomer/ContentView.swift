//
//  ContentView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CreatorsView()) {
                    Text("Creators")
                }
                NavigationLink(destination: RecentPostsView()) {
                    Text("Recent Posts")
                }
                NavigationLink(destination: CreatorPostsView()) {
                    Text("User Specific Posts")
                }
            }
            .navigationTitle("Coomer API")
        }
    }
}

#Preview {
    ContentView()
}

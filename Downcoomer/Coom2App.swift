//
//  Coom2App.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import SwiftUI

@main
struct KemonoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    NavigationLink(destination: ContentView()) {
                        Text("Browser")
                    }
                    NavigationLink(destination: ProfileDownloadView()) {
                        Text("Download Profile")
                    }
                }
            }
        }
    }
}

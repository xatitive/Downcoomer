//
//  CreatorsView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI

struct CreatorsView: View {
    @State private var creators: [Creator] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(creators) { creator in
                    VStack(alignment: .leading) {
                        Text(creator.name ?? "Unknown").font(.headline)
                        Text(creator.service!).font(.subheadline)
                        Text("Updated: \(String(describing: creator.updated))")
                    }
                }
            }
        }
        .navigationTitle("Creators")
        .onAppear {
            ApiService.shared.fetchCreators { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let creators):
                        self.creators = creators
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct CreatorsView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorsView()
    }
}

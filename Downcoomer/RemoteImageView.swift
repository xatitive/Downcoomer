//
//  RemoteImageView.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
typealias ImageType = UIImage
#elseif canImport(AppKit)
import AppKit
typealias ImageType = NSImage
#endif

struct RemoteImageView: View {
    let url: URL?
    
    @State private var image: Image? = nil
    @State private var isLoading = false
    @State private var error: Error? = nil
    
    var body: some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
        } else if isLoading {
            ProgressView()
                .onAppear(perform: loadImage)
        } else {
            Text("Failed to load image")
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        isLoading = true
        error = nil
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data, let uiImage = ImageType(data: data) {
                    #if canImport(UIKit)
                    self.image = Image(uiImage: uiImage)
                    #elseif canImport(AppKit)
                    self.image = Image(nsImage: uiImage)
                    #endif
                } else {
                    self.error = error
                }
            }
        }
        task.resume()
    }
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImageView(url: URL(string: "https://github.com/xatitive/xatitive/raw/main/squidgirl-noting.gif"))
    }
}

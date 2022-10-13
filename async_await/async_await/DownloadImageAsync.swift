//
//  DownloadImageAsync.swift
//  async_await
//
//  Created by 이건우 on 2022/10/11.
//
// Async Await을 활용해 이미지를 다운로드 해보자.

import SwiftUI

class DownloadImageAsyncLoader {
    let url = URL(string: "https://picsum.photos/250")!
    
    func downloadWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let image = UIImage(data: data),
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300
            else {
                completion(nil, error)
                return
            }
            completion(image, nil)
        }
        .resume()
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncLoader()
    
    func fetchImage() {
        loader.downloadWithEscaping { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    withAnimation { self?.image = image }
                }
            }
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 250, height: 250)
            }
            
            Rectangle()
                .frame(width: 250, height: 250)
                .foregroundColor(.gray)
                .opacity(viewModel.image == nil ? 1 : 0)
                .zIndex(1)
        }
        .onAppear {
            viewModel.fetchImage()
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}

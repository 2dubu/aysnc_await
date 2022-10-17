//
//  DownloadImageAsync.swift
//  async_await
//
//  Created by 이건우 on 2022/10/11.
//
// Async Await을 활용해 이미지를 다운로드 해보자.

import SwiftUI
import Combine

class DownloadImageAsyncLoader {
    let url = URL(string: "https://picsum.photos/250")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300
        else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completion(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        
        /* code for download image with @escaping...
        loader.downloadWithEscaping { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    withAnimation { self?.image = image }
                }
            }
        }
         */
        
        /* code for download image with combine...
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                withAnimation { self?.image = image }
            }
            .store(in: &cancellables)
         */
        
        let image = try? await loader.downloadWithAsync()
        // DispatchQueue.main 과 동일하게 다음 run loop 를 기다리지 않고 비동기적으로 처리한다.
        await MainActor.run {
            withAnimation { self.image = image }
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
            
            // Task는 Swift가 코드를 병렬로 실행하는 기본 메커니즘이다.
            // 각 Task는 다른 Task 와 함께 동시(concurrent)에 실행할 수 있는 새로운 비동기 컨텍스트를 제공한다.
            // 즉, Task{}를 통해 Task(Unstructured Task)를 생성한다. 이 외에도 여러 종류의 Task가 있음.
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}

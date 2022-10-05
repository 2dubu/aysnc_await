//
//  DoCatchTryThrows.swift
//  async_await
//
//  Created by 이건우 on 2022/10/06.
//
//  Async & Await을 학습하기 전 do-catch, try, throws를 되새겨 보자.

import SwiftUI

class DoCatchTryThrowsDataManager {
    
    let hasError: Bool = true
    
    func fetchData() throws -> String {
        if !hasError {
            return "I am a new data!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsViewModel: ObservableObject {
    
    @Published var data: String?
    let manager = DoCatchTryThrowsDataManager()
    
    func getData() {
        do {
            // 여러개의 try task를 호출할 수 있다.
            // 하지만 try문 중 하나라도 실패할 경우 do문을 나가고 catch문을 타게 된다. 무시하고 싶은 경우에는 try?를 사용할 수 있다.
            let data = try manager.fetchData()
            self.data = data
        } catch {
            data = error.localizedDescription
        }
    }
    
    func reset() {
        data = nil
    }
}

struct DoCatchTryThrows: View {
    
    @StateObject var viewModel = DoCatchTryThrowsViewModel()
    let placeholderText = "data is empty..."
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text(viewModel.data ?? placeholderText)
            
            HStack(spacing: 15) {
                Button {
                    viewModel.getData()
                } label: {
                    Text("load data")
                        .font(.callout)
                }
                
                Button {
                    viewModel.reset()
                } label: {
                    Text("reset")
                        .font(.callout)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct DoCatchTryThrows_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrows()
    }
}

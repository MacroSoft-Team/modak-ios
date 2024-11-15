//
//  ProfileViewModel.swift
//  Modak
//
//  Created by kimjihee on 11/14/24.
//

import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var originalNickname: String = "" // 서버에서 가져온 닉네임
    
    func fetchNickname() {
        Task {
            do {
                let data = try await NetworkManager.shared.requestRawData(router: .getMembersNicknames)
                
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let resultArray = jsonResponse["result"] as? [[String: Any]],
                   let firstResult = resultArray.first,
                   let fetchedNickname = firstResult["nickname"] as? String {
                    DispatchQueue.main.async {
                        self.originalNickname = fetchedNickname
                    }
                } else {
                    print("Failed to fetch nickname")
                }
            } catch {
                print("Error fetching nickname: \(error)")
            }
        }
    }
    
    func saveNickname(newNickname: String, completion: (() -> Void)? = nil) {
        Task {
            do {
                // APIRouter를 통해 URLRequest 생성
                let request = try APIRouter.updateNickname(nickname: newNickname).asURLRequest()
                print("Request URL:", request.url?.absoluteString ?? "No URL")
                print("Request Headers:", request.allHTTPHeaderFields ?? "No headers")
                print("Request Body:", String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "No body")
                
                // 서버로 요청
                let data = try await NetworkManager.shared.requestRawData(router: .updateNickname(nickname: newNickname))
                
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = jsonResponse["result"] as? [String: Any],
                   let nickname = result["nickname"] as? String {
                    
                    DispatchQueue.main.async {
                        self.originalNickname = nickname
                        print("Nickname successfully changed to: \(self.originalNickname)")
                        completion?()
                    }
                } else {
                    print("Failed to update nickname on server")
                }
            } catch {
                print("Error updating nickname: \(error)")
            }
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let data = try await NetworkManager.shared.requestRawData(router: .logout)
                
                if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                    print("Logout successful")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("Failed to logout")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Error logging out: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func deactivate(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let data = try await NetworkManager.shared.requestRawData(router: .deactivate)
                
                if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                    print("Deactivation successful")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("Failed to deactivate account")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Error deactivating account: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}

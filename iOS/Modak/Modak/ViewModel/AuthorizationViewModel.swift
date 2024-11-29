//
//  AuthorizationViewModel.swift
//  Modak
//
//  Created by kimjihee on 10/11/24.
//

import SwiftUI
import Photos

class AuthorizationViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var navigateToOrganizePhotoView: Bool = false
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.navigateToOrganizePhotoView = true
                case .limited:
                    self.showAlert = true
                case .denied, .restricted, .notDetermined :
                    self.showAlert = true
                @unknown default:
                    break
                }
            }
        }
    }
}

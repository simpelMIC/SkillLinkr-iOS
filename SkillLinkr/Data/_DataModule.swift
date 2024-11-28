//
//  data.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import Foundation
import Security
import SwiftUI

let defaultUser = User(id: "", firstname: "Max", lastname: "Mustermann", mail: "max@mustermann.de", released: true, role: UserRole(id: 2, name: "User", description: "hoishdf", createdAt: "", updatedAt: ""), profilePictureName: "", biography: "iof uisdfhiudsfhgiuhds uig dhsif dhsiuf iuh oi UHo IFho iH doih uiodfH IodHUiodfHUioh FIU ufdhios ufhids", updatedAt: "", createdAt: "")

let defaultAPIURL = "https://skilllinkr.micstudios.de/api"

struct User: Codable, Equatable {
    var id: String
    var firstname: String
    var lastname: String
    var mail: String
    var released: Bool
    var role: UserRole
    var profilePictureName: String?
    var biography: String?
    var updatedAt: String
    var createdAt: String
}

struct UserRole: Codable, Equatable {
    var id: Int
    var name: String
    var description: String
    var createdAt: String
    var updatedAt: String
}

class DataManager {
    func save(forKey: String, value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: forKey)
    }
    
    func load(forKey: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: forKey)
    }
}

class SecureDataManager {
    func saveToken(_ token: String, completion: @escaping (Result<Void, ErrorResponse>) -> Void) {
        guard let token = token.data(using: .utf8) else {
            completion(.failure(ErrorResponse(status: "Invalid token", message: "Invalid token")))
            return
        }
        
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "SkillLinkrToken",
            kSecValueData as String: token
        ]
        
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            completion(.success(()))
        case errSecDuplicateItem:
            completion(.success(()))
        default:
            completion(.failure(ErrorResponse(status: "Failed to save token", message: "Failed to save token to keychain")))
        }
    }
    
    func loadToken() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "SkillLinkrToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var data: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &data)
        
        if status == errSecSuccess, let tokenData = data as? Data, let token = String(data: tokenData, encoding: .utf8) {
            return token
        }
        return nil
    }
}

class DateDataManager {
    func iso8601StringToDate(_ isoString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: isoString)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func iso8601StringToFormattedDate(_ isoString: String) -> String? {
        let converter = ISO8601DateFormatter()
        let formatter = DateFormatter()
        converter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = converter.date(from: isoString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            return nil
        }
    }
}

extension String {
    var withZeroWidthSpaces: String {
        map({ String($0) }).joined(separator: "\u{200B}")
    }
}

extension Image {
    func jpgData(compressionQuality: CGFloat) -> Data? {
        // Convert SwiftUI Image to UIImage
        let uiImage = self.asUIImage()
        
        // Get JPEG data from UIImage
        return uiImage.jpegData(compressionQuality: compressionQuality)
    }
    
    // Helper function to convert SwiftUI Image to UIImage
    private func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self) //This can't be done async
        let view = controller.view
        
        // For simplicity, use a fixed size
        let targetSize = CGSize(width: 100, height: 100)
        
        // Set the size of the controller's view
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        // Render the view to UIImage
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

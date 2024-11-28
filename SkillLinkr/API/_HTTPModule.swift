//
//  HTTPModule.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import Foundation
import Security
import SwiftUI

struct ErrorResponse: Codable, Error {
    var status: String
    var message: String
}

class HTTPManager {
    struct LoginResponse: Codable {
        var status: String
        var message: Message
        
        struct Message: Codable {
            var token: String
        }
    }
    
    struct RegisterResponse: Codable {
        var status: String
        var message: Message
        
        struct Message: Codable {
            var token: String
        }
    }
    
    struct PatchResponse: Codable {
        var status: String
        var message: String
    }
    
    struct UserResponse: Codable, Equatable {
        var status: String
        var message: User
    }
    
    func login(mail: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        print("Logging in \(mail)...")
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/login") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    completion(.success(loginResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func register(mail: String, firstname: String, lastname: String, password: String, passwordConfirm: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        print("Registering \(mail)...")
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/register") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "firstname": firstname,
            "lastname": lastname,
            "password": password,
            "passwordConfirm": passwordConfirm
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            print("Error Code: 100-0")
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Error Code: 100-1")
                print(error)
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                print("Error Code: 100-2")
                print(error)
                return
            }
            
            if httpResponse.statusCode == 201 {
                do {
                    let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    completion(.success(registerResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                    print("Error Code: 100-3")
                    print(decodeError)
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                    print("Error Code: 100-4")
                    print(error)
                } catch let decodeError {
                    completion(.failure(decodeError))
                    print("Error Code: 100-5")
                    print(decodeError)
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
                print("Error Code: 100-6")
                print(error)
            }
        }
        
        task.resume()
    }
    
    func getLoggedInUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(userResponse.message))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decorodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decorodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get users. Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user/other/\(id)") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(userResponse.message))
                    print(userResponse)
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decorodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decorodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get users. Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func patchUser(patchUserId: String, firstname: String? = nil, lastname: String? = nil, password: String? = nil, roleID: Int? = nil, released: Bool? = nil, biography: String? = nil, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let firstname = firstname {
            parameters["firstname"] = firstname
        }
        
        if let lastname = lastname {
            parameters["lastname"] = lastname
        }
        
        if let password = password {
            parameters["password"] = password
        }
        
        if let roleID = roleID {
            parameters["roleID"] = roleID
        }
        
        if let released = released {
            parameters["released"] = released
        }
        
        if let biography = biography {
            parameters["biography"] = biography
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let response = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(response))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func updateProfilePicture(jpegDataImage: Data, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Pulling User Data...")
        getLoggedInUser() { result in
            switch result {
            case .success(let response):
                print("Successfully pulled User data")
                print("Uploading Image...")
                self.continueUpdatingProfilePicture(user: response, jpegDataImage: jpegDataImage) { result in
                    switch result {
                    case .success(let response):
                        print("Successfully uploaded image: \(response.message)")
                    case .failure(let error):
                        print("Error while uploading image: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }
    
    private func continueUpdatingProfilePicture(user: User, jpegDataImage: Data, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        
        func createMultipartBody(boundary: String, data: Data, fieldName: String, fileName: String) -> Data {
            var body = Data()
            
            let boundaryPrefix = "--\(boundary)\r\n"
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".utf8))
            body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
            body.append(data)
            body.append(Data("\r\n".utf8))
            body.append(Data("--\(boundary)--\r\n".utf8))
            
            return body
        }
        
        func postProfilePicture(completion: @escaping (Result<PatchResponse, Error>) -> Void) {
            print("Posting profile picture")
            
            guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user/profilepicture") else {
                let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
                completion(.failure(errorResponse))
                return
            }
            
            guard let token = SecureDataManager().loadToken() else {
                let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
                completion(.failure(errorResponse))
                return
            }
            
            let boundary = UUID().uuidString
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = createMultipartBody(boundary: boundary, data: jpegDataImage, fieldName: "file", fileName: "profilePicture.jpeg")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleResponse(data: data, response: response, error: error, completion: completion)
            }
            
            task.resume()
        }
        
        func patchProfilePicture(completion: @escaping (Result<PatchResponse, Error>) -> Void) {
            print("Trying to patch profile picture")
            
            guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user/profilepicture") else {
                let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
                completion(.failure(errorResponse))
                return
            }
            
            guard let token = SecureDataManager().loadToken() else {
                let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
                completion(.failure(errorResponse))
                return
            }
            
            let boundary = UUID().uuidString
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = createMultipartBody(boundary: boundary, data: jpegDataImage, fieldName: "file", fileName: "profilePicture.jpeg")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleResponse(data: data, response: response, error: error, completion: completion)
            }
            
            task.resume()
        }
        
        func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
            if let error = error {
                completion(.failure(error))
                print("Request failed with error: \(error)")
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                do {
                    let responseObj = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(responseObj))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected error. Response: \(responseString)"])
                    completion(.failure(error))
                }
            }
        }
        
        patchProfilePicture { result in
            switch result {
            case .success(let response):
                print(response)
                completion(.success(response))
            case .failure(let error):
                if error.localizedDescription.contains("User has no profile picture") {
                    print("The user has no profilePicture yet. Posting new ProfilePicture...")
                    postProfilePicture { result in
                        switch result {
                        case .success(let response):
                            print(response)
                            completion(.success(response))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                } else {
                    print(error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteProfilePicture(completion: @escaping (Result<Void, ErrorResponse>) -> Void) {
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user/profilepicture") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                let errorResponse = ErrorResponse(status: "Request failed", message: error.localizedDescription)
                completion(.failure(errorResponse))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let errorResponse = ErrorResponse(status: "Invalid response", message: "No valid HTTP response")
                completion(.failure(errorResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 400...499:
                let errorResponse = ErrorResponse(status: "Client error", message: "Status code: \(httpResponse.statusCode)")
                completion(.failure(errorResponse))
            case 500...599:
                let errorResponse = ErrorResponse(status: "Server error", message: "Status code: \(httpResponse.statusCode)")
                completion(.failure(errorResponse))
            default:
                let errorResponse = ErrorResponse(status: "Unexpected status", message: "Status code: \(httpResponse.statusCode)")
                completion(.failure(errorResponse))
            }
        }
        
        task.resume()
    }
}

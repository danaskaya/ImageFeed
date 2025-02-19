//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 16.12.2024.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var profile: Profile?
    private init(){}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request =  makeRequest(token: token)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>)  in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(data: body)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
        
    }
    
    func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com" + "/me") else { fatalError("Error of create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func object(for request: URLRequest, completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { result in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
}
struct ProfileResult: Codable {
    let id: String
    let username, name, firstName: String
    let lastName: String?
    let bio: String?
    enum CodingKeys: String, CodingKey {
        case id, username, name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
struct Profile: Codable {
    let id: String
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    init(data: ProfileResult) {
        self.id = data.id
        self.username = data.username
        self.name = (data.firstName) + " " + (data.lastName ?? " ")
        self.loginName = "@" + data.username
        self.bio = data.bio
    }
}

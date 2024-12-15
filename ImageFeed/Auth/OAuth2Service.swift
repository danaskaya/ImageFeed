//
//  0Auth2Service.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 14.12.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return Oauth2TokenStorage().token
        } set {
            Oauth2TokenStorage().token = newValue
        }
    }
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")
        components?.queryItems = [URLQueryItem(name: "client_id", value: accessKey),
                                  URLQueryItem(name: "client_secret", value: secretKey),
                                  URLQueryItem(name: "redirect_uri", value: redirectURI),
                                  URLQueryItem(name: "code", value: code),
                                  URLQueryItem(name: "grant_type", value: "authorization_code")]
        if let url = components?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
extension URLRequest {
    static func makeHTTPRequest(path: String, httpMethod: String, baseURL: URL = defaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL) ?? defaultBaseURL)
        request.httpMethod = httpMethod
        return request
    }
}
extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OauthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { result in
            let response = result.flatMap { data -> Result<OauthTokenResponseBody, Error> in
                Result { try decoder.decode(OauthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
}
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError .httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

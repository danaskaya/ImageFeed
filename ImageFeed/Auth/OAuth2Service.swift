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
    private var task: URLSessionTask?
    private var lastCode: String?
    private (set) var authToken: String? {
        get {
            return Oauth2TokenStorage.shared.token
        } set {
            Oauth2TokenStorage.shared.token = newValue
        }
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        var components = URLComponents(string: "https://unsplash.com/oauth/token")
        components?.queryItems = [URLQueryItem(name: "client_id", value: AuthConfiguration.standart.accessKey),
                                  URLQueryItem(name: "client_secret", value: AuthConfiguration.standart.secretKey),
                                  URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standart.redirectURI),
                                  URLQueryItem(name: "code", value: code),
                                  URLQueryItem(name: "grant_type", value: "authorization_code")]
        if let url = components?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OauthTokenResponseBody, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let authToken = body.accessToken
                        self.authToken = authToken
                        completion(.success(authToken))
                        self.task = nil
                        
                    case .failure(let error):
                        completion(.failure(error))
                        self.lastCode = nil
                    }
                }
            }
            self.task = task
            task.resume()
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
    func objectTask<T: Decodable> (for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        return data(for: request) { result in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {try JSONDecoder().decode(T.self, from: data) }
            }
            completion(response)
        }
    }
}
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

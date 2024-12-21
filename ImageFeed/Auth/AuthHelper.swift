//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 21.12.2024.
//

import Foundation
protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(form url: URL) -> String?
}
class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    init(configuration: AuthConfiguration = .standart) {
        self.configuration = configuration
    }
    
    func authURL() -> URL {
        var components = URLComponents(string: AuthConfiguration.standart.authURLString)
        components?.queryItems = [URLQueryItem(name: "client_id", value: AuthConfiguration.standart.accessKey),
                                  URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standart.redirectURI),
                                  URLQueryItem(name: "response_type", value: "code"),
                                  URLQueryItem(name: "scope", value: AuthConfiguration.standart.accessScope)]
        guard let url = components?.url else { return URL(string: "")! }
        return  url
    }
    func authRequest() -> URLRequest {
        let url = authURL()
        return URLRequest(url: url)
    }
    
    func code(form url: URL) -> String? {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems?.first(where: { $0.name == "code"} ) else { return nil }
        return items.value
    }
}

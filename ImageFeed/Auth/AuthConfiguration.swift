//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 21.12.2024.
//

import Foundation
let AccessKey = "asukNu-NRmJw1QDuBxE2p3n70BXJ_dtOREY4iYXE7aI"
let SecretKey = "J6Z7YMX24Pe5dEFjNJySLNBPaPqfpsKagwBdSyhGXJg"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://unsplash.com")!
let DefaultBaseApiURL = URL(string: "https://api.unsplash.com")!
let AuthURLString = "https://unsplash.com/oauth/authorize"
struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String
    let defaultBaseURL: URL
    let defaultBaseApiURL: URL
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL, defaultBaseApiURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURL = defaultBaseURL
        self.defaultBaseApiURL = defaultBaseApiURL
    }
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 authURLString: AuthURLString,
                                 defaultBaseURL: DefaultBaseURL,
                                 defaultBaseApiURL: DefaultBaseApiURL)
    }
}

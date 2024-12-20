//
//  Oauth2TokenStorage.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 14.12.2024.
//

import Foundation
import SwiftKeychainWrapper

class Oauth2TokenStorage {
    static let shared = Oauth2TokenStorage()
    private let tokenKey = "BearerToken"
    private init() {}
    private let keychain = KeychainWrapper.standard
    var token: String? {
        get {
            return keychain.string(forKey: tokenKey)
        } set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: tokenKey)
            }
        }
    }
    func removeKey() {
        keychain.removeObject(forKey: tokenKey)
    }
}

//
//  Oauth2TokenStorage.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 14.12.2024.
//

import Foundation

class Oauth2TokenStorage {
    static let shared = Oauth2TokenStorage()
    private let tokenKey = "BearerToken"
    private let userDefaults = UserDefaults()
    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        } set {
            userDefaults.setValue(newValue, forKey: tokenKey)
        }
    }
}

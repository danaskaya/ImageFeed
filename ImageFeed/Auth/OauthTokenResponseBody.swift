//
//  Oauth2TokenResponseBody.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 14.12.2024.
//

import Foundation

struct OauthTokenResponseBody: Decodable {
    let accessToken, tokenType, scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

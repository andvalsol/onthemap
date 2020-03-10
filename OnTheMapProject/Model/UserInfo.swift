//
//  UserInfo.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/9/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

struct UserInfo: Codable {
    let userName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case lastName = "lastName"
    }
}

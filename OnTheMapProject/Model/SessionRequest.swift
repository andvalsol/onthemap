//
//  SessionRequest.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/6/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import Foundation

struct SessionRequest: Codable {
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case user = "udacity"
    }
}

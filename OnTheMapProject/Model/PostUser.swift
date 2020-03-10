//
//  PostUser.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/9/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

struct PostUser: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}

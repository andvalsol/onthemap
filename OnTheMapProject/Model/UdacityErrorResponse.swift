//
//  UdacityErrorResponse.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/9/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import Foundation

struct UdacityErrorResponse: Codable, LocalizedError {
    let status: Int
    let error: String
    
    var errorDescription: String? {
        return error
    }
}

//
//  LogInResponse.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/25/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import Foundation

struct LogInResponse: Codable {
    let status: String
    let message: String?
    let errorMessage: String?
    let stackTrace: String?
}

//
//  MovieListResponse.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/25/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import Foundation

struct MovieListResponse: Codable {
    let movies: [Movie]
    
    struct Page: Codable {
        let page: String
    }
    
    let page: Page
}

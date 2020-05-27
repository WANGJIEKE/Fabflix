//
//  Movies.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/26/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import Foundation

struct Movie: Codable {
    let movieId: String
    let movieTitle: String
    let movieYear: String
    let movieDirector: String
    let movieGenres: [String]
    let movieStars: [Star]
    let movieRating: String?
}

//
//  MovieDetailViewController.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/26/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    static let movieAPIEndPoint = "single-movie"
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var starSectionHeaderLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI(from: movie)
    }
    
    func setUpUI(from theMovie: Movie) {
        movieTitleLabel.text = theMovie.movieTitle
        directorLabel.text = "Directed by \(theMovie.movieDirector)"
        yearLabel.text = "(\(theMovie.movieYear))"
        genreLabel.text = theMovie.movieGenres.joined(separator: ", ")
        if theMovie.movieStars.count == 0 {
            starSectionHeaderLabel.isHidden = true
        }
        starLabel.text = theMovie.movieStars.map { $0.starName }.joined(separator: "\n")
        ratingLabel.text = "\(theMovie.movieRating ?? "N/A")"
    }
}

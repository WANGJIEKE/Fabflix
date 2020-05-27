//
//  MovieListViewController.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/25/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import UIKit

class MovieListViewController: UITableViewController, UISearchBarDelegate {
    static let searchAPIEndPoint = "movies"
    
    var movies: [Movie] = []
    var lastMovieTitleSearched: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController!.searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshMovieList), for: .valueChanged)
    }
    
    // MARK: - UIRefreshControl related
    
    @objc func refreshMovieList() {
        if lastMovieTitleSearched == "" {
            refreshControl!.endRefreshing()
            return
        }
        fetchMovieListFor(lastMovieTitleSearched)
    }
    
    // MARK: - UITableViewDataSource
    
    static func movieStarGenreToDetailTextLabelString(_ movie: Movie) -> String {
        let genres = movie.movieGenres.joined(separator: ", ")
        let stars = movie.movieStars.map { $0.starName }.joined(separator: ", ")
        return "\(stars)" + (genres.count > 0 ? " (\(genres))" : "")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieInfoCell", for: indexPath)
        let movie = movies[indexPath.row]
        cell.textLabel!.text = "\(movie.movieTitle) (\(movie.movieDirector), \(movie.movieYear))"
        cell.detailTextLabel!.text = MovieListViewController.movieStarGenreToDetailTextLabelString(movie)
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let movieToSearch = navigationItem.searchController!.searchBar.text!
        
        if movieToSearch != lastMovieTitleSearched {
            fetchMovieListFor(movieToSearch)
        } else {
            navigationItem.searchController!.isActive = false
        }
    }
    
    // MARK: - Search
    
    func alertLoadMovieListFailureWithMessage(_ message: String) {
        DispatchQueue.main.async {
            self.navigationItem.searchController!.isActive = false
            let alert = UIAlertController(title: "Failed to load movie list", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func fetchMovieListFor(_ query: String) {
        let title = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.count == 0 {
            return
        }
        
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlQuery = "?title=\(encodedTitle)&year=null&director=null&star=null&genre=null&alnum=null&sort=3&" +
            "page=1&display=20&fulltext=fulltextsearch&fuzzy=Fuzzyoff&manualPage="
        
        let url = URL(string: baseURL + MovieListViewController.searchAPIEndPoint + urlQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                self.alertLoadMovieListFailureWithMessage("Reason: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    self.alertLoadMovieListFailureWithMessage("Reason: \(response.statusCode)")
                    return
                }
            } else {
                self.alertLoadMovieListFailureWithMessage("Server returned non HTTPURLResponse")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(MovieListResponse.self, from: data!)
                
                self.movies = json.movies
                self.lastMovieTitleSearched = title
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.navigationItem.searchController!.isActive = false
                    if self.refreshControl!.isRefreshing {
                        self.refreshControl!.endRefreshing()
                    }
                }
            } catch let decodingError as DecodingError {
                print(decodingError)
                self.alertLoadMovieListFailureWithMessage("Error while decoding response")
                return
            } catch let unknownError {
                print(unknownError)
                self.alertLoadMovieListFailureWithMessage("Failed to fetch movie list due to unknown reason")
                return
            }
        }
        task.resume()
    }
    
    // MARK: - Segue to MovieInfoView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail" {
            let movieDetailViewController = segue.destination as! MovieDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            movieDetailViewController.movie = movies[indexPath.row]
        }
    }
}

//
//  TheatersViewController.swift
//  NoahCunninghamBaker-Lab4
//
//  Created by Noah Cunningham Baker on 10/29/23.
//

import Foundation
import UIKit


class RecommendationsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data: [Movie] = []
    var imageData: [UIImage] = []
    var favoriteMovies: [Int] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setup()
        
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchData() { [weak self] data in
                self?.data = data
                self?.cacheImages()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                }
            }
        }
        super.viewWillAppear(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchData() { [weak self] data in
                self?.data = data
                self?.cacheImages()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                }
            }
        }
    }
    
    func setup() {
        if let movieData = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] {
            favoriteMovies = movieData
        }
    }
    
    func fetchData(completion: @escaping ([Movie]) -> Void){
        var results: [Movie] = []
        for id in favoriteMovies {
            let apiKey = "3151c44bf06d1dc5225c7d063a6b0fb3"
            let baseUrl = "https://api.themoviedb.org/3/movie/\(id)/recommendations"
            
            let query = [
                URLQueryItem(name: "api_key", value: apiKey)
            ]
            
            var urlComponents = URLComponents(string: baseUrl)
            urlComponents?.queryItems = query
            
            guard let url = urlComponents!.url else {
                print("Invalid URL")
                return
            }
            
            guard let response = try? Data(contentsOf: url) else {
                print("could not retrieve data")
                return
            }
            
            do {
                
                let apiResults = try JSONDecoder().decode(APIResults.self, from: response)
                for res in apiResults.results {
                    results.append(res)
                }
            } catch {
                print("Error decoding")
            }
        }
        
        completion(results)
    }
                
    func cacheImages() {
        imageData = []
        for movie in data {
            if let path = movie.poster_path, let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)"),
               let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                self.imageData.append(image)
            } else {
                // Use a placeholder image if the URL is invalid
                self.imageData.append(UIImage(systemName: "photo")!)
            }
        }
    }
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell
        
        let movie = data[indexPath.row]
        cell.title.text = movie.title
        cell.releaseDate.text = "Average Rating: \(movie.vote_average)"
        if (imageData.count > indexPath.row) {
            cell.poster.image = imageData[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailedVC = storyboard?.instantiateViewController(withIdentifier: "DetailedViewControllerID") as? DetailedViewController {
            detailedVC.movie = data[indexPath.row]
            detailedVC.image = imageData[indexPath.row]
            
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }

}

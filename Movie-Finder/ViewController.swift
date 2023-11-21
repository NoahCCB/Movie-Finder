//
//  ViewController.swift
//  NoahCunninghamBaker-Lab4
//
//  Created by Noah Cunningham Baker on 10/18/23.
//
import Foundation
import UIKit

struct APIResults: Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int!
    let poster_path: String?
    let title: String
    let release_date: String?
    let vote_average: Double
    let overview: String
    let vote_count: Int!
}


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIContextMenuInteractionDelegate {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        
        if (imageData.count > indexPath.item) {
            cell.poster.image = imageData[indexPath.item]
        }
    
        cell.title.text = data[indexPath.item].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailedVC = storyboard?.instantiateViewController(withIdentifier: "DetailedViewControllerID") as? DetailedViewController {
            detailedVC.movie = data[indexPath.item]
            detailedVC.image = imageData[indexPath.item]
            
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var data: [Movie] = []
    var imageData: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        search.delegate = self
        getTrendingMovies()
    }
    
    func getTrendingMovies(){
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.trendingData() { [weak self] data in
                self?.data = data
                self?.cacheImages()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.spinner.stopAnimating()
                }
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = data[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let favoriteAction = UIAction(title: "Add to Favorites", image: UIImage(systemName: "star.fill")) { [weak self] action in
                if let movieId = movie.id, let imagePath = movie.poster_path {
                    var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
                    var favoriteImages = UserDefaults.standard.array(forKey: "favoriteImages") as? [String] ?? []
                    if !(favoriteMovies.contains(movieId)) {
                        print("added to defaults")
                        favoriteMovies.append(movieId)
                        favoriteImages.append(imagePath)
                    } else {
                        print("already in defaults")
                    }
                    print("\(String(describing: self?.data.count))")
                    UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
                    UserDefaults.standard.set(favoriteImages, forKey: "favoriteImages")
                }
            }

            return UIMenu(title: "Actions", children: [favoriteAction])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }

    
    @IBOutlet weak var search: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let currSearch = search.text ?? ""
        if currSearch == "" {
            getTrendingMovies()
        } else {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                self.fetchData(query: currSearch) { [weak self] data in
                    self?.data = data
                    self?.cacheImages()
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                        self?.spinner.stopAnimating()
                    }
                }
            }
        }
    }
    
    func fetchData(query: String, completion: @escaping ([Movie]) -> Void){
        var results: [Movie] = []
        print("fetch called")
        let apiKey = "3151c44bf06d1dc5225c7d063a6b0fb3"
        let baseUrl = "https://api.themoviedb.org/3/search/movie"
        
        let query = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query)
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
            let searchResults = try JSONDecoder().decode(APIResults.self, from: response)
            results = searchResults.results
            //print(self.data)
            completion(results)
        } catch {
            print("Error decoding")
        }
    }
    
    func trendingData(completion: @escaping ([Movie]) -> Void){
        var results: [Movie] = []
        
        let apiKey = "3151c44bf06d1dc5225c7d063a6b0fb3"
        let baseUrl = "https://api.themoviedb.org/3/trending/movie/day"
        
        let query = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = query
        
        guard let url = urlComponents!.url else {
            print("Invalid URL")
            return
        }
        print(url)
        guard let response = try? Data(contentsOf: url) else {
            print("could not retrieve data")
            return
        }
        
        do {
            
            let apiResults = try JSONDecoder().decode(APIResults.self, from: response)
            results = apiResults.results
        } catch {
            print("Error decoding")
        }
        
        
        completion(results)
    }
    
    func cacheImages(){
        imageData = []
        for movie in data {
            if let path = movie.poster_path {
                if let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") {
                    let response = try? Data(contentsOf: url)
                    if let image = UIImage(data: response!) {
                        imageData.append(image)
                    }
                    
                } else {
                    imageData.append(UIImage(systemName: "photo")!)
                }
            } else {
                imageData.append(UIImage(systemName: "photo")!)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110.0, height: 170.0)
    }
}
    

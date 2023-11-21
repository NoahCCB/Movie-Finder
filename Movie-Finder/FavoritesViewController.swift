//
//  FavoritesViewController.swift
//  NoahCunninghamBaker-Lab4
//
//  Created by Noah Cunningham Baker on 10/28/23.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var data: [Movie] = []
    var imageData: [UIImage] = []
    var favoriteMovies: [Int] = []
    var favoriteImages: [String] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupCollectionView()
        setup()
        super.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setup() // Call setup when the view is about to appear
    }
    
    func setup() {
        if let movieData = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int],
           let imageDatas = UserDefaults.standard.array(forKey: "favoriteImages") as? [String] {
            favoriteMovies = movieData
            favoriteImages = imageDatas
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                self.fetchData() { [weak self] data in
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
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
        print("didSelect")
        if let detailedVC = storyboard?.instantiateViewController(withIdentifier: "DetailedFavoritesViewControllerID") as?
            DetailedFavoritesViewController {
            print("made vc")
            detailedVC.movie = data[indexPath.item]
            detailedVC.image = imageData[indexPath.item]
            print(detailedVC.movie.title)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func fetchData(completion: @escaping ([Movie]) -> Void){
       
        var results: [Movie] = []
        for id in favoriteMovies {
        
            let apiKey = "3151c44bf06d1dc5225c7d063a6b0fb3"
            let baseUrl = "https://api.themoviedb.org/3/movie/\(id)"
            
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
                let movie = try JSONDecoder().decode(Movie.self, from: response)
                results.append(movie)
            } catch {
                print("Error decoding")
            }
        }
        completion(results)
    }
    
    func cacheImages(){
        imageData = []
        for path in favoriteImages {
            if let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") {
                let response = try? Data(contentsOf: url)
                if let image = UIImage(data: response!) {
                    imageData.append(image)
                } else {
                    imageData.append(UIImage(systemName: "photo")!)
                }
            }
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110.0, height: 170.0)
    }
}





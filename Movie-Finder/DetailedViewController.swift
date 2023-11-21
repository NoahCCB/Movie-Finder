//
//  DetailedViewController.swift
//  NoahCunninghamBaker-Lab4
//
//  Created by Noah Cunningham Baker on 10/22/23.
//

import UIKit

class DetailedViewController : UIViewController {
    
    var movie: Movie!
    var image: UIImage!
    
    
    @IBAction func addToFavorites(_ sender: Any) {
        
        if let movieId = self.movie.id, let imagePath = self.movie.poster_path {
            var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
            var favoriteImages = UserDefaults.standard.array(forKey: "favoriteImages") as? [String] ?? []
            if !(favoriteMovies.contains(movieId) || favoriteImages.contains(imagePath)) {
                print("added to defaults")
                favoriteMovies.append(movieId)
                favoriteImages.append(imagePath)
            } else {
                print("already in defaults")
            }
            UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
            UserDefaults.standard.set(favoriteImages, forKey: "favoriteImages")
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        nameLabel.text = movie.title
        overviewLabel.text = movie.overview
        ratingLabel.text = "Average Rating: \(movie.vote_average)"
        
    }
    
}

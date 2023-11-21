
import UIKit

class DetailedFavoritesViewController : UIViewController {
    
    var movie: Movie!
    var image: UIImage!
    
    
    
    @IBAction func removeFromFavorites(_ sender: Any) {
        if let movieId = self.movie.id, let imagePath = self.movie.poster_path {
            var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
            var favoriteImages = UserDefaults.standard.array(forKey: "favoriteImages") as? [String] ?? []
            
            if let movieIndex = favoriteMovies.firstIndex(of: movieId),
               let imageIndex = favoriteImages.firstIndex(of: imagePath) {
                
                favoriteMovies.remove(at: movieIndex)
                favoriteImages.remove(at: imageIndex)
                
                UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
                UserDefaults.standard.set(favoriteImages, forKey: "favoriteImages")
            }
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

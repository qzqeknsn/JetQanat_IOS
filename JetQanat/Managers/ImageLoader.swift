
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            self.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        // 1. Check for valid URL scheme
        if urlString.lowercased().hasPrefix("http") {
            ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.image = image
                }
            }
            return
        }
        
        // 2. Try as local named asset
        if let localImage = UIImage(named: urlString) {
            self.image = localImage
            return
        }
        
        // 3. Try as SF Symbol
        if let systemImage = UIImage(systemName: urlString) {
            self.image = systemImage
            return
        }
        
        // 4. Default fallback/background if nothing matches
        self.backgroundColor = .darkGray
    }
}

import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    static let reuseIdentifier = "ImagesListCell"
    
}

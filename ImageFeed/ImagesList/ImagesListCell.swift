import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell:ImagesListCell)
}
final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
        let like = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(like, for: .normal)
    }
    @IBAction func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }
}


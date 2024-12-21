//
//  ViewController.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 11.12.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let SingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private lazy var dateFormatted = DateFormatter()
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimate()
            }
        imagesListService.fetchPhotosNextPage()
        tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController {
                let indexPath = sender as! IndexPath
                let photo = photos[indexPath.row]
                guard let url = photo.largeImageURL,
                      let imageURL = URL(string: url) else { return }
                viewController.imageURL = imageURL
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private func fetchDate(dateString: Date) -> String {
        var formattedDateString: String?
        dateFormatted.dateFormat = "dd MMMM yyyy"
        dateFormatted.locale =  Locale(identifier: "ru_RU")
        formattedDateString = dateFormatted.string(from: dateString)
        guard let formattedDateString = formattedDateString else {
            return ""
        }
        return formattedDateString
    }
    private func updateTableViewAnimate() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .bottom)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let imageURL = photos[indexPath.row].thumbImageURL  else {
            return
        }
        let url = URL(string: imageURL)
        cell.imageCell.kf.indicatorType = .activity
        let placeholder = UIImage(named: "Stub")
        cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            cell.imageCell.kf.indicatorType = .none
        }
        let labelDate = photos[indexPath.row].createdAt
        cell.dateLabel.text = fetchDate(dateString: labelDate ?? Date())
        
        let isLiked = imagesListService.photos[indexPath.row].isLiked == false
        let like = isLiked ? UIImage(named: "like_button_off") : UIImage(named: "like_button_on")
        cell.likeButton.setImage(like, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = photos[indexPath.row]
        let size = CGSize(width: cell.size.width, height: cell.size.height)
        let aspectRatio = size.width / size.height
        return tableView.frame.width / aspectRatio
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == imagesListService.photos.count else { return }
        imagesListService.fetchPhotosNextPage()
    }
}
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoID: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
                
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}




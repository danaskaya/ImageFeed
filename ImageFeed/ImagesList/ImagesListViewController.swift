//
//  ViewController.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 11.12.2024.
//

import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol { get set }
    func updateTableViewAnimate()
}

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    
    private let SingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListService = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    @IBOutlet private var tableView: UITableView!
    var presenter: ImageListViewPresenterProtocol = {
        return ImageListViewPresenter()
    }()
    
    override func viewDidLoad() {
        presenter.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        presenter.view = self
    }
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let imageURL = presenter.photos[indexPath.row].thumbImageURL  else { return }
        let url = URL(string: imageURL)
        cell.imageCell.kf.indicatorType = .activity
        let placeholder = UIImage(named: "")
        cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            cell.imageCell.kf.indicatorType = .none
        }
        let labelDate = presenter.photos[indexPath.row].createdAt
        cell.dateLabel.text = presenter.fetchDate(dateString: labelDate ?? Date())
        
        let isLiked = imagesListService.photos[indexPath.row].isLiked == false
        let like = isLiked ? UIImage(named: "like_button_off") : UIImage(named: "like_button_on")
        cell.likeButton.setImage(like, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController {
                let indexPath = sender as! IndexPath
                let photo = presenter.photos[indexPath.row]
                guard let url = photo.largeImageURL,
                      let imageURL = URL(string: url) else { return }
                viewController.imageURL = imageURL
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    func updateTableViewAnimate() {
        let oldCount = presenter.photos.count
        let newCount = imagesListService.photos.count
        presenter.photos = imagesListService.photos
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
    func checkCompletedList(_ indexPath: IndexPath) {
        if !ProcessInfo.processInfo.arguments.contains("testMode") {
            if imagesListService.photos.isEmpty || (indexPath.row + 1 == imagesListService.photos.count) {
                imagesListService.fetchPhotosNextPage()
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
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
        let cell = presenter.photos[indexPath.row]
        let size = CGSize(width: cell.size.width, height: cell.size.height)
        let aspectRatio = size.width / size.height
        return tableView.frame.width / aspectRatio
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        checkCompletedList(indexPath)
    }
}
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let photo = presenter.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoID: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success:
                self.presenter.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.presenter.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
                
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}




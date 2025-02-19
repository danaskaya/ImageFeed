//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 21.12.2024.
//

import Foundation

protocol ImageListViewPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func fetchDate(dateString: Date) -> String
    func observeAnimate()
}
final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    weak var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private lazy var dateFormatted = DateFormatter()
    func viewDidLoad() {
        observeAnimate()
    }
    func fetchDate(dateString: Date) -> String {
        var formattedDateString: String?
        dateFormatted.dateFormat = "dd MMMM yyyy"
        dateFormatted.locale =  Locale(identifier: "ru_RU")
        formattedDateString = dateFormatted.string(from: dateString)
        guard let formattedDateString = formattedDateString else {
            return ""
        }
        return formattedDateString
    }
    func observeAnimate() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                view?.updateTableViewAnimate()
            }
        ImagesListService.shared.fetchPhotosNextPage()
    }
}

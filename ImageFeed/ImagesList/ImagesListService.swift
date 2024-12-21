//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 19.12.2024.
//

import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private init(){}
    private let urlSession = URLSession.shared
    private let oauth2TokenStorage = Oauth2TokenStorage.shared
    private var page: Int?
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    private var lastLoadedPage: Int = 0
    
    func fetchPhotosNextPage() {
        print(photos.count)
        assert(Thread.isMainThread)
        guard task == nil else { return }
        page = lastLoadedPage == 0 ? 1 : lastLoadedPage + 1
        guard let token = oauth2TokenStorage.token else { return }
        let request = makeRequest(token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async{
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    for photo in photoResult {
                        self.photos.append(self.convert(model: photo))
                    }
                    guard let page = self.page else { return }
                    self.lastLoadedPage = page
                    NotificationCenter.default
                        .post(name: ImagesListService.didChangeNotification,
                              object: self
                        )
                    
                case .failure(let error):
                    assertionFailure("Receiving image failed, \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    func convert(model: PhotoResult) -> Photo {
        return Photo(id: model.id,
                     size: CGSize(width: model.width, height: model.height),
                     createdAt: dateFormatter.date(from: model.createdAt ?? ""),
                     welcomeDescription: model.description,
                     thumbImageURL: model.urls.thumb,
                     largeImageURL: model.urls.full,
                     isLiked: model.isLiked)
    }
    func makeRequest(token: String) -> URLRequest {
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        if let page = page {
            components?.queryItems = [URLQueryItem(name: "page", value: String(page)),
                                      URLQueryItem(name: "per_page", value: "10")]
        }
        
        guard let url = components?.url else { fatalError("URL create error") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = oauth2TokenStorage.token else { return }
        var request: URLRequest?
        if isLike {
            request = deleteLike(token: token, photoID: photoID)
        } else {
            request = postLike(token: token, photoID: photoID)
        }
        guard let request = request else {  return }
        let task = urlSession.objectTask(for: request) { [weak self] (result:Result<LikePhoto, Error>) in
            guard let self = self else {  return }
            self.task = nil
            switch result {
            case .success(let photoResult):
                let isLiked = photoResult.photo.isLiked
                if let index = self.photos.firstIndex(where: { $0.id == photoResult.photo.id }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         size: photo.size,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: isLiked)
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
        
    }
    func deleteLike(token: String, photoID: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(path: "photos/\(photoID)/like",
                                                 httMethod: "DELETE",
                                                 baseURL: AuthConfiguration.standart.defaultBaseApiURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func postLike(token: String, photoID: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(path: "photos/\(photoID)/like",
                                                 httMethod: "POST",
                                                 baseURL: AuthConfiguration.standart.defaultBaseApiURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
extension ImagesListService {
    private func object(for request: URLRequest, completion: @escaping (Result<PhotoResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { result in
            let response = result.flatMap { data -> Result<PhotoResult, Error> in
                Result { try decoder.decode(PhotoResult.self, from: data) }
            }
            completion(response)
        }
    }
}
extension URLRequest {
    static func makeHTTPRequest (path: String, httMethod: String, baseURL: URL = AuthConfiguration.standart.defaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httMethod
        return request
    }
}
extension Array {
    func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImagesListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}


//
//  ImageListTests.swift
//  ImageFeedTests
//
//  Created by Diliara Sadrieva on 21.12.2024.
//

import Foundation
import XCTest
@testable import ImageFeed
final class ImageListTests: XCTestCase {
    func testImageListVidDidLoadCalled(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImageListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testDateFormatFetching() {
        //given
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: "2023-04-28T12:46:16Z") ?? Date()
        let presenter = ImageListViewPresenterSpy()
        
        let fetchedFormat = presenter.fetchDate(dateString: date)
        
        XCTAssertEqual(fetchedFormat, "dd MMMM yyyy")
        
    }
    func testObserverCalled() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImageListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        //then
        
        XCTAssertTrue(presenter.observe)
    }
}
final class ImageListViewControllerSpy: ImageListViewControllerProtocol {
    
    var presenter: ImageListViewPresenterProtocol
    
    
    init(presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
    }
    
    func updateTableViewAnimate() {
    
    }

}





final class ImageListViewPresenterSpy: ImageListViewPresenterProtocol {
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var observe = false
    var view: ImageFeed.ImageListViewControllerProtocol?
    let dateFormatted = DateFormatter()
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        observeAnimate()
    }
    
    func fetchDate(dateString: Date) -> String {
        var formattedDateString: String?
        dateFormatted.dateFormat = "dd MMMM yyyy"
        formattedDateString = dateFormatted.dateFormat
        guard let formattedDateString = formattedDateString else {
            return ""
        }
        return formattedDateString
    }
    
    func observeAnimate() {
        observe = true
    }
    
    
}


//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Diliara Sadrieva on 21.12.2024.
//

import Foundation
@testable import ImageFeed
import XCTest
final class ProfileTests: XCTestCase {
    func testProfileVCCallsViewDidLoad() {
        //given
        let profileService = ProfileService()
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        viewController.presenter = presenter
        presenter.view =  viewController
        
        //when
        _ = viewController.view
        
        //then
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testLogoutCalled() {
        //given
        let profileService = ProfileService()
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        let view = ProfileViewControllerSpy(presenter: presenter)
        view.presenter = presenter
        presenter.view = view
        
        //when
        
        view.showAlert()
        
        //then
        
        XCTAssertTrue(presenter.logoutCalled)
    }
    
    func testClean() {
        //given
        let profileService = ProfileService()
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        let view = ProfileViewControllerSpy(presenter: presenter)
        view.presenter = presenter
        presenter.view = view
        
        //when
        
        view.showAlert()
        
        //then
        
        XCTAssertTrue(presenter.cleanData)
    }
    
    func testFetchinProfileURL() {
        //given
        
        let presenter = ProfileViewPresenterSpy(profileService: ProfileService.shared)
        
        //when
        let url = presenter.fetchProfileURL().absoluteString
        
        //then
        
        XCTAssertEqual(url, "https://api.unsplash.com")
    }
    
    func testAvatarUpdating() {
        let profileService = ProfileService()
        let presenter = ProfileViewPresenterSpy(profileService: profileService)
        let view = ProfileViewControllerSpy(presenter: presenter)
        view.presenter = presenter
        presenter.view = view
        
        presenter.updateProfileDetails(profile: profileService.profile)
        
        XCTAssertTrue(view.viewSetup)
        XCTAssertTrue(view.constraints)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var viewDidLoadCalled = false
    var logoutCalled = false
    var cleanData = false
    var view: ProfileViewControllerProtocol?
    var presenter: ProfileViewPresenter?
    
    var profileService: ProfileService
    
    init(profileService: ProfileService) {
        self.profileService = profileService
    }
    
    func makeAlert() -> UIAlertController {
        UIAlertController()
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        view?.setupViews()
        view?.setupConstraints()
    }
    
    func logout() {
        clean()
        logoutCalled = true
        
    }
    
    func clean() {
        cleanData = true
    }
    
    func fetchProfileURL() -> URL {
        return URL(string: "https://api.unsplash.com")!
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol
    
    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
    }
    
    var avatarImageView = UIImageView()
    var nameLabel = UILabel()
    var loginNameLabel = UILabel()
    var descriptionLabel = UILabel()
    var alertCalled = false
    var viewSetup = false
    var constraints = false
    
    func updateAvatar(url: URL) {
    }
    
    func showAlert() {
        presenter.logout()
        alertCalled = true
    }
    
    func setupViews() {
        viewSetup = true
    }
    
    func setupConstraints() {
        constraints = true
    }
    
}

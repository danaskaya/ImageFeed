//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 12.12.2024.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol { get set }
    var avatarImageView: UIImageView { get set }
    var nameLabel: UILabel { get set }
    var loginNameLabel: UILabel { get set }
    var descriptionLabel: UILabel { get set }
    func updateAvatar(url: URL)
    func setupViews()
    func setupConstraints()
}

class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol = {
        return ProfileViewPresenter()
    }()
//    private let logoutButton = UIButton()
//    private let avatarImageView = UIImageView(image: UIImage(named: "avatar"))
//    private let nameLabel = UILabel()
//    private let loginNameLabel = UILabel()
//    private let descriptionLabel = UILabel()
//    private let profileService = ProfileService.shared
//    private let profileImageService = ProfileImageService.shared
//    private let oauthTokenStorage = Oauth2TokenStorage.shared
//    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        presenter.viewDidLoad()
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([avatarImageView.widthAnchor.constraint(equalToConstant: 70),
                                     avatarImageView.heightAnchor.constraint(equalToConstant: 70),
                                     avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                                     nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
                                     loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                                     descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
                                     logoutButton.widthAnchor.constraint(equalToConstant: 44),
                                     logoutButton.heightAnchor.constraint(equalToConstant: 44),
                                     logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
                                    ])
    }
    func updateAvatar(url: URL) {
        avatarImageView.kf.indicatorType = .activity
        let placeholderImage = UIImage(named: "placeholder")
        avatarImageView.kf.setImage(with: url, placeholder: placeholderImage, options: [])
    }
    func setupViews() {
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView(image: UIImage(named: "avatar"))
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 35
        return avatarImageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        return label
    }()
    
    var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    var descriptionLabel =  {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    
    var logoutButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!,
                                           target: self,
                                           action: #selector(logoutButtonAction)
        )
        button.accessibilityIdentifier = "logoutButton"
        button.tintColor = UIColor(named: "YP Red")
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    func showAlert() {
        let alert = presenter.makeAlert()
        present(alert, animated: true)
    }
    @objc func logoutButtonAction() {
        showAlert()
    }
}

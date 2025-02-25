//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 14.12.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = Oauth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    weak var webViewVC: WebViewViewController?
    private let imagesListService = ImagesListService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSplash()
        guard UIBlockingProgressHUD.isShowing == false else { return }
        if (storage.token != nil) {
            guard let token = storage.token else {return}
            fetchProfile(token: token)
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                assertionFailure("Failed to show Authentication Screen")
                return
            }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(named: "YP Black")
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupSplash() {
        let splashScreenLogo = UIImage(named: "auth_screen_logo")
        let imageView = UIImageView(image: splashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                                    ])
    }
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert(with: error)
                break
            }
        }
    }
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = profileService.profile?.username else { return }
                profileImageService.fetchProfileImageURL(token: token, username: username) { _ in }
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert(with: error)
                break
            }
        }
    }
    private func showAlert(with error: Error) {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel))
        self.present(alert, animated: true) {
            self.tabBarController?.dismiss(animated: true)
            guard let window = UIApplication.shared.windows.first else {
                fatalError("error")
            }
            window.rootViewController = SplashViewController()
        }
    }
}


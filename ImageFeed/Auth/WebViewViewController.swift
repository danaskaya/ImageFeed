//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 13.12.2024.
//

import UIKit
import WebKit


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    @IBOutlet var progressView: UIProgressView!
    private var estimatedProgressObsetvation :NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        estimatedProgressObsetvation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else {return}
                 self.updateProgress()
             })
        webView.navigationDelegate = self
        loadWebView()
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}
private extension WebViewViewController {
    func loadWebView() {
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        
        if let url = components?.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
extension WebViewViewController: WKNavigationDelegate {
    private func code(from url: URL?) -> String? {
        guard let url = url,
              let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems?.first(where: { $0.name == "code"}) else { return nil}
        return items.value
    }
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction.request.url) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

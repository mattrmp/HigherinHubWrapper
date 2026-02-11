//
//  CustomViewController.swift
//  App
//
//  Created by Matthew Meegan on 11/02/2026.
//

import UIKit
import WebKit
import Capacitor

final class CustomViewController: CAPBridgeViewController, WKNavigationDelegate {

    private let overlay = UIView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private var didHide = false

    override func viewDidLoad() {
        super.viewDidLoad()

        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.systemBackground
        overlay.isUserInteractionEnabled = true

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        view.addSubview(overlay)
        overlay.addSubview(spinner)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])

        // Safety: never block forever
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.hideOverlayAnimated()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView?.navigationDelegate = self
    }

    private func hideOverlayAnimated() {
        guard !didHide else { return }
        didHide = true

        UIView.animate(withDuration: 0.25, animations: {
            self.overlay.alpha = 0
        }, completion: { _ in
            self.overlay.removeFromSuperview()
        })
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }
}

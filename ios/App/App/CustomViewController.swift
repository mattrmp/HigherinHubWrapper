import UIKit
import WebKit
import Capacitor

final class CustomViewController: CAPBridgeViewController, WKNavigationDelegate, WKUIDelegate {

    private let overlay = UIView()
    private let logoView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let backButton = UIButton(type: .system)

    private var didHide = false
    private var overlayStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Floating Back button (doesn't use nav bar)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        backButton.addTarget(self, action: #selector(goBackToHome), for: .touchUpInside)

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        // Record overlay start time
        overlayStartTime = Date()

        // Overlay background
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.white
        overlay.isUserInteractionEnabled = true

        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Logo
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = UIImage(named: "LaunchLogo")
        logoView.contentMode = .scaleAspectFit

        overlay.addSubview(logoView)

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -30),
            logoView.widthAnchor.constraint(equalTo: overlay.widthAnchor, multiplier: 0.5),
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor)
        ])

        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.color = .gray

        overlay.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 20)
        ])

        // Safety timeout (never block forever)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.hideOverlayAnimated()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Keep navigation + new window links inside the WebView
        webView?.navigationDelegate = self
        webView?.uiDelegate = self

        // ✅ Fix for web UI hiding behind the notch / battery area
        webView?.scrollView.contentInsetAdjustmentBehavior = .always
    }

    private func hideOverlayAnimated() {
        guard !didHide else { return }
        didHide = true

        let minimumTime: TimeInterval = 1.0
        let elapsed = Date().timeIntervalSince(overlayStartTime ?? Date())
        let remaining = max(0, minimumTime - elapsed)

        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.alpha = 0
            }, completion: { _ in
                self.overlay.removeFromSuperview()
            })
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }

    // MARK: - WKUIDelegate
    // Keeps target="_blank" / window.open() inside the same WebView (no Safari)
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil,
           let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    // MARK: - Back button action

    @objc private func goBackToHome() {

        guard let webView = self.webView,
              let currentURL = webView.url else {
            return
        }

        let baHomeURLString = "https://higherinhub.com/home"

        // 1️⃣ If we can go back in web history, do that first
        if webView.canGoBack {
            webView.goBack()
            return
        }

        // 2️⃣ If we are NOT already on /home, load it
        if currentURL.absoluteString != baHomeURLString {
            if let url = URL(string: baHomeURLString) {
                webView.load(URLRequest(url: url))
            }
            return
        }

        // 3️⃣ If already on /home, go back to native app homepage
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        window.rootViewController = AmbassadorHomeViewController()
        window.makeKeyAndVisible()
    }
}

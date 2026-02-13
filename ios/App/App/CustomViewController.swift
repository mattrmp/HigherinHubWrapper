import UIKit
import WebKit
import Capacitor

final class CustomViewController: CAPBridgeViewController, WKNavigationDelegate {

    private let overlay = UIView()
    private let logoView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let backButton = UIButton(type: .system)

    private var didHide = false
    private var overlayStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation setup (only works when embedded in a UINavigationController)
        self.title = "Ambassador"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(goBackToHome)
        )
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
        webView?.navigationDelegate = self
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

    // WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideOverlayAnimated()
    }

    // Back button action
    @objc private func goBackToHome() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = AmbassadorHomeViewController()
            window.makeKeyAndVisible()
        }
    }
}

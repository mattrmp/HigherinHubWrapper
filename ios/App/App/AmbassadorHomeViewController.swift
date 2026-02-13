//
//  AmbassadorHomeViewController.swift
//  App
//
//  Created by Matthew Meegan on 11/02/2026.
//

import UIKit

final class AmbassadorHomeViewController: UIViewController {

    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Logo
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = UIImage(named: "LaunchLogo")
        logoView.contentMode = .scaleAspectFit

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Higherin Hub"
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .center

        // Login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login as Ambassador", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.layer.cornerRadius = 12
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        loginButton.backgroundColor = .label
        loginButton.setTitleColor(.systemBackground, for: .normal)
        loginButton.addTarget(self, action: #selector(openAmbassador), for: .touchUpInside)

        // Notification settings
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setTitle("Notification Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        settingsButton.addTarget(self, action: #selector(openAppSettings), for: .touchUpInside)

        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(loginButton)
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 18),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),

            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 18),
        ])
    }

    @objc private func openAmbassador() {
        // Mark that user has entered the ambassador app so next launch can skip home
        UserDefaults.standard.set(true, forKey: "didEnterAmbassador")

        // Swap root to web nav
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = WebNavController.make()
            window.makeKeyAndVisible()
        }
    }

    @objc private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

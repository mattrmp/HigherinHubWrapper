//
//  WebNavController.swift
//  App
//
//  Created by Matthew Meegan on 11/02/2026.
//
import UIKit

final class WebNavController {
    static func make() -> UINavigationController {
        let webVC = CustomViewController()
        let nav = UINavigationController(rootViewController: webVC)
        nav.setNavigationBarHidden(true, animated: false)   // 👈 hide native top bar
        return nav
    }
}

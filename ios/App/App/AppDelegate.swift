import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let didEnterAmbassador = UserDefaults.standard.bool(forKey: "didEnterAmbassador")

        if didEnterAmbassador {
            window?.rootViewController = WebNavController.make()
        } else {
            window?.rootViewController = AmbassadorHomeViewController()
        }

        window?.makeKeyAndVisible()
        return true
    }
}

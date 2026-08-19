// import Flutter
// import UIKit

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Alert code to be executed
    let alertController = UIAlertController(title: "Alert Title", message: "Your message here", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
        // Add any additional actions here
        print("OK button pressed")
    })
    
    // Access the root view controller and present the alert
    if let rootViewController = window?.rootViewController {
        rootViewController.present(alertController, animated: true, completion: nil)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

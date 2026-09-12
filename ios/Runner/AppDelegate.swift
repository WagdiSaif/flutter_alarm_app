import Flutter
import UIKit

@main
@available(iOS 17.0, *)
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//      GeneratedPluginRegistrant.register(withRegistry:a)
//      GeneratedPluginRegistrant.register(withRegistry:Any! )
      GeneratedPluginRegistrant.register(with: self)
      if let registrar = self.registrar(forPlugin: "LiveActivityPlugin"){
          LiveActivityPlugin.register(with: registrar)
          
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


}

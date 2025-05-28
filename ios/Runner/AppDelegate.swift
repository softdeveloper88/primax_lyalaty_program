import Flutter
import UIKit
import flutter_downloader

// Define a global C-compatible function
private func registerPluginsC(registry: FlutterPluginRegistry) {
  if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
    FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     GMSServices.provideAPIKey("AIzaSyDXCUC2HiimXAZ1kV25rT7wlmURbJUtE-o")

    GeneratedPluginRegistrant.register(with: self)

    // Using @convention(c) closure to ensure C compatibility
    let callback: @convention(c) (FlutterPluginRegistry) -> Void = { registry in
      registerPluginsC(registry: registry)
    }

    FlutterDownloaderPlugin.setPluginRegistrantCallback(callback)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

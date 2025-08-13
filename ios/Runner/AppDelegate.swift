import Flutter
import UIKit
import ICSmartUX

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    //===[START] Cấu hình SDK ICSmartUX ===
      let hostICSmartUX = "" // url của server ICSmartUX
      let appKey = "" // app key của app
      let urlUploadImage = "" // url upload image
      let urlUploadEvents = "" // url upload events
      
      let icSmarUX = ICSmartUX.init(host: hostICSmartUX, appKey: appKey)
      
      icSmarUX.urlUploadImage = urlUploadImage
      icSmarUX.urlUploadEvents = urlUploadEvents
      
      icSmarUX.isPrintLog = true // xem log trên console khi chạy app bằng xcode
      icSmarUX.timeUploadEvent = 10
      icSmarUX.isAutoViewTracking = true
      icSmarUX.start()
    //===[END] Cấu hình SDK ICSmartUX ====

    //===[START] Triển khai phương thức ICSmartUX ====
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }
    let icSmartUXChannel = FlutterMethodChannel(name: "com.yourcompany.yourapp/icsmartux",
                                                binaryMessenger: controller.binaryMessenger)

    icSmartUXChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are not a dictionary", details: nil))
          return
      }
      
      // Kiểm tra tên phương thức được gọi
      switch call.method {
      case "trackingNavigationScreen":
        if let screenName = args["name"] as? String {
            // Gọi hàm native tương ứng
            ICSmartUX.trackingNavigationScreen(name: screenName)
            result("Success from trackingNavigationScreen")
        } else {
            result(FlutterError(code: "MISSING_PARAM", message: "Parameter 'name' is required", details: nil))
        }

      case "trackingNavigationEnter":
        if let screenName = args["name"] as? String {
            let timeDelay = args["timeDelay"] as? Double ?? 0.2
            let forceUpload = args["forceUpload"] as? Bool ?? false
            // Gọi hàm native tương ứng
            ICSmartUX.trackingNavigationEnter(name: screenName, timeDelay: timeDelay, forceUpload: forceUpload)
            result("Success from trackingNavigationEnter")
        } else {
            result(FlutterError(code: "MISSING_PARAM", message: "Parameter 'name' is required", details: nil))
        }

      default:
        // Trả về lỗi nếu không tìm thấy phương thức
        result(FlutterMethodNotImplemented)
      }
    })
    
    //===[END] Triển khai phương thức ICSmartUX ====

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

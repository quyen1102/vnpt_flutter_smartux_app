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
        let hostICSmartUX = "https://console-smartux.vnpt.vn" // url của server ICSmartUX
        let appKey = "<APP_KEY>" // app key của app
        let urlUploadImage = "https://console-smartux.vnpt.vn/collector/mobile/heatmap-image" // url upload image
        let urlUploadEvents = "https://console-smartux.vnpt.vn/collector/mobile/heatmap-event" // url upload events
        
        let icSmartUX = ICSmartUX.init(host: hostICSmartUX, appKey: appKey)
        
        icSmartUX.urlUploadImage = urlUploadImage
        icSmartUX.urlUploadEvents = urlUploadEvents
        icSmartUX.platform = .Flutter
        icSmartUX.isPrintLog = true // xem log trên console khi chạy app bằng xcode
        icSmartUX.timeUploadEvent = 120
        icSmartUX.isShowToastTracking = false;
        icSmartUX.isAutoViewTracking = false;
        icSmartUX.start()
        //===[END] Cấu hình SDK ICSmartUX ====
        
        // setup rotation
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // setup method channel bridge delegate
        setupMethodChannel()
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupMethodChannel() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.vnpt.ai.ic/SmartUX",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard let strongSelf = self else { return }
            guard let args = call.arguments as? [String: Any] else { return }
            switch call.method {
            case "addCrashLog":
                strongSelf.addCrashLog(args: args)
            case "logException":
                strongSelf.logException(args: args)
            case "logFlutterException":
                strongSelf.logFlutterException(args: args)
            case "event":
                strongSelf.event(args: args)
            case "startEvent":
                strongSelf.startEvent(args: args)
            case "cancelEvent":
                strongSelf.cancelEvent(args: args)
            case "endEvent":
                strongSelf.endEvent(args: args)
            case "recordView":
                strongSelf.recordView(args: args)
            case "recordAction":
                strongSelf.recordAction(args: args)
            case "trackingNavigationEnter":
                strongSelf.trackingNavigationEnter(args: args)
            case "trackingNavigationScreen":
                strongSelf.trackingNavigationScreen(args: args)
            case "makeScreenshot":
                strongSelf.makeScreenshot(args: args)
            case "setUserData":
                strongSelf.setUserData(args: args)
            case "recordFlow":
                strongSelf.recordFlow(args: args)
            default:
                break
            }
        })
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ICSmartUX.onChangeOrientation(newOrientation: .Landscape)
        } else if UIDevice.current.orientation.isPortrait {
            ICSmartUX.onChangeOrientation(newOrientation: .Portrait)
        }
    }
    
    private func addCrashLog(args: [String: Any]) {
        guard let record = args["record"] as? String else { return }
        ICSmartUX.recordCrashLog(log: record)
    }
    
    private func logException(args: [String: Any]) {
        guard let exceptionString = args["exception"] as? String else { return }
        let exception = NSException(name: NSExceptionName(rawValue: exceptionString), reason: nil)
        ICSmartUX.recordHandledException(exception: exception)
    }
    
    private func logFlutterException(args: [String: Any]) {
        guard let error = args["err"] as? String,
              let message = args["message"] as? String,
              let stack = args["stack"] as? String else { return }
        let exception = NSException(name: NSExceptionName(rawValue: error), reason: message)
        ICSmartUX.recordCrashLog(log: stack)
        ICSmartUX.recordHandledException(exception: exception)
    }
    
    private func event(args: [String: Any]) {
        guard let eventType = args["eventType"] as? String else { return }
        switch eventType {
        case "event":
            guard let eventName = args["eventName"] as? String,
                  let eventCount = args["eventCount"] as? Int else { return }
            ICSmartUX.recordEvent(eventName: eventName, count: UInt(eventCount))
        case "eventWithSum":
            guard let eventName = args["eventName"] as? String,
                  let eventCount = args["eventCount"] as? Int,
                  let eventSum = args["eventSum"] as? Double else { return }
            ICSmartUX.recordEvent(eventName: eventName, count: UInt(eventCount), sum: eventSum)
        case "eventWithSegment":
            guard let eventName = args["eventName"] as? String,
                  let segmentation = args["segmentation"] as? [String : String],
                  let eventCount = args["eventCount"] as? Int else { return }
            ICSmartUX.recordEvent(eventName: eventName, segmentation: segmentation, count: UInt(eventCount))
        case "eventWithSumSegment":
            guard let eventName = args["eventName"] as? String,
                  let segmentation = args["segmentation"] as? [String : String],
                  let eventCount = args["eventCount"] as? Int,
                  let eventSum = args["eventSum"] as? Double else { return }
            ICSmartUX.recordEvent(eventName: eventName, segmentation: segmentation, count: UInt(eventCount), sum: eventSum)
        default:
            break
        }
    }
    
    private func endEvent(args: [String: Any]) {
        guard let eventType = args["eventType"] as? String else { return }
        switch eventType {
        case "event":
            guard let eventName = args["eventName"] as? String else { return }
            ICSmartUX.endEvent(eventName: eventName)
        case "eventWithSum":
            guard let eventName = args["eventName"] as? String,
                  let eventCount = args["eventCount"] as? Int,
                  let eventSum = args["eventSum"] as? Double else { return }
            ICSmartUX.endEvent(eventName: eventName, segmentation: nil, count: UInt(eventCount), sum: eventSum)
        case "eventWithSegment":
            guard let eventName = args["eventName"] as? String,
                  let segmentation = args["segmentation"] as? [String : String],
                  let eventCount = args["eventCount"] as? Int else { return }
            ICSmartUX.endEvent(eventName: eventName, segmentation: segmentation, count: UInt(eventCount), sum: 0.0)
        case "eventWithSumSegment":
            guard let eventName = args["eventName"] as? String,
                  let segmentation = args["segmentation"] as? [String : String],
                  let eventCount = args["eventCount"] as? Int,
                  let eventSum = args["eventSum"] as? Double else { return }
            ICSmartUX.endEvent(eventName: eventName, segmentation: segmentation, count: UInt(eventCount), sum: eventSum)
        default:
            break
        }
    }
    
    private func startEvent(args: [String: Any]) {
        guard let eventName = args["startEvent"] as? String else { return }
        ICSmartUX.startEvent(eventName: eventName)
    }
    
    private func cancelEvent(args: [String: Any]) {
        guard let eventName = args["cancelEvent"] as? String else { return }
        ICSmartUX.cancelEvent(eventName: eventName)
    }
    
    private func trackingNavigationEnter(args: [String: Any]) {
        guard let screenName = args["screenName"] as? String else { return }
        ICSmartUX.trackingNavigationEnter(name: screenName)
    }
    
    private func trackingNavigationScreen(args: [String: Any]) {
        guard let screenName = args["screenName"] as? String else { return }
        ICSmartUX.trackingNavigationScreen(name: screenName)
    }
    
    private func makeScreenshot(args: [String: Any]) {
        guard let screenName = args["screenName"] as? String else { return }
        ICSmartUX.makeScreenshotOutSide(name: screenName)
    }
    
    private func recordView(args: [String: Any]) {
        guard let screenName = args["screenName"] as? String else { return }
        let segmentation = args["segmentation"] as? [String : String]
        ICSmartUX.recordViewOutSide(name: screenName, segmentation: segmentation ?? [:])
    }
    
    private func recordAction(args: [String: Any]) {
        guard let actionId = args["actionId"] as? String,
              let actionName = args["actionName"] as? String,
              let screenName = args["screenName"] as? String else { return }
        ICSmartUX.recordAction(actionId: actionId, actionName: actionName, screenName: screenName)
    }
    
    private func setUserData(args: [String: Any]) {
        guard let userId = args["userId"] as? String,
              let userData = args["userDataMap"] as? [String: Any] else { return }
        ICSmartUX.setUserData(userId: userId, userData: userData)
    }
    private func recordFlow(args: [String: Any]){
        guard let screenName = args["screenName"] as? String else { return }
        ICSmartUX.recordFlow(screenName: screenName)
    }
}

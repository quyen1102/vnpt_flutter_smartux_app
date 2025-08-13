# Tích hợp ICSmartUX SDK cho Flutter

Tài liệu này hướng dẫn cách tích hợp và cấu hình ICSmartUX SDK trong dự án Flutter. Phần native (iOS) khởi tạo SDK và cung cấp bridge qua MethodChannel; phía Flutter dùng wrapper `SmartUX` và `SmartUXObserver` để theo dõi màn hình và gửi sự kiện.

---

## 1. Cài đặt SDK (iOS - AppDelegate)

Vị trí: `ios/Runner/AppDelegate.swift`

```swift
import Flutter
import UIKit
import ICSmartUX

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Cấu hình SDK ICSmartUX
        let hostICSmartUX = "https://console-smartux.vnpt.vn"
        let appKey = "<APP_KEY>"
        let urlUploadImage = "https://console-smartux.vnpt.vn/collector/mobile/heatmap-image"
        let urlUploadEvents = "https://console-smartux.vnpt.vn/collector/mobile/heatmap-event"

        let icSmartUX = ICSmartUX.init(host: hostICSmartUX, appKey: appKey)
        icSmartUX.urlUploadImage = urlUploadImage
        icSmartUX.urlUploadEvents = urlUploadEvents
        icSmartUX.platform = .Flutter
        icSmartUX.isPrintLog = true
        icSmartUX.timeUploadEvent = 120
        icSmartUX.isShowToastTracking = false
        icSmartUX.isAutoViewTracking = false
        icSmartUX.start()

        // Lắng nghe thay đổi xoay màn hình để đồng bộ với SDK
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppDelegate.rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        // Khởi tạo bridge Flutter <-> iOS qua MethodChannel
        setupMethodChannel()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ICSmartUX.onChangeOrientation(newOrientation: .Landscape)
        } else if UIDevice.current.orientation.isPortrait {
            ICSmartUX.onChangeOrientation(newOrientation: .Portrait)
        }
    }

    private func setupMethodChannel() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.vnpt.ai.ic/SmartUX",
                                           binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard let strongSelf = self, let args = call.arguments as? [String: Any] else { return }
            switch call.method {
            case "addCrashLog": strongSelf.addCrashLog(args: args)
            case "logException": strongSelf.logException(args: args)
            case "logFlutterException": strongSelf.logFlutterException(args: args)
            case "event": strongSelf.event(args: args)
            case "startEvent": strongSelf.startEvent(args: args)
            case "cancelEvent": strongSelf.cancelEvent(args: args)
            case "endEvent": strongSelf.endEvent(args: args)
            case "recordView": strongSelf.recordView(args: args)
            case "recordAction": strongSelf.recordAction(args: args)
            case "trackingNavigationEnter": strongSelf.trackingNavigationEnter(args: args)
            case "trackingNavigationScreen": strongSelf.trackingNavigationScreen(args: args)
            case "makeScreenshot": strongSelf.makeScreenshot(args: args)
            case "setUserData": strongSelf.setUserData(args: args)
            case "recordFlow": strongSelf.recordFlow(args: args)
            default: break
            }
        })
    }
}
```

Lưu ý: Dòng cấu hình quan trọng `icSmartUX.platform = .Flutter` giúp SDK hoạt động đúng trong môi trường Flutter.

---

## 2. Theo dõi điều hướng (Flutter) bằng `SmartUXObserver`

SDK không thể tự động nhận diện các sự kiện chuyển màn hình trong Flutter. Dự án đã có sẵn `SmartUXObserver` để tự động ghi nhận màn hình mới mỗi khi `Route` được đẩy vào.

Vị trí: `lib/route_observer.dart`

- Khi `didPush`: tự động gọi `recordView` và `trackingNavigationScreen` với tên màn hình.
- Khi `didPop`: giữ nguyên (có thể mở rộng nếu cần theo dõi).

Cách sử dụng: thêm vào `navigatorObservers` của `MaterialApp`:

```dart
MaterialApp(
  navigatorObservers: [SmartUXObserver()],
  // ...
)
```

Nếu bạn cần chụp ảnh màn hình phục vụ heatmap cho một màn hình cụ thể, hãy gọi thủ công sau khi frame đầu tiên render xong:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SmartUX.instance.trackingNavigationEnter(screenName: 'SecondaryScreen');
  });
}
```


Nếu screen có hiệu ứng animation, hãy tăng timeDelay
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SmartUX.instance.trackingNavigationEnter(screenName: 'SecondaryScreen', timeDelay: 0.5);
  });
}
```
---

## 3. Sử dụng API Flutter (`SmartUX`)

Wrapper `SmartUX` đã đóng gói các lời gọi qua `MethodChannel` `com.vnpt.ai.ic/SmartUX`. Các phương thức chính hiện có:

- Theo dõi màn hình
  - `recordView({required String screenName, Map<String, dynamic>? segmentation})`
  - `trackingNavigationScreen({required String screenName})`
  - `trackingNavigationEnter({required String screenName})` (có chụp ảnh màn hình sau khi vào)
  - `recordFlow({required String screenName})`

- Sự kiện
  - `sendEvent({required String eventName, int? eventCount, double? eventSum, Map<String, dynamic>? segmentation})`
  - `startEvent({required String startEvent})`
  - `endEvent({required String eventName, int? eventCount, double? eventSum, Map<String, dynamic>? segmentation})`
  - `cancelEvent({required String cancelEvent})`

- Log/Crash
  - `addCrashLog({required String record})`
  - `logException({required String exception})`
  - `logFlutterException({required String err, required String message, required String stack})`

- User
  - `setUserData({required Map<String, dynamic> userDataMap})`

Ví dụ nhanh trong `HomePage`:

```dart
// Gửi sự kiện đơn giản
await SmartUX.instance.sendEvent(eventName: 'Basic Event', eventCount: 1);

// Theo dõi view + flow
await SmartUX.instance.recordView(screenName: 'HomePage');
await SmartUX.instance.trackingNavigationScreen(screenName: 'HomePage');

// Hành động (button click...)
await SmartUX.instance.recordAction(
  actionId: 'floating_action_button',
  actionName: 'Floating Action Button',
  screenName: 'HomePage',
);
```

---

## 4. Ghi chú triển khai

- Bridge iOS đang lắng nghe các method: `addCrashLog`, `logException`, `logFlutterException`, `event`, `startEvent`, `cancelEvent`, `endEvent`, `recordView`, `recordAction`, `trackingNavigationEnter`, `trackingNavigationScreen`, `makeScreenshot`, `setUserData`, `recordFlow`.
- `SmartUXObserver` hiện tự động gọi `recordView` và `trackingNavigationScreen` trong `didPush`. Nếu cần heatmap/screenshot hãy gọi thêm `trackingNavigationEnter` theo thời điểm phù hợp (sau render).
- Có thể mở rộng `didPop`/`didPopNext` để ghi nhận luồng quay lại nếu cần.

---

## 5. Khuyến nghị

- Đặt tên `screenName` thống nhất giữa các màn hình để dữ liệu dễ phân tích.
- Tăng `timeDelay` (nếu bổ sung tham số sau này) khi màn hình có animation nặng trước khi chụp heatmap.
- Kiểm tra log console khi debug iOS (`isPrintLog = true`) để xác thực các lệnh gọi.

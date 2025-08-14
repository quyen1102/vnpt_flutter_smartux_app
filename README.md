# Tích hợp ICSmartUX SDK cho Flutter

Tài liệu này hướng dẫn cách tích hợp và cấu hình ICSmartUX SDK trong dự án Flutter. Phần native (iOS/Android) khởi tạo SDK và cung cấp bridge qua MethodChannel; phía Flutter dùng wrapper `SmartUX` và `SmartUXObserver` để theo dõi màn hình và gửi sự kiện.

## Mục lục

- [Tích hợp ICSmartUX SDK cho Flutter](#tích-hợp-icsmartux-sdk-cho-flutter)
  - [Mục lục](#mục-lục)
  - [1. Cài đặt SDK (iOS - AppDelegate)](#1-cài-đặt-sdk-ios---appdelegate)
    - [1.1. Thêm SDK vào dự án iOS](#11-thêm-sdk-vào-dự-án-ios)
    - [1.2. Cấu hình khởi tạo SDK trong AppDelegate](#12-cấu-hình-khởi-tạo-sdk-trong-appdelegate)
    - [1.3. Cấu hình MethodChannel (Flutter \<-\> iOS)](#13-cấu-hình-methodchannel-flutter---ios)
  - [2. Cài đặt SDK (Android)](#2-cài-đặt-sdk-android)
    - [2.1. Thêm dependency (Gradle)](#21-thêm-dependency-gradle)
    - [2.2. Khởi tạo SDK trong `Application`](#22-khởi-tạo-sdk-trong-application)
    - [2.3. Bridge Flutter \<-\> Android trong `MainActivity`](#23-bridge-flutter---android-trong-mainactivity)
  - [3.\[Bắt buộc\] Theo dõi điều hướng (Flutter) bằng SmartUXObserver](#3bắt-buộc-theo-dõi-điều-hướng-flutter-bằng-smartuxobserver)
  - [4. Sử dụng API Flutter (`SmartUX`)](#4-sử-dụng-api-flutter-smartux)
  - [5. Tham chiếu MethodChannel và chức năng](#5-tham-chiếu-methodchannel-và-chức-năng)
  - [6. Khuyến nghị](#6-khuyến-nghị)

---

## 1. Cài đặt SDK (iOS - AppDelegate)

### 1.1. Thêm SDK vào dự án iOS

- Mở `ios/Runner.xcworkspace` bằng Xcode.
- Thêm `ICSmartUX.xcframework` vào mục `Runner` nếu chưa có. Trong dự án mẫu, SDK đã được đặt sẵn tại: `ios/Runner/SDK/ICSmartUX.xcframework`.
- Trong tab `General` của target `Runner`:
  - Kéo thả `ICSmartUX.xcframework` vào mục `Frameworks, Libraries, and Embedded Content`.
  - Thiết lập `Embed & Sign` cho framework.

### 1.2. Cấu hình khởi tạo SDK trong AppDelegate

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

### 1.3. Cấu hình MethodChannel (Flutter <-> iOS)

- Tên kênh: `com.vnpt.ai.ic/SmartUX`
- Các phương thức được lắng nghe: xem [Tham chiếu MethodChannel và chức năng](#5-tham-chiếu-methodchannel-và-chức-năng).


## 2. Cài đặt SDK (Android)

### 2.1. Thêm dependency (Gradle)

Thêm kho và phụ thuộc AAR (ví dụ `smart-ux-v1.1.2.aar`) vào Android project.

- File `android/build.gradle.kts`:

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("$rootDir/libs")
        }
    }
}
```

- File `android/app/build.gradle.kts`:

```kotlin
dependencies {
    implementation(files("$rootDir/libs/smart-ux-v1.1.2.aar"))
}
```

### 2.2. Khởi tạo SDK trong `Application`

Tạo `MainApplication.kt` (hoặc dùng Application hiện có) và khởi tạo SDK trong `onCreate`.

Vị trí: `android/app/src/main/kotlin/.../MainApplication.kt`

```kotlin
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // app key/project key lấy từ trang quản trị
        SmartUX.init(
            application = this,
            domain = "https://console-smartux.vnpt.vn",
            projectKey = "<PROJECT_KEY>",
            isDisableUploadImage = DisableUploadImage.NO
        )
    }
}
```

Khai báo `application` trong `AndroidManifest.xml`:

```xml
<application
    android:name= ".MainApplication"
    ...>
</application>
```

### 2.3. Bridge Flutter <-> Android trong `MainActivity`

Vị trí: `android/app/src/main/kotlin/.../MainActivity.kt`

- Tên kênh: `com.vnpt.ai.ic/SmartUX`
- Lắng nghe các method: `addCrashLog`, `logException`, `logFlutterException`, `event`, `startEvent`, `cancelEvent`, `endEvent`, `setUserData`, `recordView`, `recordUserFlow`, `recordAction`, `start`, `stop`, `makeScreenshot`, `trackingNavigationEnter`, `trackingNavigationScreen`.
- Đồng bộ vòng đời: tự động `start()` trong `onResume` và `stop()` trong `onPause`.
- Đồng bộ xoay màn hình: override `onConfigurationChanged` và gọi `SmartUX.onConfigurationChanged(newConfig)`.

Ví dụ rút gọn:

```kotlin
class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    companion object { const val METHOD_CHANNEL_NAME = "com.vnpt.ai.ic/SmartUX" }

    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Xử lý các method: addCrashLog, logException, logFlutterException, event, ...
        }
    }

    override fun onResume() {
        super.onResume()
        if (SmartUX.isInitialized()) start()
    }

    override fun onPause() {
        super.onPause()
        if (SmartUX.isInitialized()) stop()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        SmartUX.onConfigurationChanged(newConfig)
    }
}
```

---

## 3.[Bắt buộc] Theo dõi điều hướng (Flutter) bằng SmartUXObserver

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

## 4. Sử dụng API Flutter (`SmartUX`)
Ví dụ nhanh trong `HomePage`:

```dart
// Các phương thức tham khảo
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

## 5. Tham chiếu MethodChannel và chức năng

Bảng tham chiếu ngắn gọn cho các phương thức qua kênh `com.vnpt.ai.ic/SmartUX` và chức năng của chúng. Khác biệt nền tảng (iOS/Android) được ghi chú ngắn gọn.

- addCrashLog(record: String)
  - Ghi breadcrumb vào hệ thống log crash.
  - iOS/Android: hỗ trợ.

- logException(exception: String)
  - Ghi nhận một exception đã được xử lý (handled) với tên/chuỗi exception.
  - iOS/Android: hỗ trợ.

- logFlutterException(err: String, message: String, stack: String)
  - Ghi breadcrumb stack Flutter và đánh dấu exception Flutter đã xử lý.
  - iOS/Android: hỗ trợ.

- event(...)
  - Ghi sự kiện tuỳ theo biến thể:
    - event: `eventName`, `eventCount`
    - eventWithSum: `eventName`, `eventCount`, `eventSum`
    - eventWithSegment: `eventName`, `segmentation`, `eventCount`
    - eventWithSumSegment: `eventName`, `segmentation`, `eventCount`, `eventSum`
  - iOS/Android: hỗ trợ đầy đủ các biến thể.

- startEvent(startEvent: String)
  - Bắt đầu sự kiện tính thời gian.
  - iOS/Android: hỗ trợ.

- cancelEvent(cancelEvent: String)
  - Huỷ sự kiện tính thời gian (nếu không muốn gửi).
  - iOS/Android: hỗ trợ.

- endEvent(eventName: String, [segmentation], [eventCount], [eventSum])
  - Kết thúc sự kiện tính thời gian; có thể kèm phân đoạn và số/sum.
  - iOS/Android: hỗ trợ các biến thể tương ứng với `event`.

- recordView(screenName: String, segmentation?: Map)
  - Ghi nhận người dùng xem màn hình `screenName`, có thể kèm segmentation.
  - iOS/Android: hỗ trợ.

- recordUserFlow(view: String, from: String)
  - Ghi nhận luồng chuyển màn hình thủ công (Android).
  - iOS: không dùng; iOS có `recordFlow(screenName: String)`.

- recordFlow(screenName: String)
  - Ghi nhận luồng màn hình (iOS).
  - Android: dùng `recordUserFlow` thay thế.

- recordAction(actionId?: String, actionName?: String, screenName?: String)
  - Ghi nhận hành vi (nhấn nút, tương tác) trên màn hình.
  - iOS/Android: hỗ trợ.

- trackingNavigationScreen(screenName: String)
  - Cập nhật màn hình hiện tại trong SDK, kích hoạt cập nhật khảo sát nếu có; không chụp ảnh màn hình.
  - iOS/Android: hỗ trợ.

- trackingNavigationEnter(screenName: String, timeDelay?: Double, forceUpload?: Bool)
  - Thực hiện như `trackingNavigationScreen` và CHỤP ảnh màn hình phục vụ heatmap.
  - iOS: hỗ trợ `timeDelay` (mặc định 0.2s) và `forceUpload`.
  - Android: dùng giá trị mặc định trong SDK; tham số phụ có thể bị bỏ qua bởi bridge hiện tại.

- makeScreenshot(screenName: String)
  - Chụp ảnh màn hình tức thời cho `screenName` (ngoài luồng điều hướng).
  - iOS/Android: hỗ trợ.

- setUserData(userId: String, userDataMap: Map)
  - Gửi thông tin người dùng.
  - Android: dùng cả `userId` và `userDataMap`.
  - iOS: hiện sử dụng `userDataMap`; `userId` có thể bị bỏ qua bởi bridge.

- start(), stop()
  - Điều khiển phiên theo vòng đời ứng dụng.
  - Android: hỗ trợ qua bridge (được gọi trong `onResume`/`onPause`).
  - iOS: không xử lý qua MethodChannel (SDK tự quản lý sau `start()`).

---

## 6. Khuyến nghị

- Đặt tên `screenName` thống nhất giữa các màn hình để dữ liệu dễ phân tích.
- Tăng `timeDelay` khi màn hình có animation nặng trước khi chụp heatmap.
- Kiểm tra log console khi debug iOS (`isPrintLog = true`) và Android Logcat để xác thực các lệnh gọi.

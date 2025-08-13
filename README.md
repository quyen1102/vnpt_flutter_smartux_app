# Tích hợp ICSmartUX SDK cho Flutter

Tài liệu này hướng dẫn cách tích hợp và cấu hình ICSmartUX SDK trong một dự án Flutter. Do đặc thù của cross-platform, việc tích hợp đòi hỏi một số bước cấu hình ở phía native (iOS) và gọi chủ động các phương thức theo dõi từ phía Flutter.

---

## 1. Cài đặt SDK (Phía Native - iOS)

Trước tiên, bạn cần khởi tạo SDK trong file `AppDelegate.swift` của project iOS.

**Vị trí:** `ios/Runner/AppDelegate.swift`

Thêm đoạn mã sau vào trong phương thức `application(_:didFinishLaunchingWithOptions:)`:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let hostICSmartUX = "https://"
    let appKey = "55040710cf7b0a1a245"
    let urlUploadImage = "https://" 
    let urlUploadEvents = "https://"
    
  
    let icSmarUX = ICSmartUX.init(host: hostICSmartUX, appKey: appKey)
    
  
    icSmarUX.urlUploadImage = urlUploadImage
    icSmarUX.urlUploadEvents = urlUploadEvents
    icSmarUX.isPrintLog = true 
    icSmarUX.timeUploadEvent = 10 
    icSmarUX.isAutoViewTracking = true

    icSmarUX.start()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 2. Tích hợp theo dõi điều hướng (Flutter)

### Tổng quan

Vì SDK không thể tự động nhận diện các sự kiện chuyển màn hình trong Flutter, bạn cần phải chủ động thông báo cho SDK mỗi khi người dùng điều hướng tới một màn hình mới. Điều này được thực hiện bằng cách gọi các phương thức native đã được cung cấp sẵn thông qua `MethodChannel`.

### Các phương thức chính

Có hai phương thức để theo dõi điều hướng, được định nghĩa sẵn trong SDK:

#### `trackingNavigationScreen(name: String)`

Phương thức này thực hiện các tác vụ cơ bản để ghi nhận một màn hình mới.

* **Chức năng:**
    * Cập nhật màn hình hiện tại (`currentController`) sang `name` mới.
    * Ghi nhận luồng điều hướng của người dùng (user flow) khi tên màn hình thay đổi.
    * Ẩn các khảo sát (survey) đang hiển thị và tải các khảo sát mới tương ứng với màn hình `name` (nếu tính năng survey được bật).
* **Lưu ý:** Phương thức này **không** chụp ảnh màn hình.

#### `trackingNavigationEnter(name: String, timeDelay: Double = 0.2, forceUpload: Bool = false)`

Phương thức này làm tất cả những gì `trackingNavigationScreen` làm, và bổ sung thêm chức năng chụp ảnh màn hình để phục vụ cho tính năng heatmap.

* **Chức năng:**
    * Thực hiện toàn bộ các tác vụ của `trackingNavigationScreen`.
    * **Chụp ảnh màn hình** sau một khoảng trễ `timeDelay` (mặc định là 0.2 giây).
* **Tham số:**
    * `name`: Tên định danh của màn hình.
    * `timeDelay` (tùy chọn): Thời gian chờ (giây) trước khi chụp ảnh. Tăng giá trị này cho các màn hình có nhiều animation hoặc cần thời gian render lâu.
    * `forceUpload` (tùy chọn): Nếu `true`, SDK sẽ chụp và upload lại ảnh màn hình ngay cả khi đã có ảnh trước đó cho màn hình này.

### Khi nào và làm thế nào để gọi trong Flutter?

**Quy tắc ngắn gọn:**

> * Nếu bạn **chỉ cần theo dõi luồng người dùng và khảo sát**, hãy gọi `trackingNavigationScreen`.
> * Nếu bạn **cần thêm ảnh màn hình cho heatmap**, hãy gọi `trackingNavigationEnter`.

**Thời điểm gọi lý tưởng:**

Bạn nên gọi các phương thức này ngay sau khi một màn hình mới đã được render hoàn chỉnh và hiển thị cho người dùng. Cách tiếp cận tốt nhất trong Flutter là sử dụng `RouteObserver` kết hợp với `RouteAware`.

1.  **Sử dụng `RouteObserver` và `RouteAware`:**
    * Trong các sự kiện `didPush` (khi mở màn hình mới) và `didPopNext` (khi quay lại màn hình), hãy gọi phương thức tương ứng.
2.  **Sử dụng `addPostFrameCallback`:**
    * Đây là một giải pháp thay thế, đảm bảo lệnh gọi được thực thi sau khi frame đầu tiên của widget được vẽ xong.

    ```dart
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
       
      });
    }
    ```

### Ví dụ (Ý tưởng triển khai)

Bạn sẽ cần thiết lập một `MethodChannel` để giao tiếp từ Dart tới code native Swift. Dưới đây là ý tưởng về cách bạn sẽ gọi nó trong widget của mình.

Giả sử bạn đã có một custom hook hoặc một mixin tên là `useFocusRouteAware` để lắng nghe sự kiện route:

```dart
// Trong một StatefullWidget hoặc sử dụng một custom hook
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  
  // Giả sử bạn đã thiết lập RouteObserver
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Màn hình vừa được đẩy vào, gọi tracking
    // Giả sử `ICSmartUXChannel` là class quản lý MethodChannel của bạn
    ICSmartUXChannel.trackingNavigationEnter(
      name: 'HomeScreen', 
      timeDelay: 0.3 // Tăng delay nếu màn hình có animation
    );
  }

  @override
  void didPopNext() {
    // Quay lại màn hình này từ một màn hình khác
    ICSmartUXChannel.trackingNavigationEnter(name: 'HomeScreen');
  }

  // ... build method
}

import 'package:flutter/services.dart';

class ICSmartUXChannel {
  static const MethodChannel _channel = MethodChannel(
    'com.yourcompany.yourapp/icsmartux',
  );

  /// Thông báo cho SDK rằng một màn hình mới đã được hiển thị.
  ///
  /// Phương thức này chỉ theo dõi luồng người dùng và khảo sát, không chụp ảnh màn hình.
  ///
  /// - [name]: Tên định danh của màn hình.
  static Future<void> trackingNavigationScreen({required String name}) async {
    try {
      await _channel.invokeMethod('trackingNavigationScreen', {'name': name});
    } on PlatformException catch (e) {
      print("Failed to track screen: '${e.message}'.");
    }
  }

  /// Thông báo cho SDK rằng một màn hình mới đã được hiển thị và chụp ảnh màn hình.
  ///
  /// Phương thức này dùng để theo dõi luồng người dùng, khảo sát và heatmap.
  ///
  /// - [name]: Tên định danh của màn hình.
  /// - [timeDelay]: Thời gian chờ (giây) trước khi chụp ảnh. Mặc định là 0.2s.
  /// - [forceUpload]: Nếu `true`, sẽ chụp và upload lại ảnh ngay cả khi đã có.
  static Future<void> trackingNavigationEnter({
    required String name,
    double timeDelay = 0.2,
    bool forceUpload = false,
  }) async {
    try {
      await _channel.invokeMethod('trackingNavigationEnter', {
        'name': name,
        'timeDelay': timeDelay,
        'forceUpload': forceUpload,
      });
    } on PlatformException catch (e) {
      print("Failed to track screen with screenshot: '${e.message}'.");
    }
  }
}

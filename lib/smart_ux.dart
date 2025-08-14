import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmartUX {
  static final SmartUX _singleton = SmartUX._internal();

  /// Gets the only running instance of SmartUX SDK.
  static SmartUX get instance {
    return _singleton;
  }

  SmartUX._internal();

  Future<void> enableAutoTracking() async {
    await Channels.smartUX.invokeMethodOnMobile<void>("enableAutoTracking");
  }

  Future<void> addCrashLog({required String record}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("addCrashLog", {
      "record": record,
    });
  }

  Future<void> logException({required String exception}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("logException", {
      "exception": exception,
    });
  }

  Future<void> logFlutterException({
    required String err,
    required String message,
    required String stack,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("logFlutterException", {
      "err": err,
      "message": message,
      "stack": stack,
    });
  }

  Future<void> sendEvent({
    required String eventName,
    int? eventCount,
    double? eventSum,
    Map<String, dynamic>? segmentation,
  }) async {
    String? eventType;
    var args = <String, dynamic>{};

    if (eventCount != null) {
      eventType = "event";
      args = {"eventCount": eventCount};
    }

    if (eventCount != null && eventSum != null) {
      eventType = "eventWithSum";
      args = {"eventCount": eventCount, "eventSum": eventSum};
    }

    if (eventCount != null && segmentation != null) {
      eventType = "eventWithSegment";
      args = {"eventCount": eventCount, "segmentation": segmentation};
    }

    if (eventCount != null && eventSum != null && segmentation != null) {
      eventType = "eventWithSumSegment";
      args = {
        "eventCount": eventCount,
        "segmentation": segmentation,
        "eventSum": eventSum,
      };
    }

    if (eventType == null) return Future.value();
    args.addAll({"eventType": eventType, "eventName": eventName});

    await Channels.smartUX.invokeMethodOnMobile<void>("event", args);
  }

  Future<void> endEvent({
    required String eventName,
    int? eventCount,
    double? eventSum,
    Map<String, dynamic>? segmentation,
  }) async {
    String eventType = "event";
    var args = <String, dynamic>{};

    if (eventCount != null && eventSum != null) {
      eventType = "eventWithSum";
      args = {"eventCount": eventCount, "eventSum": eventSum};
    }

    if (eventCount != null && segmentation != null) {
      eventType = "eventWithSegment";
      args = {"eventCount": eventCount, "segmentation": segmentation};
    }

    if (eventCount != null && segmentation != null && eventSum != null) {
      eventType = "eventWithSumSegment";
      args = {
        "eventCount": eventCount,
        "segmentation": segmentation,
        "eventSum": eventSum,
      };
    }

    args.addAll({"eventType": eventType, "eventName": eventName});
    await Channels.smartUX.invokeMethodOnMobile<void>("endEvent", args);
  }

  Future<void> startEvent({required String startEvent}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("startEvent", {
      "startEvent": startEvent,
    });
  }

  Future<void> cancelEvent({required String cancelEvent}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("cancelEvent", {
      "cancelEvent": cancelEvent,
    });
  }

  Future<void> setUserData({
    required String userId,
    required Map<String, dynamic> userDataMap,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("setUserData", {
      "userDataMap": userDataMap,
      "userId": userId,
    });
  }

  Future<void> recordView({
    required String screenName,
    Map<String, dynamic>? segmentation,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("recordView", {
      "screenName": screenName,
      if (segmentation != null) "segmentation": segmentation,
    });
  }

  Future<void> recordUserFlow({
    required String view,
    required String from,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("recordUserFlow", {
      "view": view,
      "from": from,
    });
  }

  Future<void> recordAction({
    String? actionId,
    String? actionName,
    String? screenName,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("recordAction", {
      "actionId": actionId ?? "",
      "actionName": actionName ?? "",
      "screenName": screenName ?? "",
    });
  }

  Future<void> start() async {
    await Channels.smartUX.invokeMethodOnMobile<void>("start");
  }

  Future<void> stop() async {
    await Channels.smartUX.invokeMethodOnMobile<void>("stop");
  }

  Future<void> trackingNavigationEnter({
    required String screenName,
    double timeDelay = 0.2,
    bool forceUpload = false,
  }) async {
    await Channels.smartUX.invokeMethodOnMobile<void>(
      "trackingNavigationEnter",
      {
        "screenName": screenName,
        "timeDelay": timeDelay,
        "forceUpload": forceUpload,
      },
    );
  }

  Future<void> trackingNavigationScreen({required String screenName}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>(
      "trackingNavigationScreen",
      {"screenName": screenName},
    );
  }

  Future<void> recordFlow({required String screenName}) async {
    await Channels.smartUX.invokeMethodOnMobile<void>("recordFlow", {
      "screenName": screenName,
    });
  }
}

extension MethodChannelMobile on MethodChannel {
  Future<T?> invokeMethodOnMobile<T>(String method, [dynamic arguments]) {
    try {
      if (kIsWeb) {
        return Future.value(null);
      }

      return invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      print("Failed to track screen with screenshot: '${e.message}'.");
      return Future.value(null);
    }
  }
}

/// Native channels.
class Channels {
  static const MethodChannel smartUX = MethodChannel('com.vnpt.ai.ic/SmartUX');
}

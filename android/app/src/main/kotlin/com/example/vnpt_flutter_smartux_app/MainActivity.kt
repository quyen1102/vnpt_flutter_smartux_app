package com.example.vnpt_flutter_smartux_app

import android.content.res.Configuration
import android.util.Log
import ic.vnpt.analytics.heatmap.SmartUX
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
	private companion object {
		private const val TAG = "SmartUXPlugin"

		const val METHOD_CHANNEL_NAME = "com.vnpt.ai.ic/SmartUX"

		fun log(message: String?, logLevel: LogLevel) {
			log(message, null, logLevel)
		}

		fun log(message: String?, tr: Throwable?, logLevel: LogLevel) {
			when (logLevel) {
				LogLevel.INFO -> Log.i(TAG, message, tr)
				LogLevel.DEBUG -> Log.d(TAG, message, tr)
				LogLevel.WARNING -> Log.w(TAG, message, tr)
				LogLevel.ERROR -> Log.e(TAG, message, tr)
				LogLevel.VERBOSE -> Log.v(TAG, message, tr)
			}
		}

	}

	private var isSessionStarted = false

	private lateinit var channel: MethodChannel

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
		channel.setMethodCallHandler(this)
	}

	override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
		super.cleanUpFlutterEngine(flutterEngine)
		channel.setMethodCallHandler(null)
	}

	override fun onResume() {
		super.onResume()
		if (SmartUX.isInitialized()) {
			start()
		}
	}

	override fun onPause() {
		super.onPause()
		if (SmartUX.isInitialized()) {
			stop()
		}
	}

	override fun onConfigurationChanged(newConfig: Configuration) {
		super.onConfigurationChanged(newConfig)
		SmartUX.onConfigurationChanged(newConfig)
	}

	override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
		return FlutterActivityLaunchConfigs.BackgroundMode.transparent
	}

	override fun getTransparencyMode(): TransparencyMode {
		return TransparencyMode.transparent
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		val args = parseJsonFromArgs(call)
		when (call.method) {
			"addCrashLog" -> addCrashLog(args.getString("record"))

			"logException" -> logException(args.getString("exception"))

			"logFlutterException" -> logFlutterException(
				args.getString("err"),
				args.getString("message"),
				args.getString("stack")
			)

			"event" -> {
				when (args.getString("eventType")) {
					"event" -> event(
						args.getString("eventName"),
						args.getInt("eventCount")
					)

					"eventWithSum" -> event(
						args.getString("eventName"),
						args.getInt("eventCount"),
						args.getDouble("eventSum").toFloat()
					)

					"eventWithSegment" -> event(
						args.getString("eventName"),
						args.getHashMap("segmentation"),
						args.getInt("eventCount")
					)

					"eventWithSumSegment" -> event(
						args.getString("eventName"),
						args.getHashMap("segmentation"),
						args.getInt("eventCount"),
						args.getDouble("eventSum").toFloat()
					)
				}
			}

			"startEvent" -> startEvent(args.getString("startEvent"))

			"cancelEvent" -> cancelEvent(args.getString("cancelEvent"))

			"endEvent" -> {
				when (args.getString("eventType")) {
					"event" -> endEvent(args.getString("eventName"))

					"eventWithSum" -> endEvent(
						args.getString("eventName"),
						null,
						args.getInt("eventCount"),
						args.getDouble("eventSum").toFloat()
					)

					"eventWithSegment" -> endEvent(
						args.getString("eventName"),
						args.getHashMap("segmentation"),
						args.getInt("eventCount"),
						0f
					)

					"eventWithSumSegment" -> endEvent(
						args.getString("eventName"),
						args.getHashMap("segmentation"),
						args.getInt("eventCount"),
						args.getDouble("eventSum").toFloat()
					)
				}
			}

			"setUserData" -> setUserData(
				args.getString("userID"),
				args.getHashMap("userDataMap")
			)

			"recordView" -> recordView(
				args.getString("screenName"),
				args.getHashMap("segmentation"),
			)

			"recordUserFlow" -> recordUserFlow(
				args.getString("view"),
				args.getString("from")
			)

			"recordAction" -> recordAction(
				args.getString("actionId"),
				args.getString("actionName"),
				args.getString("screenName")
			)

			"start" -> start()

			"stop" -> stop()

			"makeScreenshot" -> makeScreenshot(args.getString("screenName"))

			"trackingNavigationEnter" -> trackingNavigationEnter(args.getString("screenName"))

			"trackingNavigationScreen" -> trackingNavigationScreen(args.getString("screenName"))

			else -> result.notImplemented()
		}
	}

	private fun setUserData(userID: String, userDataMap: HashMap<String, Any>) {
		SmartUX.setUserData(userId = userID, userDataMap = userDataMap)
	}

	private fun addCrashLog(record: String) {
		SmartUX.addCrashBreadcrumb(record)
	}

	private fun logException(exceptionString: String) {
		val exception = Exception(exceptionString)
		SmartUX.recordHandledException(exception)
	}

	private fun logFlutterException(err: String, message: String, stack: String) {
		SmartUX.addCrashBreadcrumb(stack)
		SmartUX.recordHandledException(SmartUXFlutterException(err, message, stack))
	}

	private fun event(eventName: String, eventCount: Int) {
		SmartUX.recordEvent(eventName, eventCount)
	}

	private fun event(eventName: String, eventCount: Int, eventSum: Float) {
		SmartUX.recordEvent(eventName, eventCount, eventSum)
	}

	private fun event(eventName: String, segmentation: HashMap<String, Any>, eventCount: Int) {
		SmartUX.recordEvent(eventName, segmentation, eventCount)
	}

	private fun event(
		eventName: String,
		segmentation: HashMap<String, Any>,
		eventCount: Int,
		eventSum: Float
	) {
		SmartUX.recordEvent(eventName, segmentation, eventCount, eventSum)
	}

	private fun endEvent(eventName: String) {
		SmartUX.endEvent(eventName)
	}

	private fun endEvent(
		eventName: String,
		segmentation: HashMap<String, Any>?,
		eventCount: Int,
		eventSum: Float
	) {
		SmartUX.endEvent(eventName, segmentation, eventCount, eventSum)
	}

	private fun startEvent(startEvent: String) {
		SmartUX.startEvent(startEvent)
	}

	private fun cancelEvent(cancelEvent: String) {
		SmartUX.cancelEvent(cancelEvent)
	}

	private fun start() {
		try {
			if (isSessionStarted) {
				log("session already started", LogLevel.INFO)
				return
			}
			SmartUX.onStartTracking(this)
			isSessionStarted = true
		} catch (e: Exception) {
			log(e.message, LogLevel.ERROR)
		}
	}

	private fun stop() {
		if (!isSessionStarted) {
			log("must call Start before Stop", LogLevel.INFO)
			return
		}
		SmartUX.onStopTracking()
		isSessionStarted = false
	}

	private fun makeScreenshot(screenName: String) {
		try {
			SmartUX.ensureInitialized()
			SmartUX.makeScreenshot(this, screenName)
		} catch (e: Exception) {
			log(e.message, LogLevel.ERROR)
		}
	}

	private fun trackingNavigationEnter(screenName: String) {
		try {
			SmartUX.ensureInitialized()
			SmartUX.trackingNavigationEnter(this, screenName)
		} catch (e: Exception) {
			log(e.message, LogLevel.ERROR)
		}
	}

	private fun trackingNavigationScreen(screenName: String) {
		SmartUX.ensureInitialized()
		SmartUX.trackNavigationScreen(screenName)
	}

	private fun recordView(screenName: String, segmentation: Map<String, Any>?) {
		SmartUX.recordView(screenName, segmentation)
	}

	private fun recordUserFlow(view: String, from: String) {
		SmartUX.recordUserFlow(view, from)
	}

	private fun recordAction(
		actionId: String? = null,
		actionName: String? = null,
		screenName: String? = null
	) {
		SmartUX.recordAction(actionId, actionName, screenName)
	}

	private fun parseJsonFromArgs(call: MethodCall): JSONObject {
		return try {
			@Suppress("UNCHECKED_CAST")
			(JSONObject(call.arguments as Map<String, Any>))
		} catch (e: Exception) {
			JSONObject(mapOf<String, Any>())
		}
	}

	private fun JSONObject.getHashMap(key: String): HashMap<String, Any> {
		if (!has(key)) return hashMapOf()
		return try {
			getJSONObject(key).toMap()
		} catch (e: Exception) {
			log(e.message, LogLevel.ERROR)
			hashMapOf()
		}
	}

	private fun JSONObject.toMap(): HashMap<String, Any> {
		val map = HashMap<String, Any>()
		val keysItr: Iterator<String> = this.keys()
		while (keysItr.hasNext()) {
			val key = keysItr.next()
			var value: Any = this.get(key)
			when (value) {
				is JSONArray -> value = value.toList()
				is JSONObject -> value = value.toMap()
			}
			map[key] = value
		}
		return map
	}

	private fun JSONArray.toList(): List<Any> {
		val list = mutableListOf<Any>()
		for (i in 0 until this.length()) {
			var value: Any = this[i]
			when (value) {
				is JSONArray -> value = value.toList()
				is JSONObject -> value = value.toMap()
			}
			list.add(value)
		}
		return list
	}
}

internal enum class LogLevel {
	INFO, DEBUG, VERBOSE, WARNING, ERROR
}

internal data class SmartUXFlutterException(
	val flutterError: String,
	val flutterMessage: String,
	val flutterStack: String
) : Exception() {
	override fun toString(): String {
		return "[Flutter] $flutterError: $flutterMessage\n$flutterStack\n\nJava Stack:"
	}
}

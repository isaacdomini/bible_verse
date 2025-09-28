package com.example.bible_verse

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.common.api.ResultCallback

class MainActivity: FlutterActivity() {
    private val CHANNEL = "bible_verse/cast"
    private var castContext: CastContext? = null
    private var castSession: CastSession? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        try {
            castContext = CastContext.getSharedInstance(this)
        } catch (e: Exception) {
            // Cast framework not available
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startCasting" -> {
                    val success = startCasting()
                    result.success(success)
                }
                "stopCasting" -> {
                    val success = stopCasting()
                    result.success(success)
                }
                "updateVerseDisplay" -> {
                    val reference = call.argument<String>("reference") ?: ""
                    val verse = call.argument<String>("verse") ?: ""
                    updateVerseDisplay(reference, verse)
                    result.success(null)
                }
                "getAvailableDevices" -> {
                    val devices = getAvailableDevices()
                    result.success(devices)
                }
                "connectToDevice" -> {
                    val deviceId = call.argument<String>("deviceId") ?: ""
                    val success = connectToDevice(deviceId)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startCasting(): Boolean {
        return try {
            castContext?.let { context ->
                castSession = context.sessionManager.currentCastSession
                castSession != null
            } ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun stopCasting(): Boolean {
        return try {
            castContext?.sessionManager?.endCurrentSession(true)
            castSession = null
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun updateVerseDisplay(reference: String, verse: String) {
        castSession?.remoteMediaClient?.let { remoteMediaClient ->
            try {
                val metadata = MediaMetadata(MediaMetadata.MEDIA_TYPE_GENERIC)
                metadata.putString(MediaMetadata.KEY_TITLE, reference)
                metadata.putString(MediaMetadata.KEY_SUBTITLE, verse)
                
                val mediaInfo = MediaInfo.Builder("bible_verse://cast")
                    .setStreamType(MediaInfo.STREAM_TYPE_NONE)
                    .setContentType("text/plain")
                    .setMetadata(metadata)
                    .build()

                val request = MediaLoadRequestData.Builder()
                    .setMediaInfo(mediaInfo)
                    .build()

                remoteMediaClient.load(request)
            } catch (e: Exception) {
                // Handle error
            }
        }
    }

    private fun getAvailableDevices(): List<String> {
        return try {
            castContext?.let {
                listOf("Google Cast Device") // Simplified for demo
            } ?: emptyList()
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun connectToDevice(deviceId: String): Boolean {
        // In a real implementation, you would use the Cast SDK to connect
        return false
    }
}
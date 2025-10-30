package com.example.flutter_ar_app

import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class RecordingActivity : FlutterActivity() {
    private val CHANNEL = "recording_channel"
    private var mediaRecorder: MediaRecorder? = null
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var currentRecordingPath: String? = null
    private var isRecording = false
    private var isPaused = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    val filePath = call.argument<String>("filePath")
                    val includeAudio = call.argument<Boolean>("includeAudio") ?: true
                    startRecording(filePath, includeAudio, result)
                }
                "stopRecording" -> {
                    stopRecording(result)
                }
                "pauseRecording" -> {
                    pauseRecording(result)
                }
                "resumeRecording" -> {
                    resumeRecording(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startRecording(filePath: String?, includeAudio: Boolean, result: MethodChannel.Result) {
        if (isRecording) {
            result.success(false)
            return
        }

        try {
            val outputDir = getExternalFilesDir(Environment.DIRECTORY_MOVIES)
            val fileName = filePath?.substringAfterLast("/") ?: "recording_${System.currentTimeMillis()}.mp4"
            currentRecordingPath = File(outputDir, fileName).absolutePath

            mediaRecorder = MediaRecorder().apply {
                setAudioSource(if (includeAudio) MediaRecorder.AudioSource.MIC else MediaRecorder.AudioSource.DEFAULT)
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setOutputFile(currentRecordingPath)
                setVideoSize(1080, 1920)
                setVideoFrameRate(30)
                setVideoEncodingBitRate(5 * 1024 * 1024)
                
                if (includeAudio) {
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                    setAudioEncodingBitRate(128 * 1024)
                    setAudioSamplingRate(44100)
                }
                
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                
                try {
                    prepare()
                } catch (e: IOException) {
                    result.error("PREPARE_ERROR", "Failed to prepare media recorder", e.message)
                    return
                }
            }

            // Request screen capture permission
            val intent = mediaProjectionManager?.createScreenCaptureIntent()
            if (intent != null) {
                startActivityForResult(intent, REQUEST_CODE)
                result.success(true)
            } else {
                result.error("PROJECTION_ERROR", "Failed to create screen capture intent", null)
            }
        } catch (e: Exception) {
            result.error("RECORDING_ERROR", "Failed to start recording: ${e.message}", e.message)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE && resultCode == RESULT_OK) {
            data?.let { resultData ->
                mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, resultData)
                startVirtualDisplay()
                mediaRecorder?.start()
                isRecording = true
                isPaused = false
            }
        }
    }

    private fun startVirtualDisplay() {
        mediaRecorder?.let { recorder ->
            val surface = recorder.surface
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                "Recording",
                1080,
                1920,
                resources.displayMetrics.densityDpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                surface,
                null,
                null
            )
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        if (!isRecording) {
            result.success(false)
            return
        }

        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            virtualDisplay?.release()
            mediaProjection?.stop()
            
            mediaRecorder = null
            virtualDisplay = null
            mediaProjection = null
            isRecording = false
            isPaused = false
            
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_ERROR", "Failed to stop recording: ${e.message}", e.message)
        }
    }

    private fun pauseRecording(result: MethodChannel.Result) {
        if (!isRecording || isPaused) {
            result.success(false)
            return
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mediaRecorder?.pause()
                isPaused = true
                result.success(true)
            } else {
                result.error("NOT_SUPPORTED", "Pause/resume not supported on this Android version", null)
            }
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", "Failed to pause recording: ${e.message}", e.message)
        }
    }

    private fun resumeRecording(result: MethodChannel.Result) {
        if (!isRecording || !isPaused) {
            result.success(false)
            return
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mediaRecorder?.resume()
                isPaused = false
                result.success(true)
            } else {
                result.error("NOT_SUPPORTED", "Pause/resume not supported on this Android version", null)
            }
        } catch (e: Exception) {
            result.error("RESUME_ERROR", "Failed to resume recording: ${e.message}", e.message)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cleanup()
    }

    private fun cleanup() {
        if (isRecording) {
            try {
                mediaRecorder?.stop()
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
        }
        
        mediaRecorder?.release()
        virtualDisplay?.release()
        mediaProjection?.stop()
        
        mediaRecorder = null
        virtualDisplay = null
        mediaProjection = null
        isRecording = false
        isPaused = false
    }

    companion object {
        private const val REQUEST_CODE = 1000
    }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../domain/entities/recording.dart';
import '../providers/recording_provider.dart';

class RecordingControls extends ConsumerWidget {
  const RecordingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingStateProvider);
    final currentRecording = ref.watch(currentRecordingProvider);
    final recordingNotifier = ref.read(recordingStateProvider.notifier);

    ref.listen<RecordingState>(recordingStateProvider, (previous, next) {
      if (next.error != null) {
        Fluttertoast.showToast(
          msg: next.error!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        recordingNotifier.clearError();
      }

      if (next.lastSavedRecording != null) {
        Fluttertoast.showToast(
          msg: 'Recording saved to gallery!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        recordingNotifier.clearLastSaved();
      }
    });

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recordingState.isRecording) ...[
            _buildRecordingInfo(currentRecording.value),
            SizedBox(height: 16.h),
            _buildStopButton(recordingNotifier, recordingState),
          ] else ...[
            _buildStartButton(recordingNotifier, recordingState),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingInfo(Recording? recording) {
    if (recording == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'REC',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              _formatDuration(recording.duration),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (recording.hasAudio) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                color: Colors.white70,
                size: 16.w,
              ),
              SizedBox(width: 4.w),
              Text(
                'Audio',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStartButton(RecordingNotifier notifier, RecordingState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isLoading ? null : () => notifier.startRecording(),
        icon: state.isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.fiber_manual_record, size: 24.w),
        label: Text(
          state.isLoading ? 'Starting...' : 'Start Recording',
          style: TextStyle(fontSize: 16.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildStopButton(RecordingNotifier notifier, RecordingState state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () => notifier.stopRecording(),
            icon: state.isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.stop, size: 24.w),
            label: Text(
              state.isLoading ? 'Stopping...' : 'Stop',
              style: TextStyle(fontSize: 16.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
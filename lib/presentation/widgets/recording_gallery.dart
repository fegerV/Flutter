import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../domain/entities/recording.dart';
import '../providers/recording_provider.dart';

class RecordingGallery extends ConsumerWidget {
  const RecordingGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingsAsync = ref.watch(recordingsProvider);
    final recordingNotifier = ref.read(recordingStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recording Gallery',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: recordingsAsync.when(
        data: (recordings) {
          if (recordings.isEmpty) {
            return _buildEmptyState();
          }
          return _buildGallery(recordings, recordingNotifier);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, stack) => _buildErrorState(error.toString(), recordingNotifier),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 80.w,
              color: Colors.white54,
            ),
            SizedBox(height: 16.h),
            Text(
              'No recordings yet',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start recording to see them here',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, RecordingNotifier notifier) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.w,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading recordings',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => notifier.refreshRecordings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(List<Recording> recordings, RecordingNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () async => notifier.refreshRecordings(),
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.8,
        ),
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          final recording = recordings[index];
          return _buildRecordingCard(recording, notifier);
        },
      ),
    );
  }

  Widget _buildRecordingCard(Recording recording, RecordingNotifier notifier) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 48.w,
                      color: Colors.white54,
                    ),
                  ),
                  if (recording.status == RecordingStatus.saved)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Saved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDuration(recording.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(recording.createdAt),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatFileSize(recording.fileSizeBytes),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp,
                    ),
                  ),
                  const Spacer(),
                  if (recording.status != RecordingStatus.saved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveToGallery(recording, notifier),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Text(
                          'Save to Gallery',
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery(Recording recording, RecordingNotifier notifier) async {
    await notifier.saveToGallery(recording);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}
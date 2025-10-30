import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/cache_provider.dart';

class CacheStatusWidget extends StatelessWidget {
  final CacheState cacheState;

  const CacheStatusWidget({
    super.key,
    required this.cacheState,
  });

  @override
  Widget build(BuildContext context) {
    return cacheState.when(
      initial: () => _buildPlaceholder(),
      loading: () => _buildLoading(),
      loaded: (cacheInfo) => _buildCacheInfo(cacheInfo),
      error: (error) => _buildError(error),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No cache data available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheInfo(cacheInfo) {
    final usagePercentage = cacheInfo.usagePercentage;
    final isOverLimit = cacheInfo.isOverLimit;
    final isNearLimit = cacheInfo.isNearLimit;

    Color progressColor;
    if (isOverLimit) {
      progressColor = Colors.red;
    } else if (isNearLimit) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage Usage',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatFileSize(cacheInfo.usedSize)} / ${_formatFileSize(cacheInfo.maxSizeLimit)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: usagePercentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8.h,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Items',
                  '${cacheInfo.itemCount}',
                  Icons.animation,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Usage',
                  '${(usagePercentage * 100).toStringAsFixed(1)}%',
                  Icons.storage,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'TTL',
                  '${cacheInfo.ttl.inDays}d',
                  Icons.schedule,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (isOverLimit || isNearLimit)
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isOverLimit ? Colors.red.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isOverLimit ? Colors.red.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverLimit ? Icons.warning : Icons.info,
                    size: 16.w,
                    color: isOverLimit ? Colors.red.shade600 : Colors.orange.shade600,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isOverLimit
                          ? 'Cache over limit. Consider clearing some items.'
                          : 'Cache approaching limit. Consider optimization.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isOverLimit ? Colors.red.shade600 : Colors.orange.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.w,
          color: Colors.grey.shade600,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
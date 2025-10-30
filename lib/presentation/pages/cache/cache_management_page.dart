import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/cache_provider.dart';
import '../../providers/animation_provider.dart';
import '../../widgets/cache_status_widget.dart';

class CacheManagementPage extends ConsumerWidget {
  const CacheManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cacheState = ref.watch(cacheProvider);
    final animationState = ref.watch(animationProvider);

    ref.listen<CacheState>(cacheProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        loaded: (_) {},
        error: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cacheManagement),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(cacheProvider.notifier).loadCacheInfo();
          ref.read(animationProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCacheStatusSection(context, ref, cacheState, l10n),
              SizedBox(height: 24.h),
              _buildCacheActionsSection(context, ref, cacheState, l10n),
              SizedBox(height: 24.h),
              _buildCachedAnimationsSection(context, ref, animationState, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheStatusSection(
    BuildContext context,
    WidgetRef ref,
    CacheState cacheState,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cacheStatus,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            CacheStatusWidget(cacheState: cacheState),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheActionsSection(
    BuildContext context,
    WidgetRef ref,
    CacheState cacheState,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cacheActions,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: cacheState.isLoading
                        ? null
                        : () {
                            _showClearCacheDialog(context, ref, l10n);
                          },
                    icon: const Icon(Icons.delete_sweep),
                    label: Text(l10n.clearAllCache),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: cacheState.isLoading
                        ? null
                        : () {
                            ref.read(cacheProvider.notifier).optimizeCache();
                          },
                    icon: const Icon(Icons.tune),
                    label: Text(l10n.optimizeCache),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedAnimationsSection(
    BuildContext context,
    WidgetRef ref,
    AnimationState animationState,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.cachedAnimations,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(animationProvider.notifier).loadAnimations(onlyDownloaded: true);
                  },
                  child: Text(l10n.refresh),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            animationState.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (animations) {
                final downloadedAnimations = animations.where((a) => a.isDownloaded).toList();
                
                if (downloadedAnimations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 64.w,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.noCachedAnimations,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: downloadedAnimations.length,
                  itemBuilder: (context, index) {
                    final animation = downloadedAnimations[index];
                    return _buildCachedAnimationItem(context, ref, animation, l10n);
                  },
                );
              },
              error: (error) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.w,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      error,
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(animationProvider.notifier).refresh();
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedAnimationItem(
    BuildContext context,
    WidgetRef ref,
    animation,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.blue.shade100,
            child: Icon(
              Icons.animation,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ),
      title: Text(
        animation.title,
        style: TextStyle(fontSize: 16.sp),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatFileSize(animation.fileSize)} • ${_formatDuration(animation.duration)}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          if (animation.downloadedAt != null)
            Text(
              'Downloaded: ${_formatDateTime(animation.downloadedAt!)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          _showDeleteAnimationDialog(context, ref, animation, l10n);
        },
      ),
      onTap: () {
        // Navigate to animation playback
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllCache),
        content: Text(l10n.clearAllCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(cacheProvider.notifier).clearAllCache();
            },
            child: Text(l10n.clear),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showDeleteAnimationDialog(
    BuildContext context,
    WidgetRef ref,
    animation,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAnimation),
        content: Text('${l10n.deleteAnimationConfirmation} "${animation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(cacheProvider.notifier).clearAnimationCache(animation.id);
              ref.read(animationProvider.notifier).refresh();
            },
            child: Text(l10n.delete),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
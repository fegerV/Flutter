import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/qr_provider.dart';

class QRHistoryPage extends ConsumerWidget {
  const QRHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final qrState = ref.watch(qrProvider);

    ref.listen<QRState>(qrProvider, (previous, next) {
      next.when(
        initial: () {},
        scanning: () {},
        scanned: (_) {},
        loading: () {},
        historyLoaded: (_) {},
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
        title: Text(l10n.scanHistory),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _showClearHistoryDialog(context, ref);
            },
          ),
        ],
      ),
      body: qrState.when(
        initial: () => Center(child: Text(l10n.noScanHistory)),
        loading: () => const Center(child: CircularProgressIndicator()),
        historyLoaded: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 64.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noScanHistory,
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
            padding: EdgeInsets.all(16.w),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final qrCode = history[index];
              return _buildQRCodeItem(context, qrCode, ref);
            },
          );
        },
        scanning: () => const Center(child: CircularProgressIndicator()),
        scanned: (_) => const Center(child: CircularProgressIndicator()),
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
                  ref.read(qrProvider.notifier).loadScanHistory();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pop();
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildQRCodeItem(BuildContext context, QRCode qrCode, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: qrCode.isValidAnimationQR 
              ? Colors.green 
              : Colors.grey.shade400,
          child: Icon(
            qrCode.isValidAnimationQR 
                ? Icons.check 
                : Icons.qr_code_2,
            color: Colors.white,
          ),
        ),
        title: Text(
          qrCode.animationId ?? l10n.unknownQRCode,
          style: TextStyle(fontSize: 16.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(qrCode.scannedAt),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            if (qrCode.type != null)
              Text(
                'Type: ${qrCode.type}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: qrCode.isValidAnimationQR
            ? IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  if (qrCode.animationId != null) {
                    context.push('/ar', extra: {'animationId': qrCode.animationId});
                  }
                },
              )
            : null,
        onTap: () {
          _showQRCodeDetails(context, qrCode);
        },
      ),
    );
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

  void _showQRCodeDetails(BuildContext context, QRCode qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Raw Value: ${qrCode.rawValue}'),
              const SizedBox(height: 8),
              Text('Animation ID: ${qrCode.animationId ?? 'None'}'),
              const SizedBox(height: 8),
              Text('Type: ${qrCode.type ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text('Scanned At: ${qrCode.scannedAt.toIso8601String()}'),
              if (qrCode.metadata != null) ...[
                const SizedBox(height: 8),
                Text('Metadata: ${qrCode.metadata.toString()}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearScanHistory),
        content: Text(l10n.clearScanHistoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(qrProvider.notifier).clearHistory();
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }
}
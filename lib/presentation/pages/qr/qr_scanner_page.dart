import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/qr_provider.dart';
import '../../widgets/qr_scanner_overlay.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  const QRScannerPage({super.key});

  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  CameraController? _cameraController;
  bool _isScanning = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final cameraPermission = await Permission.camera.request();
    
    if (cameraPermission.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _initializeCamera();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cameraPermissionRequired),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  void _simulateQRScan(String value) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    ref.read(qrProvider.notifier).scanQRCode(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final qrState = ref.watch(qrProvider);

    ref.listen<QRState>(qrProvider, (previous, next) {
      next.when(
        initial: () {},
        scanning: () {},
        scanned: (qrCode) {
          if (qrCode.isValidAnimationQR) {
            context.push('/ar', extra: {'animationId': qrCode.animationId});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.invalidQRCode),
                backgroundColor: Colors.red,
              ),
            );
            _resetScanner();
          }
        },
        loading: () {},
        historyLoaded: (_) {},
        error: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
          _resetScanner();
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrScanner),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera preview or placeholder
          if (_cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64.w,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _hasPermission ? 'Initializing camera...' : 'Camera permission required',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // QR Scanner overlay
          QRScannerOverlay(
            borderColor: Colors.white,
            borderRadius: 16,
            borderLength: 30,
            borderWidth: 4,
            cutOutSize: 250,
          ),
          
          // Instructions
          if (qrState.isScanning)
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.scanQRCodeInstruction,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => _simulateQRScan('anim_001'),
                        child: Text(
                          'Simulate QR Scan (Test)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Loading overlay
          if (qrState.isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.processingQRCode,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/qr/history');
        },
        icon: const Icon(Icons.history),
        label: Text(l10n.scanHistory),
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
    });
  }
}
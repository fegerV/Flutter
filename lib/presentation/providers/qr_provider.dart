import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/qr_code.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import '../../domain/repositories/qr_repository.dart';
import '../../core/di/injection_container.dart';

final qrProvider = StateNotifierProvider<QRNotifier, QRState>((ref) {
  final scanQRCodeUseCase = ref.read(scanQRCodeUseCaseProvider);
  final qrRepository = ref.read(qrRepositoryProvider);
  
  return QRNotifier(
    scanQRCodeUseCase,
    qrRepository,
  );
});

final scanQRCodeUseCaseProvider = Provider<ScanQRCodeUseCase>((ref) {
  return ref.read(getItProvider).get<ScanQRCodeUseCase>();
});

final qrRepositoryProvider = Provider<QRRepository>((ref) {
  return ref.read(getItProvider).get<QRRepository>();
});

class QRNotifier extends StateNotifier<QRState> {
  final ScanQRCodeUseCase _scanQRCodeUseCase;
  final QRRepository _qrRepository;

  QRNotifier(
    this._scanQRCodeUseCase,
    this._qrRepository,
  ) : super(const QRState.initial());

  Future<void> scanQRCode(String rawValue) async {
    state = const QRState.scanning();
    
    try {
      final qrCode = await _scanQRCodeUseCase(ScanQRCodeParams(rawValue));
      state = QRState.scanned(qrCode);
    } catch (e) {
      state = QRState.error(e.toString());
    }
  }

  Future<void> loadScanHistory() async {
    state = const QRState.loading();
    
    try {
      final history = await _qrRepository.getScanHistory();
      state = QRState.historyLoaded(history);
    } catch (e) {
      state = QRState.error(e.toString());
    }
  }

  Future<void> clearHistory() async {
    try {
      await _qrRepository.clearScanHistory();
      state = const QRState.historyLoaded([]);
    } catch (e) {
      state = QRState.error(e.toString());
    }
  }

  void reset() {
    state = const QRState.initial();
  }
}

class QRState {
  final QRCode? scannedQRCode;
  final List<QRCode> scanHistory;
  final bool isScanning;
  final bool isLoading;
  final String? error;

  const QRState._({
    this.scannedQRCode,
    required this.scanHistory,
    required this.isScanning,
    required this.isLoading,
    this.error,
  });

  const QRState.initial()
      : this._(
          scanHistory: [],
          isScanning: false,
          isLoading: false,
        );

  const QRState.scanning()
      : this._(
          scanHistory: [],
          isScanning: true,
          isLoading: false,
        );

  const QRState.scanned(QRCode qrCode)
      : this._(
          scannedQRCode: qrCode,
          scanHistory: [],
          isScanning: false,
          isLoading: false,
        );

  const QRState.loading()
      : this._(
          scanHistory: [],
          isScanning: false,
          isLoading: true,
        );

  const QRState.historyLoaded(List<QRCode> history)
      : this._(
          scanHistory: history,
          isScanning: false,
          isLoading: false,
        );

  const QRState.error(String error)
      : this._(
          scanHistory: [],
          isScanning: false,
          isLoading: false,
          error: error,
        );

  T when<T>({
    required T Function() initial,
    required T Function() scanning,
    required T Function(QRCode qrCode) scanned,
    required T Function() loading,
    required T Function(List<QRCode> history) historyLoaded,
    required T Function(String error) error,
  }) {
    if (isLoading) {
      return loading();
    } else if (isScanning) {
      return scanning();
    } else if (scannedQRCode != null) {
      return scanned(scannedQRCode!);
    } else if (this.error != null) {
      return error(this.error!);
    } else if (scanHistory.isNotEmpty) {
      return historyLoaded(scanHistory);
    } else {
      return initial();
    }
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? scanning,
    T Function(QRCode qrCode)? scanned,
    T Function()? loading,
    T Function(List<QRCode> history)? historyLoaded,
    T Function(String error)? error,
  }) {
    if (isLoading && loading != null) {
      return loading();
    } else if (isScanning && scanning != null) {
      return scanning();
    } else if (scannedQRCode != null && scanned != null) {
      return scanned(scannedQRCode!);
    } else if (this.error != null && error != null) {
      return error(this.error!);
    } else if (scanHistory.isNotEmpty && historyLoaded != null) {
      return historyLoaded(scanHistory);
    } else if (initial != null) {
      return initial();
    }
    return null;
  }
}
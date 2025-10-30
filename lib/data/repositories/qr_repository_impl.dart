import 'package:injectable/injectable.dart';
import '../../domain/entities/qr_code.dart';
import '../../domain/repositories/qr_repository.dart';
import '../services/qr_service.dart';

@injectable
class QRRepositoryImpl implements QRRepository {
  final QRService _qrService;

  QRRepositoryImpl(this._qrService);

  @override
  Future<QRCode> scanQRCode(String rawValue) async {
    final qrCode = await _qrService.parseQRCode(rawValue);
    await _qrService.saveQRCode(qrCode);
    return qrCode;
  }

  @override
  Future<List<QRCode>> getScanHistory() async {
    return await _qrService.getScanHistory();
  }

  @override
  Future<void> saveQRCode(QRCode qrCode) async {
    await _qrService.saveQRCode(qrCode);
  }

  @override
  Future<void> clearScanHistory() async {
    await _qrService.clearScanHistory();
  }
}
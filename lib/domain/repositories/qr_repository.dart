import '../entities/qr_code.dart';

abstract class QRRepository {
  Future<QRCode> scanQRCode(String rawValue);
  Future<List<QRCode>> getScanHistory();
  Future<void> saveQRCode(QRCode qrCode);
  Future<void> clearScanHistory();
}
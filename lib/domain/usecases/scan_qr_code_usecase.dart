import 'package:injectable/injectable.dart';
import '../entities/qr_code.dart';
import '../repositories/qr_repository.dart';
import 'usecase.dart';

class ScanQRCodeParams {
  final String rawValue;

  const ScanQRCodeParams(this.rawValue);
}

@injectable
class ScanQRCodeUseCase implements UseCase<QRCode, ScanQRCodeParams> {
  final QRRepository _repository;

  ScanQRCodeUseCase(this._repository);

  @override
  Future<QRCode> call(ScanQRCodeParams params) async {
    return await _repository.scanQRCode(params.rawValue);
  }
}
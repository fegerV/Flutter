import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/qr_code.dart';

class QRService {
  static const String _qrHistoryKey = 'qr_scan_history';
  late final SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<QRCode> parseQRCode(String rawValue) async {
    try {
      // Try to parse as JSON first
      final jsonData = jsonDecode(rawValue);
      
      if (jsonData is Map<String, dynamic>) {
        return QRCode(
          rawValue: rawValue,
          animationId: jsonData['animation_id'] as String?,
          type: jsonData['type'] as String? ?? 'animation',
          scannedAt: DateTime.now(),
          metadata: jsonData,
        );
      }
    } catch (e) {
      // Not JSON, try to parse as simple animation ID
      if (RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(rawValue)) {
        return QRCode(
          rawValue: rawValue,
          animationId: rawValue,
          type: 'animation',
          scannedAt: DateTime.now(),
          metadata: {'source': 'simple_id'},
        );
      }
      
      // Try to extract animation ID from URL format
      final urlMatch = RegExp(r'animation[/:]([a-zA-Z0-9_-]+)').firstMatch(rawValue);
      if (urlMatch != null) {
        return QRCode(
          rawValue: rawValue,
          animationId: urlMatch.group(1),
          type: 'animation',
          scannedAt: DateTime.now(),
          metadata: {'source': 'url'},
        );
      }
    }

    // Return QR code without animation ID if parsing fails
    return QRCode(
      rawValue: rawValue,
      type: 'unknown',
      scannedAt: DateTime.now(),
      metadata: {'parse_error': true},
    );
  }

  Future<void> saveQRCode(QRCode qrCode) async {
    final history = await getScanHistory();
    history.add(qrCode);
    
    // Keep only last 100 scans
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    
    await _saveHistory(history);
  }

  Future<List<QRCode>> getScanHistory() async {
    try {
      final historyJson = _prefs.getStringList(_qrHistoryKey) ?? [];
      
      return historyJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return QRCode(
          rawValue: map['rawValue'] as String,
          animationId: map['animationId'] as String?,
          type: map['type'] as String?,
          scannedAt: DateTime.parse(map['scannedAt'] as String),
          metadata: map['metadata'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearScanHistory() async {
    await _prefs.remove(_qrHistoryKey);
  }

  Future<void> _saveHistory(List<QRCode> history) async {
    final historyJson = history.map((qr) => jsonEncode({
      'rawValue': qr.rawValue,
      'animationId': qr.animationId,
      'type': qr.type,
      'scannedAt': qr.scannedAt.toIso8601String(),
      'metadata': qr.metadata,
    })).toList();
    
    await _prefs.setStringList(_qrHistoryKey, historyJson);
  }
}
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ar_app/core/network/network_info.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test('should return true when connected to wifi', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final result = await networkInfo.isConnected;

      expect(result, true);
    });

    test('should return true when connected to mobile', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.mobile);

      final result = await networkInfo.isConnected;

      expect(result, true);
    });

    test('should return false when not connected', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final result = await networkInfo.isConnected;

      expect(result, false);
    });
  });

  group('onConnectivityChanged', () {
    test('should emit true when connection is established', () async {
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

      final stream = networkInfo.onConnectivityChanged;

      expect(await stream.first, true);
    });

    test('should emit false when connection is lost', () async {
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.none));

      final stream = networkInfo.onConnectivityChanged;

      expect(await stream.first, false);
    });
  });
}

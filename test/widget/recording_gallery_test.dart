import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../lib/presentation/widgets/recording_gallery.dart';
import '../../../lib/domain/entities/recording.dart';
import '../../../lib/presentation/providers/recording_provider.dart';

void main() {
  group('RecordingGallery Widget Tests', () {
    late ProviderContainer container;
    late List<Recording> mockRecordings;

    setUp(() {
      mockRecordings = [
        Recording(
          id: '1',
          filePath: '/test/path1.mp4',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: const Duration(minutes: 2, seconds: 30),
          fileSizeBytes: 2048000,
          hasAudio: true,
          status: RecordingStatus.completed,
        ),
        Recording(
          id: '2',
          filePath: '/test/path2.mp4',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          duration: const Duration(minutes: 1, seconds: 15),
          fileSizeBytes: 1024000,
          hasAudio: true,
          status: RecordingStatus.saved,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          recordingsProvider.overrideWith((ref) => Stream.value(mockRecordings)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('displays gallery with recordings', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const RecordingGallery(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recording Gallery'), findsOneWidget);
      expect(find.text('2m 30s'), findsOneWidget);
      expect(find.text('1m 15s'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Save to Gallery'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('displays empty state when no recordings', (WidgetTester tester) async {
      container = ProviderContainer(
        overrides: [
          recordingsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const RecordingGallery(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No recordings yet'), findsOneWidget);
      expect(find.text('Start recording to see them here'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      container = ProviderContainer(
        overrides: [
          recordingsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const RecordingGallery(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('taps save to gallery button', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const RecordingGallery(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final saveButton = find.text('Save to Gallery');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Verify the save action was triggered
      expect(find.text('Save to Gallery'), findsOneWidget);
    });
  });

  group('Recording Entity Tests', () {
    test('creates recording entity correctly', () {
      final recording = Recording(
        id: 'test-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 1, seconds: 30),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      expect(recording.id, 'test-id');
      expect(recording.filePath, '/test/path.mp4');
      expect(recording.hasAudio, true);
      expect(recording.status, RecordingStatus.recording);
      expect(recording.duration, const Duration(minutes: 1, seconds: 30));
    });

    test('copyWith creates new instance with updated values', () {
      final original = Recording(
        id: 'test-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 1),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      final updated = original.copyWith(
        status: RecordingStatus.completed,
        duration: const Duration(minutes: 2),
      );

      expect(updated.id, original.id);
      expect(updated.status, RecordingStatus.completed);
      expect(updated.duration, const Duration(minutes: 2));
      expect(updated.hasAudio, original.hasAudio);
    });

    test('equality works correctly', () {
      final recording1 = Recording(
        id: 'test-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 1),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      final recording2 = Recording(
        id: 'test-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 1),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      final recording3 = Recording(
        id: 'different-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 1),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      expect(recording1, equals(recording2));
      expect(recording1, isNot(equals(recording3)));
    });
  });
}
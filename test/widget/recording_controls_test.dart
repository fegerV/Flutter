import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../lib/presentation/widgets/recording_controls.dart';
import '../../../lib/domain/entities/recording.dart';
import '../../../lib/presentation/providers/recording_provider.dart';

void main() {
  group('RecordingControls Widget Tests', () {
    late ProviderContainer container;
    late RecordingNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockRecordingNotifier();
      container = ProviderContainer(
        overrides: [
          recordingStateProvider.overrideWith((ref) => mockNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('displays start recording button when not recording', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(const RecordingState(isRecording: false));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) => const RecordingControls(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Start Recording'), findsOneWidget);
      expect(find.byIcon(Icons.fiber_manual_record), findsOneWidget);
    });

    testWidgets('displays recording info and stop button when recording', (WidgetTester tester) async {
      final recording = Recording(
        id: 'test-id',
        filePath: '/test/path.mp4',
        createdAt: DateTime.now(),
        duration: const Duration(seconds: 30),
        fileSizeBytes: 1024000,
        hasAudio: true,
        status: RecordingStatus.recording,
      );

      when(mockNotifier.state).thenReturn(RecordingState(isRecording: true));
      when(mockNotifier.currentRecordingStream).thenAnswer((_) => Stream.value(recording));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) => const RecordingControls(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('REC'), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('calls startRecording when start button is tapped', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(const RecordingState(isRecording: false));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) => const RecordingControls(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start Recording'));
      await tester.pump();

      verify(mockNotifier.startRecording()).called(1);
    });

    testWidgets('calls stopRecording when stop button is tapped', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(const RecordingState(isRecording: true));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) => const RecordingControls(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Stop'));
      await tester.pump();

      verify(mockNotifier.stopRecording()).called(1);
    });
  });
}

class MockRecordingNotifier extends RecordingNotifier {
  MockRecordingNotifier() : super(
    startRecordingUseCase: MockStartRecordingUseCase(),
    stopRecordingUseCase: MockStopRecordingUseCase(),
    saveToGalleryUseCase: MockSaveToGalleryUseCase(),
    getRecordingsUseCase: MockGetRecordingsUseCase(),
  );

  @override
  RecordingState get state => _state;
  RecordingState _state = const RecordingState();

  void setState(RecordingState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  Stream<Recording?> get currentRecordingStream => Stream.value(null);
}

class MockStartRecordingUseCase extends StartRecordingUseCase {
  MockStartRecordingUseCase() : super(MockRecordingRepository());

  @override
  Future<bool> execute({bool includeAudio = true}) async {
    return true;
  }
}

class MockStopRecordingUseCase extends StopRecordingUseCase {
  MockStopRecordingUseCase() : super(MockRecordingRepository());

  @override
  Future<bool> execute() async {
    return true;
  }
}

class MockSaveToGalleryUseCase extends SaveToGalleryUseCase {
  MockSaveToGalleryUseCase() : super(MockRecordingRepository());

  @override
  Future<bool> execute(Recording recording) async {
    return true;
  }
}

class MockGetRecordingsUseCase extends GetRecordingsUseCase {
  MockGetRecordingsUseCase() : super(MockRecordingRepository());

  @override
  Future<List<Recording>> execute() async {
    return [];
  }

  @override
  Stream<List<Recording>> watchRecordings() {
    return Stream.value([]);
  }
}

class MockRecordingRepository implements RecordingRepository {
  @override
  Future<bool> startRecording({bool includeAudio = true}) async => true;

  @override
  Future<bool> stopRecording() async => true;

  @override
  Future<bool> pauseRecording() async => true;

  @override
  Future<bool> resumeRecording() async => true;

  @override
  Future<Recording?> getCurrentRecording() async => null;

  @override
  Future<List<Recording>> getAllRecordings() async => [];

  @override
  Future<bool> saveToGallery(Recording recording) async => true;

  @override
  Future<bool> deleteRecording(String recordingId) async => true;

  @override
  Future<Recording?> getRecordingById(String id) async => null;

  @override
  Stream<Recording?> get currentRecordingStream => Stream.value(null);

  @override
  Stream<List<Recording>> get recordingsStream => Stream.value([]);
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/domain/entities/recording.dart';
import '../../../lib/domain/repositories/recording_repository.dart';
import '../../../lib/domain/usecases/start_recording_usecase.dart';
import '../../../lib/domain/usecases/stop_recording_usecase.dart';
import '../../../lib/domain/usecases/save_to_gallery_usecase.dart';
import '../../../lib/domain/usecases/get_recordings_usecase.dart';

import 'recording_usecases_test.mocks.dart';

@GenerateMocks([RecordingRepository])
void main() {
  group('Recording Use Cases Tests', () {
    late MockRecordingRepository mockRepository;

    setUp(() {
      mockRepository = MockRecordingRepository();
    });

    group('StartRecordingUseCase', () {
      test('should start recording successfully', () async {
        // Arrange
        final useCase = StartRecordingUseCase(mockRepository);
        when(mockRepository.startRecording(includeAudio: true))
            .thenAnswer((_) async => true);

        // Act
        final result = await useCase.execute(includeAudio: true);

        // Assert
        expect(result, true);
        verify(mockRepository.startRecording(includeAudio: true)).called(1);
      });

      test('should fail to start recording', () async {
        // Arrange
        final useCase = StartRecordingUseCase(mockRepository);
        when(mockRepository.startRecording(includeAudio: false))
            .thenAnswer((_) async => false);

        // Act
        final result = await useCase.execute(includeAudio: false);

        // Assert
        expect(result, false);
        verify(mockRepository.startRecording(includeAudio: false)).called(1);
      });
    });

    group('StopRecordingUseCase', () {
      test('should stop recording successfully', () async {
        // Arrange
        final useCase = StopRecordingUseCase(mockRepository);
        when(mockRepository.stopRecording()).thenAnswer((_) async => true);

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, true);
        verify(mockRepository.stopRecording()).called(1);
      });

      test('should fail to stop recording', () async {
        // Arrange
        final useCase = StopRecordingUseCase(mockRepository);
        when(mockRepository.stopRecording()).thenAnswer((_) async => false);

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, false);
        verify(mockRepository.stopRecording()).called(1);
      });
    });

    group('SaveToGalleryUseCase', () {
      test('should save recording to gallery successfully', () async {
        // Arrange
        final useCase = SaveToGalleryUseCase(mockRepository);
        final recording = Recording(
          id: 'test-id',
          filePath: '/test/path.mp4',
          createdAt: DateTime.now(),
          duration: const Duration(minutes: 1),
          fileSizeBytes: 1024000,
          hasAudio: true,
          status: RecordingStatus.completed,
        );

        when(mockRepository.saveToGallery(recording))
            .thenAnswer((_) async => true);

        // Act
        final result = await useCase.execute(recording);

        // Assert
        expect(result, true);
        verify(mockRepository.saveToGallery(recording)).called(1);
      });

      test('should fail to save recording to gallery', () async {
        // Arrange
        final useCase = SaveToGalleryUseCase(mockRepository);
        final recording = Recording(
          id: 'test-id',
          filePath: '/test/path.mp4',
          createdAt: DateTime.now(),
          duration: const Duration(minutes: 1),
          fileSizeBytes: 1024000,
          hasAudio: true,
          status: RecordingStatus.completed,
        );

        when(mockRepository.saveToGallery(recording))
            .thenAnswer((_) async => false);

        // Act
        final result = await useCase.execute(recording);

        // Assert
        expect(result, false);
        verify(mockRepository.saveToGallery(recording)).called(1);
      });
    });

    group('GetRecordingsUseCase', () {
      test('should get all recordings successfully', () async {
        // Arrange
        final useCase = GetRecordingsUseCase(mockRepository);
        final recordings = [
          Recording(
            id: '1',
            filePath: '/test/path1.mp4',
            createdAt: DateTime.now(),
            duration: const Duration(minutes: 1),
            fileSizeBytes: 1024000,
            hasAudio: true,
            status: RecordingStatus.completed,
          ),
          Recording(
            id: '2',
            filePath: '/test/path2.mp4',
            createdAt: DateTime.now(),
            duration: const Duration(minutes: 2),
            fileSizeBytes: 2048000,
            hasAudio: true,
            status: RecordingStatus.saved,
          ),
        ];

        when(mockRepository.getAllRecordings()).thenAnswer((_) async => recordings);

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
        verify(mockRepository.getAllRecordings()).called(1);
      });

      test('should return empty list when no recordings exist', () async {
        // Arrange
        final useCase = GetRecordingsUseCase(mockRepository);
        when(mockRepository.getAllRecordings()).thenAnswer((_) async => []);

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getAllRecordings()).called(1);
      });

      test('should watch recordings stream', () async {
        // Arrange
        final useCase = GetRecordingsUseCase(mockRepository);
        final recordings = [
          Recording(
            id: '1',
            filePath: '/test/path1.mp4',
            createdAt: DateTime.now(),
            duration: const Duration(minutes: 1),
            fileSizeBytes: 1024000,
            hasAudio: true,
            status: RecordingStatus.completed,
          ),
        ];

        when(mockRepository.recordingsStream)
            .thenAnswer((_) => Stream.value(recordings));

        // Act
        final stream = useCase.watchRecordings();

        // Assert
        expect(stream, isA<Stream<List<Recording>>>());
        verify(mockRepository.recordingsStream).called(1);
      });
    });
  });
}
import 'package:dio/dio.dart';
import '../../domain/entities/animation.dart';

abstract class AnimationRemoteDataSource {
  Future<List<Animation>> getAnimations();
  Future<Animation?> getAnimationById(String id);
}

class AnimationRemoteDataSourceImpl implements AnimationRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  AnimationRemoteDataSourceImpl(this._dio, [this._baseUrl = 'https://api.example.com']);

  @override
  Future<List<Animation>> getAnimations() async {
    try {
      final response = await _dio.get('$_baseUrl/animations');
      
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => _mapToAnimation(json)).toList();
      } else {
        throw Exception('Failed to load animations');
      }
    } catch (e) {
      // Return mock data for now
      return _getMockAnimations();
    }
  }

  @override
  Future<Animation?> getAnimationById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/animations/$id');
      
      if (response.statusCode == 200) {
        return _mapToAnimation(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load animation');
      }
    } catch (e) {
      // Return mock data for now
      final animations = _getMockAnimations();
      try {
        return animations.firstWhere((animation) => animation.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  Animation _mapToAnimation(Map<String, dynamic> json) {
    return Animation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileSize: json['fileSize'] as int,
      duration: json['duration'] as int,
    );
  }

  List<Animation> _getMockAnimations() {
    return [
      Animation(
        id: 'anim_001',
        title: 'Dancing Robot',
        description: 'A fun robot dancing animation',
        fileUrl: 'https://example.com/animations/dancing_robot.mp4',
        thumbnailUrl: 'https://example.com/thumbnails/dancing_robot.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: 5242880, // 5MB
        duration: 30,
      ),
      Animation(
        id: 'anim_002',
        title: 'Floating Particles',
        description: 'Beautiful particle effects animation',
        fileUrl: 'https://example.com/animations/floating_particles.mp4',
        thumbnailUrl: 'https://example.com/thumbnails/floating_particles.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: 8388608, // 8MB
        duration: 45,
      ),
      Animation(
        id: 'anim_003',
        title: 'Colorful Waves',
        description: 'Mesmerizing color wave animation',
        fileUrl: 'https://example.com/animations/colorful_waves.mp4',
        thumbnailUrl: 'https://example.com/thumbnails/colorful_waves.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: 6291456, // 6MB
        duration: 60,
      ),
    ];
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

class AvatarReply {
  final String conversationId;
  final String reply;
  const AvatarReply({required this.conversationId, required this.reply});
}

class AvatarVoiceReply {
  final String conversationId;
  final String transcript;
  final String reply;
  final List<int>? audioBytes;
  const AvatarVoiceReply({
    required this.conversationId,
    required this.transcript,
    required this.reply,
    this.audioBytes,
  });
}

class AvatarCharacter {
  final String id;
  final String displayName;
  final String? imageUrl;
  final String? defaultImageUrl;
  final String? language;
  const AvatarCharacter({
    required this.id,
    required this.displayName,
    this.imageUrl,
    this.defaultImageUrl,
    this.language,
  });

  factory AvatarCharacter.fromJson(Map<String, dynamic> json) {
    return AvatarCharacter(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      defaultImageUrl: json['defaultImageUrl'] as String?,
      language: json['language'] as String?,
    );
  }
}

class AvatarRepository {
  final Dio _dio;
  AvatarRepository(this._dio);

  Future<List<AvatarCharacter>> fetchCharacters() async {
    final res = await _dio.get<List<dynamic>>('/avatar/characters');
    final raw = res.data ?? const <dynamic>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AvatarCharacter.fromJson)
        .toList();
  }

  Future<AvatarReply> ask({
    required String character,
    required String question,
    String? conversationId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/avatar/$character/ask',
      data: {
        'question': question,
        'conversationId': ?conversationId,
      },
    );
    final data = res.data ?? const {};
    return AvatarReply(
      conversationId: data['conversationId'] as String? ?? '',
      reply: data['reply'] as String? ?? '',
    );
  }

  Future<AvatarVoiceReply> askVoice({
    required String character,
    required File audio,
    String? conversationId,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audio.path, filename: 'voice.m4a'),
      'conversationId': ?conversationId,
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/avatar/$character/ask-voice',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data ?? const {};
    final b64 = data['audioBase64'] as String?;
    return AvatarVoiceReply(
      conversationId: data['conversationId'] as String? ?? '',
      transcript: data['transcript'] as String? ?? '',
      reply: data['reply'] as String? ?? '',
      audioBytes: b64 == null || b64.isEmpty ? null : base64Decode(b64),
    );
  }
}

final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return AvatarRepository(ref.watch(apiClientProvider));
});

final avatarCharactersProvider =
    FutureProvider.autoDispose<List<AvatarCharacter>>((ref) {
  return ref.watch(avatarRepositoryProvider).fetchCharacters();
});

final khwarizmiCharacterProvider =
    Provider.autoDispose<AsyncValue<AvatarCharacter?>>((ref) {
  return ref.watch(avatarCharactersProvider).whenData(
        (list) => list
            .cast<AvatarCharacter?>()
            .firstWhere((c) => c?.id == 'khwarizmi', orElse: () => null),
      );
});

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

class AvatarHistorySession {
  final String conversationId;
  final String lastMessage;
  final String lastRole;
  final int messageCount;
  final DateTime updatedAt;
  const AvatarHistorySession({
    required this.conversationId,
    required this.lastMessage,
    required this.lastRole,
    required this.messageCount,
    required this.updatedAt,
  });

  factory AvatarHistorySession.fromJson(Map<String, dynamic> json) {
    return AvatarHistorySession(
      conversationId: json['conversationId'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastRole: json['lastRole'] as String? ?? 'user',
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AvatarHistoryMessage {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  const AvatarHistoryMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AvatarHistoryMessage.fromJson(Map<String, dynamic> json) {
    return AvatarHistoryMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
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

  Future<List<AvatarHistorySession>> fetchHistory(String character) async {
    final res = await _dio.get<Map<String, dynamic>>('/avatar/$character/history');
    final data = res.data ?? const <String, dynamic>{};
    final list = data['sessions'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AvatarHistorySession.fromJson)
        .toList();
  }

  Future<List<AvatarHistoryMessage>> fetchSessionMessages({
    required String character,
    required String conversationId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/avatar/$character/history/$conversationId',
    );
    final data = res.data ?? const <String, dynamic>{};
    final list = data['messages'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AvatarHistoryMessage.fromJson)
        .toList();
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

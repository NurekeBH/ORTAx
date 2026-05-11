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

class AvatarRepository {
  final Dio _dio;
  AvatarRepository(this._dio);

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

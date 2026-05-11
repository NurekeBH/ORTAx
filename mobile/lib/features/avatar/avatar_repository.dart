import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

class AvatarReply {
  final String conversationId;
  final String reply;
  const AvatarReply({required this.conversationId, required this.reply});
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
}

final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return AvatarRepository(ref.watch(apiClientProvider));
});

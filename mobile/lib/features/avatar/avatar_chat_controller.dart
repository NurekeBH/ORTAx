import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'avatar_repository.dart';

enum ChatRole { user, avatar }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime at;
  const ChatMessage({required this.role, required this.text, required this.at});
}

class AvatarChatState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final String? conversationId;

  const AvatarChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
    this.conversationId,
  });

  AvatarChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    String? conversationId,
    bool clearError = false,
  }) {
    return AvatarChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

class AvatarChatController extends Notifier<AvatarChatState> {
  static const _character = 'khwarizmi';

  @override
  AvatarChatState build() {
    return const AvatarChatState();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.loading) return;

    final userMsg = ChatMessage(role: ChatRole.user, text: trimmed, at: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      loading: true,
      clearError: true,
    );

    try {
      final repo = ref.read(avatarRepositoryProvider);
      final res = await repo.ask(
        character: _character,
        question: trimmed,
        conversationId: state.conversationId,
      );
      final reply = ChatMessage(role: ChatRole.avatar, text: res.reply, at: DateTime.now());
      state = state.copyWith(
        messages: [...state.messages, reply],
        loading: false,
        conversationId: res.conversationId,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clear() {
    state = const AvatarChatState();
  }
}

final avatarChatProvider = NotifierProvider<AvatarChatController, AvatarChatState>(
  AvatarChatController.new,
);

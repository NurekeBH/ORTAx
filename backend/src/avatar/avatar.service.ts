import { Injectable, Logger, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { ChatLog, ChatLogSource } from './chat-log.entity';
import { LlmService, ChatMessage } from './llm.service';
import { CHARACTERS, CharacterId } from './prompts/characters';

interface ConversationState {
  messages: ChatMessage[];
  updatedAt: number;
}

export interface AskContext {
  source?: ChatLogSource;
  userId?: string;
  telegramUserId?: string;
}

@Injectable()
export class AvatarService {
  private readonly logger = new Logger(AvatarService.name);
  private readonly conversations = new Map<string, ConversationState>();
  private readonly maxHistory = 12;
  private readonly ttlMs = 60 * 60 * 1000;

  constructor(
    private readonly llm: LlmService,
    @Optional()
    @InjectRepository(ChatLog)
    private readonly chatLogs?: Repository<ChatLog>,
  ) {}

  greeting(character: CharacterId): string {
    return CHARACTERS[character].greeting;
  }

  displayName(character: CharacterId): string {
    return CHARACTERS[character].displayName;
  }

  reset(conversationId: string, character: CharacterId): void {
    this.conversations.delete(this.key(conversationId, character));
  }

  async ask(
    conversationId: string,
    character: CharacterId,
    userMessage: string,
    context: AskContext = {},
  ): Promise<string> {
    this.gc();
    const key = this.key(conversationId, character);
    const state = this.conversations.get(key) ?? this.create();
    state.messages.push({ role: 'user', content: userMessage });
    this.trim(state);

    const reply = await this.llm.chat([
      { role: 'system', content: CHARACTERS[character].systemPrompt },
      ...state.messages,
    ]);

    state.messages.push({ role: 'assistant', content: reply });
    state.updatedAt = Date.now();
    this.conversations.set(key, state);

    void this.persistLog(conversationId, character, 'user', userMessage, context);
    void this.persistLog(conversationId, character, 'assistant', reply, context);

    return reply;
  }

  private async persistLog(
    conversationId: string,
    character: CharacterId,
    role: 'user' | 'assistant',
    content: string,
    context: AskContext,
  ): Promise<void> {
    if (!this.chatLogs) return;
    try {
      await this.chatLogs.insert({
        conversationId,
        character,
        role,
        content,
        source: context.source ?? 'mobile',
        userId: context.userId,
        telegramUserId: context.telegramUserId,
      });
    } catch (err) {
      this.logger.warn(`Failed to persist chat log: ${(err as Error).message}`);
    }
  }

  private key(conversationId: string, character: CharacterId): string {
    return `${character}:${conversationId}`;
  }

  private create(): ConversationState {
    return { messages: [], updatedAt: Date.now() };
  }

  private trim(state: ConversationState) {
    if (state.messages.length > this.maxHistory) {
      state.messages = state.messages.slice(-this.maxHistory);
    }
  }

  private gc() {
    const now = Date.now();
    for (const [id, state] of this.conversations) {
      if (now - state.updatedAt > this.ttlMs) {
        this.conversations.delete(id);
      }
    }
  }
}

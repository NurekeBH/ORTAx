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

  /// Қолданушының барлық сессияларын (conversationId бойынша) тізімдеу.
  async listUserSessions(
    userId: string,
    character: CharacterId,
  ): Promise<
    Array<{
      conversationId: string;
      lastMessage: string;
      lastRole: 'user' | 'assistant';
      messageCount: number;
      updatedAt: Date;
    }>
  > {
    if (!this.chatLogs) return [];
    const rows = await this.chatLogs
      .createQueryBuilder('log')
      .select([
        'log.conversation_id AS "conversationId"',
        'MAX(log.created_at) AS "updatedAt"',
        'COUNT(*) AS "messageCount"',
      ])
      .where('log.user_id = :userId', { userId })
      .andWhere('log.character = :character', { character })
      .groupBy('log.conversation_id')
      .orderBy('"updatedAt"', 'DESC')
      .limit(50)
      .getRawMany<{ conversationId: string; updatedAt: string; messageCount: string }>();

    if (rows.length === 0) return [];
    const ids = rows.map((r) => r.conversationId);
    const latests = await this.chatLogs
      .createQueryBuilder('log')
      .where('log.conversation_id IN (:...ids)', { ids })
      .orderBy('log.created_at', 'DESC')
      .getMany();
    const latestByConv = new Map<string, ChatLog>();
    for (const row of latests) {
      if (!latestByConv.has(row.conversationId)) {
        latestByConv.set(row.conversationId, row);
      }
    }
    return rows.map((r) => {
      const latest = latestByConv.get(r.conversationId);
      return {
        conversationId: r.conversationId,
        lastMessage: latest?.content ?? '',
        lastRole: (latest?.role ?? 'user') as 'user' | 'assistant',
        messageCount: parseInt(r.messageCount, 10),
        updatedAt: new Date(r.updatedAt),
      };
    });
  }

  /// Бір сессияның толық хабарламалары (chronological).
  async getSessionMessages(
    userId: string,
    character: CharacterId,
    conversationId: string,
  ): Promise<ChatLog[]> {
    if (!this.chatLogs) return [];
    return this.chatLogs.find({
      where: { userId, character, conversationId },
      order: { createdAt: 'ASC' },
    });
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

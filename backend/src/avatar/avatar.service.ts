import { Injectable, Logger } from '@nestjs/common';

import { LlmService, ChatMessage } from './llm.service';
import { CHARACTERS, CharacterId } from './prompts/characters';

interface ConversationState {
  messages: ChatMessage[];
  updatedAt: number;
}

@Injectable()
export class AvatarService {
  private readonly logger = new Logger(AvatarService.name);
  private readonly conversations = new Map<string, ConversationState>();
  private readonly maxHistory = 12;
  private readonly ttlMs = 60 * 60 * 1000;

  constructor(private readonly llm: LlmService) {}

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
    return reply;
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

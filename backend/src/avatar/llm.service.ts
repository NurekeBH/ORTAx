import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

@Injectable()
export class LlmService implements OnModuleInit {
  private readonly logger = new Logger(LlmService.name);
  private client!: OpenAI;
  private model!: string;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    const apiKey = this.config.get<string>('OPENAI_API_KEY');
    if (!apiKey) {
      this.logger.warn('OPENAI_API_KEY not set — LLM calls will fail');
    }
    this.client = new OpenAI({ apiKey });
    this.model = this.config.get<string>('OPENAI_MODEL') ?? 'gpt-4o-mini';
  }

  async chat(messages: ChatMessage[]): Promise<string> {
    const completion = await this.client.chat.completions.create({
      model: this.model,
      messages,
      temperature: 0.7,
      max_tokens: 800,
    });
    const reply = completion.choices[0]?.message?.content?.trim();
    if (!reply) throw new Error('Empty LLM reply');
    return reply;
  }
}

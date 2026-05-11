import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

export type TtsVoice = 'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer';
export type TtsFormat = 'opus' | 'mp3' | 'aac' | 'flac' | 'wav';

@Injectable()
export class TtsService implements OnModuleInit {
  private readonly logger = new Logger(TtsService.name);
  private client!: OpenAI;
  private model!: string;
  private voice!: TtsVoice;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    this.client = new OpenAI({
      apiKey: this.config.get<string>('OPENAI_API_KEY'),
    });
    this.model = this.config.get<string>('TTS_MODEL') ?? 'tts-1';
    this.voice = (this.config.get<string>('TTS_VOICE') ?? 'onyx') as TtsVoice;
  }

  async synthesize(text: string, format: TtsFormat = 'opus'): Promise<Buffer> {
    const response = await this.client.audio.speech.create({
      model: this.model,
      voice: this.voice,
      input: this.prepareText(text),
      response_format: format,
      speed: 0.92,
    });
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }

  private prepareText(text: string): string {
    return text.length > 1500 ? `${text.slice(0, 1497)}...` : text;
  }
}

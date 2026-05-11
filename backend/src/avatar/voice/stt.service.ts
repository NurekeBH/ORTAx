import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI, { toFile } from 'openai';

@Injectable()
export class SttService implements OnModuleInit {
  private readonly logger = new Logger(SttService.name);
  private client!: OpenAI;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    this.client = new OpenAI({
      apiKey: this.config.get<string>('OPENAI_API_KEY'),
    });
  }

  async transcribe(
    audio: Buffer,
    filename = 'voice.ogg',
    language?: string,
  ): Promise<string> {
    const file = await toFile(audio, filename);
    const result = await this.client.audio.transcriptions.create({
      file,
      model: 'whisper-1',
      ...(language ? { language } : {}),
    });
    return result.text.trim();
  }
}

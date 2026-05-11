import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { randomUUID } from 'node:crypto';

import { AvatarService } from './avatar.service';
import { AskDto } from './dto/ask.dto';
import { CHARACTERS, isCharacterId } from './prompts/characters';
import { SttService } from './voice/stt.service';
import { TtsService } from './voice/tts.service';

@Controller('avatar')
export class AvatarController {
  constructor(
    private readonly avatar: AvatarService,
    private readonly stt: SttService,
    private readonly tts: TtsService,
  ) {}

  @Get(':character/greeting')
  greeting(@Param('character') character: string) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    return { character, greeting: this.avatar.greeting(character) };
  }

  @Post(':character/ask')
  async ask(@Param('character') character: string, @Body() dto: AskDto) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    const conversationId = dto.conversationId ?? randomUUID();
    const reply = await this.avatar.ask(conversationId, character, dto.question);
    return { conversationId, character, reply };
  }

  @Post(':character/ask-voice')
  @UseInterceptors(FileInterceptor('audio'))
  async askVoice(
    @Param('character') character: string,
    @UploadedFile() file: Express.Multer.File,
    @Body('conversationId') conversationIdInput?: string,
  ) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    if (!file?.buffer || file.buffer.length === 0) {
      return { error: 'audio file required (field: audio)' };
    }

    const conversationId = conversationIdInput ?? randomUUID();
    const transcript = await this.stt.transcribe(
      file.buffer,
      file.originalname || 'voice.m4a',
      CHARACTERS[character].language,
    );
    if (!transcript) {
      return { conversationId, character, transcript: '', reply: '', audioBase64: null };
    }

    const reply = await this.avatar.ask(conversationId, character, transcript);
    const audio = await this.tts.synthesize(reply, 'mp3');

    return {
      conversationId,
      character,
      transcript,
      reply,
      audioBase64: audio.toString('base64'),
      audioMime: 'audio/mpeg',
    };
  }
}

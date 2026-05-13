import {
  Body,
  Controller,
  Get,
  Optional,
  Param,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import type { Request } from 'express';
import { Repository } from 'typeorm';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/optional-jwt.guard';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { AvatarOverride } from './avatar-override.entity';
import { AvatarService } from './avatar.service';
import { AskDto } from './dto/ask.dto';
import { CHARACTERS, isCharacterId } from './prompts/characters';
import { SttService } from './voice/stt.service';
import { TtsService } from './voice/tts.service';

type ReqWithOptionalUser = Request & { user?: AuthenticatedUser };
type ReqWithUser = Request & { user: AuthenticatedUser };

@Controller('avatar')
export class AvatarController {
  constructor(
    private readonly avatar: AvatarService,
    private readonly stt: SttService,
    private readonly tts: TtsService,
    @Optional()
    @InjectRepository(AvatarOverride)
    private readonly overrides?: Repository<AvatarOverride>,
  ) {}

  @Get('characters')
  async listCharacters() {
    const overrideRows = this.overrides ? await this.overrides.find() : [];
    const overrideMap = new Map(overrideRows.map((o) => [o.character, o]));
    return Object.values(CHARACTERS).map((c) => {
      const override = overrideMap.get(c.id);
      return {
        id: c.id,
        displayName: c.displayName,
        greeting: c.greeting,
        helpText: c.helpText,
        language: c.language ?? null,
        defaultImageUrl: c.defaultImageUrl ?? null,
        imageUrl: override?.imageUrl ?? c.defaultImageUrl ?? null,
      };
    });
  }

  @Get(':character/greeting')
  greeting(@Param('character') character: string) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    return { character, greeting: this.avatar.greeting(character) };
  }

  @Post(':character/ask')
  @UseGuards(OptionalJwtAuthGuard)
  async ask(
    @Param('character') character: string,
    @Body() dto: AskDto,
    @Req() req: ReqWithOptionalUser,
  ) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    const conversationId = dto.conversationId ?? randomUUID();
    const reply = await this.avatar.ask(conversationId, character, dto.question, {
      source: 'mobile',
      userId: req.user?.userId,
    });
    return { conversationId, character, reply };
  }

  @Post(':character/ask-voice')
  @UseGuards(OptionalJwtAuthGuard)
  @UseInterceptors(FileInterceptor('audio'))
  async askVoice(
    @Param('character') character: string,
    @UploadedFile() file: Express.Multer.File,
    @Body('conversationId') conversationIdInput: string | undefined,
    @Req() req: ReqWithOptionalUser,
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

    const reply = await this.avatar.ask(conversationId, character, transcript, {
      source: 'mobile',
      userId: req.user?.userId,
    });
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

  /// Авторизацияланған юзердің берілген кейіпкермен бар сессиялар тізімі.
  @Get(':character/history')
  @UseGuards(JwtAuthGuard)
  async listHistory(
    @Param('character') character: string,
    @Req() req: ReqWithUser,
  ) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    const sessions = await this.avatar.listUserSessions(req.user.userId, character);
    return {
      character,
      sessions: sessions.map((s) => ({
        conversationId: s.conversationId,
        lastMessage: s.lastMessage,
        lastRole: s.lastRole,
        messageCount: s.messageCount,
        updatedAt: s.updatedAt.toISOString(),
      })),
    };
  }

  /// Бір conversation-ның толық тарихы (chronological).
  @Get(':character/history/:conversationId')
  @UseGuards(JwtAuthGuard)
  async getHistoryMessages(
    @Param('character') character: string,
    @Param('conversationId') conversationId: string,
    @Req() req: ReqWithUser,
  ) {
    if (!isCharacterId(character)) {
      return { error: 'unknown character' };
    }
    const messages = await this.avatar.getSessionMessages(
      req.user.userId,
      character,
      conversationId,
    );
    return {
      character,
      conversationId,
      messages: messages.map((m) => ({
        id: m.id,
        role: m.role,
        content: m.content,
        createdAt: m.createdAt.toISOString(),
      })),
    };
  }
}

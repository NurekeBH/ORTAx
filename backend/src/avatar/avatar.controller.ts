import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

import { AvatarService } from './avatar.service';
import { AskDto } from './dto/ask.dto';
import { isCharacterId } from './prompts/characters';

@Controller('avatar')
export class AvatarController {
  constructor(private readonly avatar: AvatarService) {}

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
}

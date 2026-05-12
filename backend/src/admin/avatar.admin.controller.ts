import {
  Body,
  Controller,
  Get,
  Optional,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IsOptional, IsString } from 'class-validator';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AvatarOverride } from '../avatar/avatar-override.entity';
import { ChatLog } from '../avatar/chat-log.entity';
import { CHARACTERS, isCharacterId } from '../avatar/prompts/characters';
import { ChatLogQueryDto } from './dto/admin.dto';

class UpdateCharacterImageDto {
  @IsOptional()
  @IsString()
  imageUrl?: string;
}

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/avatar')
export class AvatarAdminController {
  constructor(
    @Optional()
    @InjectRepository(ChatLog)
    private readonly chatLogs?: Repository<ChatLog>,
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
        systemPrompt: c.systemPrompt,
        defaultImageUrl: c.defaultImageUrl ?? null,
        imageUrl: override?.imageUrl ?? c.defaultImageUrl ?? null,
        hasOverride: !!override?.imageUrl,
      };
    });
  }

  @Patch('characters/:id/image')
  async setCharacterImage(
    @Param('id') id: string,
    @Body() body: UpdateCharacterImageDto,
  ) {
    if (!isCharacterId(id)) {
      return { ok: false, error: 'unknown character' };
    }
    if (!this.overrides) {
      return { ok: false, error: 'database disabled' };
    }
    const existing = await this.overrides.findOne({ where: { character: id } });
    if (!body.imageUrl) {
      if (existing) await this.overrides.delete({ character: id });
      const def = CHARACTERS[id].defaultImageUrl ?? null;
      return { ok: true, imageUrl: def, hasOverride: false };
    }
    if (existing) {
      existing.imageUrl = body.imageUrl;
      await this.overrides.save(existing);
    } else {
      await this.overrides.save(
        this.overrides.create({ character: id, imageUrl: body.imageUrl }),
      );
    }
    return { ok: true, imageUrl: body.imageUrl, hasOverride: true };
  }

  @Get('logs')
  async listLogs(@Query() query: ChatLogQueryDto) {
    if (!this.chatLogs) return { items: [], total: 0 };
    const page = Math.max(query.page ?? 1, 1);
    const pageSize = Math.min(Math.max(query.pageSize ?? 50, 1), 200);
    const where: Record<string, unknown> = {};
    if (query.character) where.character = query.character;
    if (query.conversationId) where.conversationId = query.conversationId;
    if (query.source) where.source = query.source;
    const [items, total] = await this.chatLogs.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total };
  }

  @Get('conversations')
  async listConversations(@Query('character') character?: string) {
    if (!this.chatLogs) return { items: [] };
    const qb = this.chatLogs
      .createQueryBuilder('l')
      .select('l.conversation_id', 'conversationId')
      .addSelect('l.character', 'character')
      .addSelect('MAX(l.created_at)', 'lastAt')
      .addSelect('COUNT(*)', 'messageCount')
      .groupBy('l.conversation_id')
      .addGroupBy('l.character')
      .orderBy('"lastAt"', 'DESC')
      .limit(100);
    if (character) qb.where('l.character = :character', { character });
    const items = await qb.getRawMany();
    return { items };
  }
}

import { Controller, Get, Optional, Query, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ChatLog } from '../avatar/chat-log.entity';
import { CHARACTERS } from '../avatar/prompts/characters';
import { ChatLogQueryDto } from './dto/admin.dto';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/avatar')
export class AvatarAdminController {
  constructor(
    @Optional()
    @InjectRepository(ChatLog)
    private readonly chatLogs?: Repository<ChatLog>,
  ) {}

  @Get('characters')
  listCharacters() {
    return Object.values(CHARACTERS).map((c) => ({
      id: c.id,
      displayName: c.displayName,
      greeting: c.greeting,
      helpText: c.helpText,
      language: c.language ?? null,
      systemPrompt: c.systemPrompt,
    }));
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

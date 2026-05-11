import { Controller, Get, Optional, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { MoreThan, Repository } from 'typeorm';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ChatLog } from '../avatar/chat-log.entity';
import { JournalsService } from '../journals/journals.service';
import { TelegramUser } from '../telegram/telegram-user.entity';
import { UsersService } from '../users/users.service';

const DAY_MS = 24 * 60 * 60 * 1000;

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/analytics')
export class AnalyticsAdminController {
  constructor(
    private readonly users: UsersService,
    private readonly journals: JournalsService,
    @Optional()
    @InjectRepository(ChatLog)
    private readonly chatLogs?: Repository<ChatLog>,
    @Optional()
    @InjectRepository(TelegramUser)
    private readonly tgUsers?: Repository<TelegramUser>,
  ) {}

  @Get('overview')
  async overview() {
    const now = Date.now();
    const since24h = new Date(now - DAY_MS);
    const since7d = new Date(now - 7 * DAY_MS);
    const since30d = new Date(now - 30 * DAY_MS);

    const [totalUsers, dau, wau, mau] = await Promise.all([
      this.users.countAll(),
      this.users.countActiveSince(since24h),
      this.users.countActiveSince(since7d),
      this.users.countActiveSince(since30d),
    ]);

    const [journals, pages, assets] = await Promise.all([
      this.journals.countJournals(),
      this.journals.countPages(),
      this.journals.countAssets(),
    ]);

    const chatMessages24h = this.chatLogs
      ? await this.chatLogs.count({ where: { createdAt: MoreThan(since24h) } })
      : 0;
    const chatMessagesTotal = this.chatLogs ? await this.chatLogs.count() : 0;

    const tgUsersTotal = this.tgUsers ? await this.tgUsers.count() : 0;
    const tgBanned = this.tgUsers
      ? await this.tgUsers.count({ where: { banned: true } })
      : 0;

    return {
      users: { total: totalUsers, dau, wau, mau },
      content: { journals, pages, arAssets: assets },
      avatar: { messages24h: chatMessages24h, messagesTotal: chatMessagesTotal },
      telegram: { total: tgUsersTotal, banned: tgBanned },
    };
  }

  @Get('chat-by-day')
  async chatByDay() {
    if (!this.chatLogs) return { items: [] };
    const since = new Date(Date.now() - 30 * DAY_MS);
    const rows = await this.chatLogs
      .createQueryBuilder('l')
      .select("DATE_TRUNC('day', l.created_at)", 'day')
      .addSelect('l.character', 'character')
      .addSelect('COUNT(*)', 'count')
      .where('l.created_at >= :since', { since })
      .groupBy('day')
      .addGroupBy('l.character')
      .orderBy('day', 'ASC')
      .getRawMany();
    return { items: rows };
  }
}

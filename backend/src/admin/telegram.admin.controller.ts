import {
  Body,
  Controller,
  Get,
  Optional,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CharacterId, isCharacterId } from '../avatar/prompts/characters';
import { TelegramService } from '../telegram/telegram.service';
import { TelegramUser } from '../telegram/telegram-user.entity';
import { BroadcastDto, PaginationDto, UpdateUserBanDto } from './dto/admin.dto';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/telegram')
export class TelegramAdminController {
  constructor(
    private readonly telegram: TelegramService,
    @Optional()
    @InjectRepository(TelegramUser)
    private readonly tgUsers?: Repository<TelegramUser>,
  ) {}

  @Get('users')
  async listUsers(
    @Query() query: PaginationDto,
    @Query('search') search?: string,
    @Query('character') character?: string,
  ) {
    if (!this.tgUsers) return { items: [], total: 0 };
    const page = Math.max(query.page ?? 1, 1);
    const pageSize = Math.min(Math.max(query.pageSize ?? 50, 1), 200);
    const where: Record<string, unknown> = {};
    if (search) where.username = ILike(`%${search}%`);
    if (character) where.lastCharacter = character;
    const [items, total] = await this.tgUsers.findAndCount({
      where,
      order: { updatedAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total };
  }

  @Patch('users/:id/ban')
  async setBanned(
    @Param('id') id: string,
    @Body() body: UpdateUserBanDto,
  ) {
    if (!this.tgUsers) return { ok: false };
    await this.tgUsers.update({ telegramId: id }, { banned: body.banned });
    return { ok: true };
  }

  @Post('broadcast')
  async broadcast(@Body() body: BroadcastDto) {
    if (!isCharacterId(body.character)) {
      return { ok: false, error: 'unknown character' };
    }
    return this.telegram.broadcast(
      body.character as CharacterId,
      body.message,
    );
  }
}

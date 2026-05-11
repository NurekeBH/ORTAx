import { DynamicModule, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AvatarModule } from '../avatar/avatar.module';
import { TelegramService } from './telegram.service';
import { TelegramUser } from './telegram-user.entity';

const dbEnabled = process.env.DB_ENABLED !== 'false';

const dbImports: DynamicModule[] = dbEnabled
  ? [TypeOrmModule.forFeature([TelegramUser])]
  : [];

@Module({
  imports: [AvatarModule, ...dbImports],
  providers: [TelegramService],
  exports: [TelegramService, ...dbImports],
})
export class TelegramModule {}

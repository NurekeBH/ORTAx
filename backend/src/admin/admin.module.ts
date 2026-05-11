import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { AvatarModule } from '../avatar/avatar.module';
import { JournalsModule } from '../journals/journals.module';
import { TelegramModule } from '../telegram/telegram.module';
import { UsersModule } from '../users/users.module';
import { AnalyticsAdminController } from './analytics.admin.controller';
import { AvatarAdminController } from './avatar.admin.controller';
import { JournalsAdminController } from './journals.admin.controller';
import { TelegramAdminController } from './telegram.admin.controller';
import { UsersAdminController } from './users.admin.controller';

@Module({
  imports: [
    AuthModule,
    UsersModule,
    JournalsModule,
    AvatarModule,
    TelegramModule,
  ],
  controllers: [
    UsersAdminController,
    JournalsAdminController,
    AvatarAdminController,
    TelegramAdminController,
    AnalyticsAdminController,
  ],
})
export class AdminModule {}

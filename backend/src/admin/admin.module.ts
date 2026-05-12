import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { AvatarModule } from '../avatar/avatar.module';
import { JournalsModule } from '../journals/journals.module';
import { OnboardingModule } from '../onboarding/onboarding.module';
import { TelegramModule } from '../telegram/telegram.module';
import { UsersModule } from '../users/users.module';
import { AnalyticsAdminController } from './analytics.admin.controller';
import { AvatarAdminController } from './avatar.admin.controller';
import { CategoriesAdminController } from './categories.admin.controller';
import { JournalsAdminController } from './journals.admin.controller';
import { LibraryAdminController } from './library.admin.controller';
import { OnboardingAdminController } from './onboarding.admin.controller';
import { TelegramAdminController } from './telegram.admin.controller';
import { UploadsAdminController } from './uploads.admin.controller';
import { UsersAdminController } from './users.admin.controller';

@Module({
  imports: [
    AuthModule,
    UsersModule,
    JournalsModule,
    AvatarModule,
    TelegramModule,
    OnboardingModule,
  ],
  controllers: [
    UsersAdminController,
    JournalsAdminController,
    CategoriesAdminController,
    AvatarAdminController,
    TelegramAdminController,
    AnalyticsAdminController,
    OnboardingAdminController,
    UploadsAdminController,
    LibraryAdminController,
  ],
})
export class AdminModule {}

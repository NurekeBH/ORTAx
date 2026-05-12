import { DynamicModule, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { AvatarModule } from './avatar/avatar.module';
import { AvatarOverride } from './avatar/avatar-override.entity';
import { ChatLog } from './avatar/chat-log.entity';
import { Category } from './journals/category.entity';
import { Journal } from './journals/journal.entity';
import { JournalsModule } from './journals/journals.module';
import { LiveAvatarModule } from './live-avatar/live-avatar.module';
import { Page } from './journals/page.entity';
import { ArAsset } from './journals/ar-asset.entity';
import { OnboardingModule } from './onboarding/onboarding.module';
import { OnboardingSlide } from './onboarding/onboarding-slide.entity';
import { TelegramModule } from './telegram/telegram.module';
import { TelegramUser } from './telegram/telegram-user.entity';
import { User } from './users/user.entity';
import { UsersModule } from './users/users.module';

const dbEnabled = process.env.DB_ENABLED !== 'false';

const dbImports: DynamicModule[] = dbEnabled
  ? [
      TypeOrmModule.forRootAsync({
        inject: [ConfigService],
        useFactory: (config: ConfigService) => ({
          type: 'postgres' as const,
          host: config.get<string>('DB_HOST') ?? 'localhost',
          port: parseInt(config.get<string>('DB_PORT') ?? '5432', 10),
          username: config.get<string>('DB_USER') ?? 'ortax',
          password: config.get<string>('DB_PASSWORD') ?? 'ortax',
          database: config.get<string>('DB_NAME') ?? 'ortax',
          entities: [User, Journal, Page, ArAsset, Category, ChatLog, AvatarOverride, TelegramUser, OnboardingSlide],
          synchronize: (config.get<string>('DB_SYNCHRONIZE') ?? 'true') !== 'false',
        }),
      }),
    ]
  : [];

const featureImports = dbEnabled
  ? [UsersModule, AuthModule, JournalsModule, OnboardingModule, AdminModule]
  : [];

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ...dbImports,
    ...featureImports,
    AvatarModule,
    LiveAvatarModule,
    TelegramModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

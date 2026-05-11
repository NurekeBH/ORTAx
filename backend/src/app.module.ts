import { DynamicModule, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { AvatarModule } from './avatar/avatar.module';
import { ChatLog } from './avatar/chat-log.entity';
import { Journal } from './journals/journal.entity';
import { JournalsModule } from './journals/journals.module';
import { Page } from './journals/page.entity';
import { ArAsset } from './journals/ar-asset.entity';
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
          entities: [User, Journal, Page, ArAsset, ChatLog, TelegramUser],
          synchronize: config.get<string>('NODE_ENV') !== 'production',
        }),
      }),
    ]
  : [];

const featureImports = dbEnabled
  ? [UsersModule, AuthModule, JournalsModule, AdminModule]
  : [];

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ...dbImports,
    ...featureImports,
    AvatarModule,
    TelegramModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

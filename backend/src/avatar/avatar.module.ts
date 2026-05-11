import { DynamicModule, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AvatarController } from './avatar.controller';
import { AvatarService } from './avatar.service';
import { ChatLog } from './chat-log.entity';
import { LlmService } from './llm.service';
import { SttService } from './voice/stt.service';
import { TtsService } from './voice/tts.service';

const dbEnabled = process.env.DB_ENABLED !== 'false';

const dbImports: DynamicModule[] = dbEnabled
  ? [TypeOrmModule.forFeature([ChatLog])]
  : [];

@Module({
  imports: [...dbImports],
  controllers: [AvatarController],
  providers: [AvatarService, LlmService, SttService, TtsService],
  exports: [AvatarService, SttService, TtsService, ...dbImports],
})
export class AvatarModule {}

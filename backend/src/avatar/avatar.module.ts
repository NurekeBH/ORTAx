import { Module } from '@nestjs/common';

import { AvatarController } from './avatar.controller';
import { AvatarService } from './avatar.service';
import { LlmService } from './llm.service';
import { SttService } from './voice/stt.service';
import { TtsService } from './voice/tts.service';

@Module({
  controllers: [AvatarController],
  providers: [AvatarService, LlmService, SttService, TtsService],
  exports: [AvatarService, SttService, TtsService],
})
export class AvatarModule {}

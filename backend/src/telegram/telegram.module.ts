import { Module } from '@nestjs/common';

import { AvatarModule } from '../avatar/avatar.module';
import { TelegramService } from './telegram.service';

@Module({
  imports: [AvatarModule],
  providers: [TelegramService],
})
export class TelegramModule {}

import { Module } from '@nestjs/common';

import { LiveAvatarController } from './live-avatar.controller';

@Module({
  controllers: [LiveAvatarController],
})
export class LiveAvatarModule {}

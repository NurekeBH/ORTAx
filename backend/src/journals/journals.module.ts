import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ArAsset } from './ar-asset.entity';
import { Journal } from './journal.entity';
import { JournalsController } from './journals.controller';
import { JournalsService } from './journals.service';
import { Page } from './page.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Journal, Page, ArAsset])],
  controllers: [JournalsController],
  providers: [JournalsService],
  exports: [JournalsService, TypeOrmModule],
})
export class JournalsModule {}

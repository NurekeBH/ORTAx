import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ArAsset } from './ar-asset.entity';
import { CategoriesService } from './categories.service';
import { Category } from './category.entity';
import { Journal } from './journal.entity';
import { JournalsController } from './journals.controller';
import { JournalsService } from './journals.service';
import { Page } from './page.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Journal, Page, ArAsset, Category])],
  controllers: [JournalsController],
  providers: [JournalsService, CategoriesService],
  exports: [JournalsService, CategoriesService, TypeOrmModule],
})
export class JournalsModule {}

import {
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CategoriesService } from './categories.service';
import { JournalsService } from './journals.service';

@UseGuards(JwtAuthGuard)
@Controller('journals')
export class JournalsController {
  constructor(
    private readonly journals: JournalsService,
    private readonly categories: CategoriesService,
  ) {}

  @Get()
  list(
    @Query('category') category?: string,
    @Query('gradeLevel') gradeLevel?: string,
    @Query('language') language?: string,
    @Query('featured') featured?: string,
    @Query('search') search?: string,
  ) {
    return this.journals.list({
      category,
      gradeLevel,
      language,
      featured: featured === undefined ? undefined : featured === 'true',
      search,
    });
  }

  @Get('categories')
  listCategories() {
    return this.categories.list();
  }

  @Get('slug/:slug')
  async findBySlug(@Param('slug') slug: string) {
    const journal = await this.journals.findBySlug(slug);
    void this.journals.incrementViews(journal.id);
    return journal;
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const journal = await this.journals.findOne(id);
    void this.journals.incrementViews(journal.id);
    return journal;
  }

  @Post(':id/view')
  async view(@Param('id') id: string) {
    await this.journals.incrementViews(id);
    return { ok: true };
  }
}

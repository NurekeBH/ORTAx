import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CategoriesService } from '../journals/categories.service';
import { CreateCategoryDto, UpdateCategoryDto } from './dto/admin.dto';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/categories')
export class CategoriesAdminController {
  constructor(private readonly categories: CategoriesService) {}

  @Get()
  list() {
    return this.categories.list();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.categories.findOne(id);
  }

  @Post()
  create(@Body() body: CreateCategoryDto) {
    return this.categories.create(body);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() body: UpdateCategoryDto) {
    return this.categories.update(id, body);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.categories.remove(id);
    return { ok: true };
  }
}

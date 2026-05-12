import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { JournalsService } from '../journals/journals.service';
import {
  CreateArAssetDto,
  CreateJournalDto,
  CreatePageDto,
  ListJournalsDto,
  UpdateArAssetDto,
  UpdateJournalDto,
  UpdatePageDto,
} from './dto/admin.dto';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/journals')
export class JournalsAdminController {
  constructor(private readonly journals: JournalsService) {}

  @Get()
  list(@Query() query: ListJournalsDto) {
    return this.journals.listAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.journals.findOne(id);
  }

  @Post()
  create(@Body() body: CreateJournalDto) {
    return this.journals.createJournal(body);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() body: UpdateJournalDto) {
    return this.journals.updateJournal(id, body);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.journals.removeJournal(id);
    return { ok: true };
  }

  @Post(':id/pages')
  createPage(@Param('id') id: string, @Body() body: CreatePageDto) {
    return this.journals.createPage(id, body);
  }

  @Patch('pages/:pageId')
  updatePage(@Param('pageId') pageId: string, @Body() body: UpdatePageDto) {
    return this.journals.updatePage(pageId, body);
  }

  @Delete('pages/:pageId')
  async removePage(@Param('pageId') pageId: string) {
    await this.journals.removePage(pageId);
    return { ok: true };
  }

  @Post('pages/:pageId/assets')
  createAsset(
    @Param('pageId') pageId: string,
    @Body() body: CreateArAssetDto,
  ) {
    return this.journals.createAsset(pageId, body);
  }

  @Patch('assets/:assetId')
  updateAsset(
    @Param('assetId') assetId: string,
    @Body() body: UpdateArAssetDto,
  ) {
    return this.journals.updateAsset(assetId, body);
  }

  @Delete('assets/:assetId')
  async removeAsset(@Param('assetId') assetId: string) {
    await this.journals.removeAsset(assetId);
    return { ok: true };
  }
}

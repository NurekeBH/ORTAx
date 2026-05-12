import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UpsertOnboardingSlideDto } from '../onboarding/dto/onboarding.dto';
import { OnboardingService } from '../onboarding/onboarding.service';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/onboarding')
export class OnboardingAdminController {
  constructor(private readonly onboarding: OnboardingService) {}

  @Get()
  list() {
    return this.onboarding.listAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.onboarding.findOne(id);
  }

  @Post()
  create(@Body() dto: UpsertOnboardingSlideDto) {
    return this.onboarding.create(dto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpsertOnboardingSlideDto) {
    return this.onboarding.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.onboarding.remove(id);
    return { ok: true };
  }
}

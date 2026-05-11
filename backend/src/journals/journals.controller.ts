import { Controller, Get, Param, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { JournalsService } from './journals.service';

@UseGuards(JwtAuthGuard)
@Controller('journals')
export class JournalsController {
  constructor(private readonly journals: JournalsService) {}

  @Get()
  list() {
    return this.journals.list();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.journals.findOne(id);
  }
}

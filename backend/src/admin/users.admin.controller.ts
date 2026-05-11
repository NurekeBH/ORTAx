import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import {
  ListUsersDto,
  UpdateUserBanDto,
  UpdateUserRoleDto,
} from './dto/admin.dto';

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/users')
export class UsersAdminController {
  constructor(private readonly users: UsersService) {}

  @Get()
  async list(@Query() query: ListUsersDto) {
    return this.users.list(query);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.users.findById(id);
  }

  @Patch(':id/role')
  async setRole(@Param('id') id: string, @Body() body: UpdateUserRoleDto) {
    return this.users.setRole(id, body.role);
  }

  @Patch(':id/ban')
  async setBanned(@Param('id') id: string, @Body() body: UpdateUserBanDto) {
    return this.users.setBanned(id, body.banned);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.users.remove(id);
    return { ok: true };
  }
}

import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';

import { AuthService } from './auth.service';
import {
  AdminLoginDto,
  LoginDto,
  RegisterRequestDto,
  RequestResetDto,
  ResetPasswordDto,
  VerifyOtpDto,
} from './dto/auth.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { AuthenticatedUser } from './jwt.strategy';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @Post('admin/login')
  adminLogin(@Body() dto: AdminLoginDto) {
    return this.auth.adminLogin(dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Req() req: Request & { user: AuthenticatedUser }) {
    return req.user;
  }

  @Post('register/request')
  registerRequest(@Body() dto: RegisterRequestDto) {
    return this.auth.requestRegister(dto);
  }

  @Post('register/verify')
  registerVerify(@Body() dto: VerifyOtpDto) {
    return this.auth.verifyRegister(dto);
  }

  @Post('reset/request')
  resetRequest(@Body() dto: RequestResetDto) {
    return this.auth.requestReset(dto.phone);
  }

  @Post('reset/confirm')
  resetConfirm(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto);
  }
}

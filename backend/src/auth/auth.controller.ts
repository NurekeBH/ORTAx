import { Body, Controller, Post } from '@nestjs/common';

import { AuthService } from './auth.service';
import {
  LoginDto,
  RegisterRequestDto,
  RequestResetDto,
  ResetPasswordDto,
  VerifyOtpDto,
} from './dto/auth.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
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

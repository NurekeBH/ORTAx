import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

import { UserRole } from '../users/user.entity';
import { UsersService } from '../users/users.service';
import {
  AdminLoginDto,
  LoginDto,
  RegisterRequestDto,
  ResetPasswordDto,
  VerifyOtpDto,
} from './dto/auth.dto';
import { OtpService } from './otp.service';

interface PendingRegistration {
  phone: string;
  password: string;
  expiresAt: number;
}

@Injectable()
export class AuthService {
  private readonly pendingRegistrations = new Map<string, PendingRegistration>();
  private readonly pendingTtlMs = 10 * 60 * 1000;

  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly otp: OtpService,
  ) {}

  async login(dto: LoginDto) {
    const user = await this.users.findByPhone(dto.phone);
    if (!user) throw new UnauthorizedException('Invalid credentials');
    if (user.banned) throw new UnauthorizedException('User is banned');
    const ok = await this.users.verifyPassword(user, dto.password);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    return this.signToken(user.id, user.phone, user.role);
  }

  async adminLogin(dto: AdminLoginDto) {
    const user = await this.users.findByPhone(dto.phone);
    if (!user) throw new UnauthorizedException('Invalid credentials');
    if (user.banned) throw new UnauthorizedException('User is banned');
    const ok = await this.users.verifyPassword(user, dto.password);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    if (user.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Admin role required');
    }
    return {
      ...this.signToken(user.id, user.phone, user.role),
      user: {
        id: user.id,
        phone: user.phone,
        role: user.role,
        displayName: user.displayName,
      },
    };
  }

  async requestRegister(dto: RegisterRequestDto) {
    const existing = await this.users.findByPhone(dto.phone);
    if (existing) throw new ConflictException('Phone already registered');
    this.pendingRegistrations.set(dto.phone, {
      phone: dto.phone,
      password: dto.password,
      expiresAt: Date.now() + this.pendingTtlMs,
    });
    const otp = this.otp.generate(dto.phone);
    return { sent: true, otpDevHint: process.env.NODE_ENV === 'development' ? otp : undefined };
  }

  async verifyRegister(dto: VerifyOtpDto) {
    const pending = this.pendingRegistrations.get(dto.phone);
    if (!pending || Date.now() > pending.expiresAt) {
      throw new BadRequestException('Registration not initiated or expired');
    }
    if (!this.otp.verify(dto.phone, dto.otp)) {
      throw new UnauthorizedException('Invalid OTP');
    }
    this.pendingRegistrations.delete(dto.phone);
    const user = await this.users.create(pending.phone, pending.password);
    return this.signToken(user.id, user.phone, user.role);
  }

  async requestReset(phone: string) {
    const user = await this.users.findByPhone(phone);
    if (!user) {
      return { sent: true };
    }
    const otp = this.otp.generate(phone);
    return { sent: true, otpDevHint: process.env.NODE_ENV === 'development' ? otp : undefined };
  }

  async resetPassword(dto: ResetPasswordDto) {
    if (!this.otp.verify(dto.phone, dto.otp)) {
      throw new UnauthorizedException('Invalid OTP');
    }
    const user = await this.users.findByPhone(dto.phone);
    if (!user) throw new BadRequestException('User not found');
    await this.users.updatePassword(user.id, dto.newPassword);
    return { ok: true };
  }

  private signToken(userId: string, phone: string, role: UserRole) {
    const accessToken = this.jwt.sign({ sub: userId, phone, role });
    return { accessToken };
  }
}

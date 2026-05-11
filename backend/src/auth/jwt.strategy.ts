import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { UserRole } from '../users/user.entity';
import { UsersService } from '../users/users.service';

export interface JwtPayload {
  sub: string;
  phone: string;
  role: UserRole;
}

export interface AuthenticatedUser {
  userId: string;
  phone: string;
  role: UserRole;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly users: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('JWT_SECRET') ?? 'change-me-in-production',
    });
  }

  async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
    const user = await this.users.findById(payload.sub);
    if (!user) throw new UnauthorizedException('User not found');
    if (user.banned) throw new UnauthorizedException('User is banned');
    return { userId: user.id, phone: user.phone, role: user.role };
  }
}

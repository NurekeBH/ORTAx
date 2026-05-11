import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

import { UserRole } from '../users/user.entity';
import { AuthenticatedUser } from './jwt.strategy';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<{ user?: AuthenticatedUser }>();
    if (!req.user) throw new ForbiddenException('Not authenticated');
    if (req.user.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Admin role required');
    }
    return true;
  }
}

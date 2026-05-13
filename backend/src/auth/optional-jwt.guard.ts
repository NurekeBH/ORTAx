import { ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { AuthenticatedUser } from './jwt.strategy';

/// JWT bar bolsa req.user-ge set qoyıp, joq bolsa silently pasyňydy.
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    try {
      await super.canActivate(context);
    } catch (_) {
      // Token jok nemese in invalid bolsa, anonymous ari qaray ote berediñ
    }
    return true;
  }

  handleRequest<TUser = AuthenticatedUser>(
    _err: unknown,
    user: TUser | false,
  ): TUser | undefined {
    return user || undefined;
  }
}

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { User, UserRole } from './user.entity';

export interface ListUsersOptions {
  search?: string;
  role?: UserRole;
  banned?: boolean;
  page?: number;
  pageSize?: number;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly users: Repository<User>,
  ) {}

  findByPhone(phone: string): Promise<User | null> {
    return this.users.findOne({ where: { phone } });
  }

  findById(id: string): Promise<User | null> {
    return this.users.findOne({ where: { id } });
  }

  async create(phone: string, password: string, role: UserRole = UserRole.STUDENT): Promise<User> {
    const passwordHash = await bcrypt.hash(password, 10);
    const user = this.users.create({ phone, passwordHash, role });
    return this.users.save(user);
  }

  async updatePassword(id: string, newPassword: string): Promise<void> {
    const passwordHash = await bcrypt.hash(newPassword, 10);
    await this.users.update({ id }, { passwordHash });
  }

  async verifyPassword(user: User, password: string): Promise<boolean> {
    return bcrypt.compare(password, user.passwordHash);
  }

  async list(opts: ListUsersOptions = {}): Promise<{ items: User[]; total: number }> {
    const page = Math.max(opts.page ?? 1, 1);
    const pageSize = Math.min(Math.max(opts.pageSize ?? 20, 1), 200);
    const where: Record<string, unknown> = {};
    if (opts.role) where.role = opts.role;
    if (typeof opts.banned === 'boolean') where.banned = opts.banned;
    if (opts.search) where.phone = ILike(`%${opts.search}%`);
    const [items, total] = await this.users.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total };
  }

  async setRole(id: string, role: UserRole): Promise<User> {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');
    user.role = role;
    return this.users.save(user);
  }

  async setBanned(id: string, banned: boolean): Promise<User> {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');
    user.banned = banned;
    return this.users.save(user);
  }

  async setDisplayName(id: string, displayName: string): Promise<void> {
    await this.users.update({ id }, { displayName });
  }

  async remove(id: string): Promise<void> {
    const res = await this.users.delete({ id });
    if (!res.affected) throw new NotFoundException('User not found');
  }

  async touchLastSeen(id: string): Promise<void> {
    await this.users.update({ id }, { lastSeenAt: new Date() });
  }

  countAll(): Promise<number> {
    return this.users.count();
  }

  countActiveSince(since: Date): Promise<number> {
    return this.users
      .createQueryBuilder('u')
      .where('u.last_seen_at >= :since', { since })
      .getCount();
  }
}

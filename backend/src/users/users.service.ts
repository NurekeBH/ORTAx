import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { User, UserRole } from './user.entity';

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
}

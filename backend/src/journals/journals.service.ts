import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Journal } from './journal.entity';

@Injectable()
export class JournalsService {
  constructor(
    @InjectRepository(Journal)
    private readonly journals: Repository<Journal>,
  ) {}

  list(): Promise<Journal[]> {
    return this.journals.find({
      where: { published: true },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Journal> {
    const journal = await this.journals.findOne({
      where: { id },
      relations: { pages: { arAssets: true } },
    });
    if (!journal) throw new NotFoundException('Journal not found');
    return journal;
  }
}

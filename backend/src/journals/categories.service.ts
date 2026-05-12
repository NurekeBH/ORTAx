import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Category } from './category.entity';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private readonly categories: Repository<Category>,
  ) {}

  list(): Promise<Category[]> {
    return this.categories.find({
      order: { sortOrder: 'ASC', name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Category> {
    const cat = await this.categories.findOne({ where: { id } });
    if (!cat) throw new NotFoundException('Category not found');
    return cat;
  }

  async findBySlug(slug: string): Promise<Category | null> {
    return this.categories.findOne({ where: { slug } });
  }

  async create(data: Partial<Category>): Promise<Category> {
    if (data.slug) {
      const existing = await this.categories.findOne({
        where: { slug: data.slug },
      });
      if (existing) throw new ConflictException('Slug already exists');
    }
    const cat = this.categories.create(data);
    return this.categories.save(cat);
  }

  async update(id: string, data: Partial<Category>): Promise<Category> {
    const cat = await this.findOne(id);
    if (data.slug && data.slug !== cat.slug) {
      const dup = await this.categories.findOne({
        where: { slug: data.slug },
      });
      if (dup && dup.id !== id) {
        throw new ConflictException('Slug already exists');
      }
    }
    Object.assign(cat, data);
    return this.categories.save(cat);
  }

  async remove(id: string): Promise<void> {
    const res = await this.categories.delete({ id });
    if (!res.affected) throw new NotFoundException('Category not found');
  }

  count(): Promise<number> {
    return this.categories.count();
  }
}

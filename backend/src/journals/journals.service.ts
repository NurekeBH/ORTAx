import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindOptionsWhere, ILike, Repository } from 'typeorm';

import { ArAsset } from './ar-asset.entity';
import { Journal } from './journal.entity';
import { Page } from './page.entity';

export interface ListJournalsOptions {
  category?: string;
  gradeLevel?: string;
  language?: string;
  featured?: boolean;
  published?: boolean;
  search?: string;
  page?: number;
  pageSize?: number;
}

@Injectable()
export class JournalsService {
  constructor(
    @InjectRepository(Journal)
    private readonly journals: Repository<Journal>,
    @InjectRepository(Page)
    private readonly pages: Repository<Page>,
    @InjectRepository(ArAsset)
    private readonly assets: Repository<ArAsset>,
  ) {}

  async list(opts: ListJournalsOptions = {}): Promise<Journal[]> {
    const where: FindOptionsWhere<Journal> = {};
    if (opts.published !== undefined) {
      where.published = opts.published;
    } else {
      where.published = true;
    }
    if (opts.gradeLevel) where.gradeLevel = opts.gradeLevel;
    if (opts.language) where.language = opts.language;
    if (opts.featured !== undefined) where.featured = opts.featured;
    if (opts.search) where.title = ILike(`%${opts.search}%`);
    if (opts.category) {
      where.category = { slug: opts.category };
    }
    return this.journals.find({
      where,
      relations: { category: true },
      order: { featured: 'DESC', createdAt: 'DESC' },
    });
  }

  async listAll(
    opts: ListJournalsOptions = {},
  ): Promise<{ items: Array<Journal & { pagesCount: number }>; total: number }> {
    const page = Math.max(opts.page ?? 1, 1);
    const pageSize = Math.min(Math.max(opts.pageSize ?? 50, 1), 200);

    const qb = this.journals
      .createQueryBuilder('journal')
      .leftJoinAndSelect('journal.category', 'category')
      .loadRelationCountAndMap('journal.pagesCount', 'journal.pages')
      .orderBy('journal.createdAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize);

    if (opts.published !== undefined) {
      qb.andWhere('journal.published = :published', {
        published: opts.published,
      });
    }
    if (opts.gradeLevel) {
      qb.andWhere('journal.gradeLevel = :grade', { grade: opts.gradeLevel });
    }
    if (opts.language) {
      qb.andWhere('journal.language = :lang', { lang: opts.language });
    }
    if (opts.featured !== undefined) {
      qb.andWhere('journal.featured = :featured', {
        featured: opts.featured,
      });
    }
    if (opts.search) {
      qb.andWhere('journal.title ILIKE :search', {
        search: `%${opts.search}%`,
      });
    }
    if (opts.category) {
      qb.andWhere('category.slug = :catSlug', { catSlug: opts.category });
    }

    const [items, total] = await qb.getManyAndCount();
    return {
      items: items as Array<Journal & { pagesCount: number }>,
      total,
    };
  }

  async findOne(id: string): Promise<Journal> {
    const journal = await this.journals.findOne({
      where: { id },
      relations: { pages: { arAssets: true }, category: true },
      order: { pages: { pageNumber: 'ASC' } },
    });
    if (!journal) throw new NotFoundException('Journal not found');
    return journal;
  }

  async findBySlug(slug: string): Promise<Journal> {
    const journal = await this.journals.findOne({
      where: { slug },
      relations: { pages: { arAssets: true }, category: true },
      order: { pages: { pageNumber: 'ASC' } },
    });
    if (!journal) throw new NotFoundException('Journal not found');
    return journal;
  }

  async createJournal(data: Partial<Journal>): Promise<Journal> {
    if (data.slug) {
      const dup = await this.journals.findOne({ where: { slug: data.slug } });
      if (dup) throw new ConflictException('Slug already exists');
    }
    if (data.published && !data.publishedAt) {
      data.publishedAt = new Date();
    }
    const journal = this.journals.create(data);
    return this.journals.save(journal);
  }

  async updateJournal(id: string, data: Partial<Journal>): Promise<Journal> {
    const journal = await this.journals.findOne({ where: { id } });
    if (!journal) throw new NotFoundException('Journal not found');
    if (data.slug && data.slug !== journal.slug) {
      const dup = await this.journals.findOne({ where: { slug: data.slug } });
      if (dup && dup.id !== id) {
        throw new ConflictException('Slug already exists');
      }
    }
    if (data.published === true && !journal.publishedAt && !data.publishedAt) {
      data.publishedAt = new Date();
    }
    Object.assign(journal, data);
    return this.journals.save(journal);
  }

  async incrementViews(id: string): Promise<void> {
    await this.journals.increment({ id }, 'viewsCount', 1);
  }

  async removeJournal(id: string): Promise<void> {
    const res = await this.journals.delete({ id });
    if (!res.affected) throw new NotFoundException('Journal not found');
  }

  async createPage(journalId: string, data: Partial<Page>): Promise<Page> {
    const journal = await this.journals.findOne({ where: { id: journalId } });
    if (!journal) throw new NotFoundException('Journal not found');
    const page = this.pages.create({ ...data, journal });
    return this.pages.save(page);
  }

  async updatePage(id: string, data: Partial<Page>): Promise<Page> {
    const page = await this.pages.findOne({ where: { id } });
    if (!page) throw new NotFoundException('Page not found');
    Object.assign(page, data);
    return this.pages.save(page);
  }

  async removePage(id: string): Promise<void> {
    const res = await this.pages.delete({ id });
    if (!res.affected) throw new NotFoundException('Page not found');
  }

  async createAsset(pageId: string, data: Partial<ArAsset>): Promise<ArAsset> {
    const page = await this.pages.findOne({ where: { id: pageId } });
    if (!page) throw new NotFoundException('Page not found');
    const asset = this.assets.create({ ...data, page });
    return this.assets.save(asset);
  }

  async updateAsset(id: string, data: Partial<ArAsset>): Promise<ArAsset> {
    const asset = await this.assets.findOne({ where: { id } });
    if (!asset) throw new NotFoundException('Asset not found');
    Object.assign(asset, data);
    return this.assets.save(asset);
  }

  async removeAsset(id: string): Promise<void> {
    const res = await this.assets.delete({ id });
    if (!res.affected) throw new NotFoundException('Asset not found');
  }

  countJournals(): Promise<number> {
    return this.journals.count();
  }

  countPages(): Promise<number> {
    return this.pages.count();
  }

  countAssets(): Promise<number> {
    return this.assets.count();
  }
}

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { ArAsset } from './ar-asset.entity';
import { Journal } from './journal.entity';
import { Page } from './page.entity';

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

  list(): Promise<Journal[]> {
    return this.journals.find({
      where: { published: true },
      order: { createdAt: 'DESC' },
    });
  }

  listAll(): Promise<Journal[]> {
    return this.journals.find({ order: { createdAt: 'DESC' } });
  }

  async findOne(id: string): Promise<Journal> {
    const journal = await this.journals.findOne({
      where: { id },
      relations: { pages: { arAssets: true } },
      order: { pages: { pageNumber: 'ASC' } },
    });
    if (!journal) throw new NotFoundException('Journal not found');
    return journal;
  }

  async createJournal(data: Partial<Journal>): Promise<Journal> {
    const journal = this.journals.create(data);
    return this.journals.save(journal);
  }

  async updateJournal(id: string, data: Partial<Journal>): Promise<Journal> {
    const journal = await this.journals.findOne({ where: { id } });
    if (!journal) throw new NotFoundException('Journal not found');
    Object.assign(journal, data);
    return this.journals.save(journal);
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

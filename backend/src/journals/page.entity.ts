import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { ArAsset } from './ar-asset.entity';
import { Journal } from './journal.entity';

@Entity('pages')
export class Page {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => Journal, (journal) => journal.pages, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'journal_id' })
  journal!: Journal;

  @Column({ name: 'page_number' })
  pageNumber!: number;

  @Column({ name: 'image_url', nullable: true })
  imageUrl?: string;

  @Column({ type: 'text', nullable: true })
  text?: string;

  @Column({ type: 'jsonb', nullable: true })
  contentBlocks?: unknown;

  @OneToMany(() => ArAsset, (asset) => asset.page, { cascade: true })
  arAssets!: ArAsset[];
}

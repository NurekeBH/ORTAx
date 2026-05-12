import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { Category } from './category.entity';
import { Page } from './page.entity';

@Entity('journals')
export class Journal {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  title!: string;

  @Column({ type: 'text' })
  description!: string;

  @Column({ name: 'cover_image', nullable: true })
  coverImage?: string;

  @Column({ name: 'pdf_url', nullable: true })
  pdfUrl?: string;

  @Column({ name: 'trailer_video_url', nullable: true })
  trailerVideoUrl?: string;

  @Column({ nullable: true })
  subject?: string;

  @Column({ name: 'grade_level', nullable: true })
  gradeLevel?: string;

  @Index({ unique: true, where: '"slug" IS NOT NULL' })
  @Column({ nullable: true })
  slug?: string;

  @Column({ nullable: true })
  author?: string;

  @Column({ default: 'kk' })
  language!: string;

  @Column({ type: 'jsonb', nullable: true })
  tags?: string[];

  @Column({ default: false })
  featured!: boolean;

  @Column({ default: true })
  published!: boolean;

  @Column({ name: 'published_at', type: 'timestamptz', nullable: true })
  publishedAt?: Date;

  @Column({ name: 'views_count', default: 0 })
  viewsCount!: number;

  @ManyToOne(() => Category, (cat) => cat.journals, {
    nullable: true,
    onDelete: 'SET NULL',
    eager: false,
  })
  @JoinColumn({ name: 'category_id' })
  category?: Category;

  @Column({ name: 'category_id', nullable: true })
  categoryId?: string;

  @OneToMany(() => Page, (page) => page.journal, { cascade: true })
  pages!: Page[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';

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

  @Column({ nullable: true })
  subject?: string;

  @Column({ name: 'grade_level', nullable: true })
  gradeLevel?: string;

  @Column({ default: true })
  published!: boolean;

  @OneToMany(() => Page, (page) => page.journal, { cascade: true })
  pages!: Page[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}

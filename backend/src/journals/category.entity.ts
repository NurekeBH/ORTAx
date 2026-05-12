import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { Journal } from './journal.entity';

@Entity('journal_categories')
export class Category {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index({ unique: true })
  @Column()
  slug!: string;

  @Column()
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ nullable: true })
  icon?: string;

  @Column({ nullable: true })
  color?: string;

  @Column({ name: 'cover_image', nullable: true })
  coverImage?: string;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder!: number;

  @OneToMany(() => Journal, (journal) => journal.category)
  journals!: Journal[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

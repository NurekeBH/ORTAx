import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { Page } from './page.entity';

@Entity('ar_assets')
export class ArAsset {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => Page, (page) => page.arAssets, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'page_id' })
  page!: Page;

  @Column({ name: 'trigger_marker' })
  triggerMarker!: string;

  @Column({ name: 'model_url' })
  modelUrl!: string;

  @Column({ name: 'audio_url', nullable: true })
  audioUrl?: string;

  @Column({ name: 'animation_set', nullable: true })
  animationSet?: string;
}

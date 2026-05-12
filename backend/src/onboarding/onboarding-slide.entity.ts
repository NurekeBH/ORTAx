import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('onboarding_slides')
export class OnboardingSlide {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ default: 0 })
  position!: number;

  @Column({ name: 'icon_svg', type: 'text', nullable: true })
  iconSvg?: string;

  @Column({ name: 'title_kk' })
  titleKk!: string;

  @Column({ name: 'title_ru', nullable: true })
  titleRu?: string;

  @Column({ name: 'title_en', nullable: true })
  titleEn?: string;

  @Column({ name: 'description_kk', type: 'text' })
  descriptionKk!: string;

  @Column({ name: 'description_ru', type: 'text', nullable: true })
  descriptionRu?: string;

  @Column({ name: 'description_en', type: 'text', nullable: true })
  descriptionEn?: string;

  @Column({ default: true })
  published!: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

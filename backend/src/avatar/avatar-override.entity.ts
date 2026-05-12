import {
  Column,
  Entity,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('avatar_overrides')
export class AvatarOverride {
  @PrimaryColumn()
  character!: string;

  @Column({ name: 'image_url', nullable: true })
  imageUrl?: string;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

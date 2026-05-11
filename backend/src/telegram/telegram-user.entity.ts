import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('telegram_users')
export class TelegramUser {
  @PrimaryColumn({ type: 'bigint', name: 'telegram_id' })
  telegramId!: string;

  @Column({ nullable: true })
  username?: string;

  @Column({ name: 'first_name', nullable: true })
  firstName?: string;

  @Column({ name: 'last_name', nullable: true })
  lastName?: string;

  @Column({ name: 'language_code', nullable: true })
  languageCode?: string;

  @Column({ name: 'last_character', nullable: true })
  lastCharacter?: string;

  @Column({ name: 'message_count', default: 0 })
  messageCount!: number;

  @Column({ default: false })
  banned!: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';

export type ChatLogSource = 'mobile' | 'telegram' | 'web';
export type ChatLogRole = 'user' | 'assistant';

@Entity('avatar_chat_logs')
@Index(['character', 'createdAt'])
@Index(['conversationId', 'createdAt'])
export class ChatLog {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  character!: string;

  @Column({ name: 'conversation_id' })
  conversationId!: string;

  @Column()
  role!: ChatLogRole;

  @Column({ type: 'text' })
  content!: string;

  @Column({ default: 'mobile' })
  source!: ChatLogSource;

  @Column({ name: 'user_id', nullable: true })
  userId?: string;

  @Column({ name: 'telegram_user_id', type: 'bigint', nullable: true })
  telegramUserId?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}

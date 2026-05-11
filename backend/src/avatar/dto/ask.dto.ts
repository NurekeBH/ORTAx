import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class AskDto {
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  question!: string;

  @IsOptional()
  @IsString()
  conversationId?: string;
}

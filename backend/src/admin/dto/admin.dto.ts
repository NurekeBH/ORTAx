import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

import { UserRole } from '../../users/user.entity';

export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200)
  pageSize?: number;
}

export class ListUsersDto extends PaginationDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  banned?: boolean;
}

export class UpdateUserRoleDto {
  @IsEnum(UserRole)
  role!: UserRole;
}

export class UpdateUserBanDto {
  @IsBoolean()
  banned!: boolean;
}

export class CreateJournalDto {
  @IsString()
  title!: string;

  @IsString()
  description!: string;

  @IsOptional()
  @IsString()
  coverImage?: string;

  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  gradeLevel?: string;

  @IsOptional()
  @IsBoolean()
  published?: boolean;
}

export class UpdateJournalDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  coverImage?: string;

  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  gradeLevel?: string;

  @IsOptional()
  @IsBoolean()
  published?: boolean;
}

export class CreatePageDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageNumber!: number;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsString()
  text?: string;
}

export class UpdatePageDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageNumber?: number;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsString()
  text?: string;
}

export class CreateArAssetDto {
  @IsString()
  triggerMarker!: string;

  @IsString()
  modelUrl!: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsString()
  animationSet?: string;
}

export class UpdateArAssetDto {
  @IsOptional()
  @IsString()
  triggerMarker?: string;

  @IsOptional()
  @IsString()
  modelUrl?: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsString()
  animationSet?: string;
}

export class ChatLogQueryDto extends PaginationDto {
  @IsOptional()
  @IsString()
  character?: string;

  @IsOptional()
  @IsString()
  conversationId?: string;

  @IsOptional()
  @IsString()
  source?: string;
}

export class BroadcastDto {
  @IsString()
  character!: string;

  @IsString()
  message!: string;
}

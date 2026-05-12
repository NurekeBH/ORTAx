import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class UpsertOnboardingSlideDto {
  @IsInt()
  @Min(0)
  position!: number;

  @IsOptional()
  @IsString()
  @MaxLength(50000)
  iconSvg?: string;

  @IsString()
  @MaxLength(200)
  titleKk!: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  titleRu?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  titleEn?: string;

  @IsString()
  @MaxLength(2000)
  descriptionKk!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  descriptionRu?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  descriptionEn?: string;

  @IsOptional()
  @IsBoolean()
  published?: boolean;
}

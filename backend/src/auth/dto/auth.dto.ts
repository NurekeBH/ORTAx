import { IsString, MinLength, Matches, Length } from 'class-validator';

export class LoginDto {
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/, { message: 'phone must be a valid number' })
  phone!: string;

  @IsString()
  @MinLength(6)
  password!: string;
}

export class AdminLoginDto {
  @IsString()
  @MinLength(3)
  phone!: string;

  @IsString()
  @MinLength(6)
  password!: string;
}

export class RegisterRequestDto {
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/, { message: 'phone must be a valid number' })
  phone!: string;

  @IsString()
  @MinLength(6)
  password!: string;
}

export class VerifyOtpDto {
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/)
  phone!: string;

  @IsString()
  @Length(4, 6)
  otp!: string;
}

export class RequestResetDto {
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/)
  phone!: string;
}

export class ResetPasswordDto {
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/)
  phone!: string;

  @IsString()
  @Length(4, 6)
  otp!: string;

  @IsString()
  @MinLength(6)
  newPassword!: string;
}

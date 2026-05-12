import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface OtpEntry {
  otp: string;
  expiresAt: number;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly store = new Map<string, OtpEntry>();
  private readonly ttlMs = 5 * 60 * 1000;

  constructor(private readonly config: ConfigService) {}

  private isMock(): boolean {
    return (this.config.get<string>('SMS_PROVIDER') ?? 'mock') === 'mock';
  }

  generate(phone: string): string {
    const otp = this.isMock()
      ? '0000'
      : String(Math.floor(1000 + Math.random() * 9000));
    this.store.set(phone, { otp, expiresAt: Date.now() + this.ttlMs });
    this.logger.log(`OTP for ${phone}: ${otp} (mock=${this.isMock()})`);
    return otp;
  }

  verify(phone: string, otp: string): boolean {
    if (this.isMock() && otp === '0000') {
      this.store.delete(phone);
      return true;
    }
    const entry = this.store.get(phone);
    if (!entry) return false;
    if (Date.now() > entry.expiresAt) {
      this.store.delete(phone);
      return false;
    }
    if (entry.otp !== otp) return false;
    this.store.delete(phone);
    return true;
  }
}

import { Injectable, Logger } from '@nestjs/common';

interface OtpEntry {
  otp: string;
  expiresAt: number;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly store = new Map<string, OtpEntry>();
  private readonly ttlMs = 5 * 60 * 1000;

  generate(phone: string): string {
    const otp = String(Math.floor(1000 + Math.random() * 9000));
    this.store.set(phone, { otp, expiresAt: Date.now() + this.ttlMs });
    this.logger.log(`OTP for ${phone}: ${otp} (dev only)`);
    return otp;
  }

  verify(phone: string, otp: string): boolean {
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

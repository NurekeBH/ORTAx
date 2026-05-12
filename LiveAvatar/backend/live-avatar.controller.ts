import {
  Body,
  Controller,
  HttpException,
  HttpStatus,
  Logger,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtAuthGuard } from '../../backend/src/auth/jwt-auth.guard';

type CreateTokenResponse = {
  data: { token: string };
};

type NewSessionBody = {
  quality?: 'low' | 'medium' | 'high';
  avatar_id?: string;
  voice_id?: string;
  language?: string;
};

type NewSessionResponse = {
  data: {
    session_id: string;
    sdp: RTCSessionDescriptionInit;
    ice_servers2: RTCIceServer[];
    access_token: string;
    url: string;
  };
};

@Controller('live-avatar')
@UseGuards(JwtAuthGuard)
export class LiveAvatarController {
  private readonly logger = new Logger(LiveAvatarController.name);

  constructor(private readonly config: ConfigService) {}

  private get apiBase(): string {
    return this.config.get<string>('LIVEAVATAR_API_BASE') ?? 'https://api.heygen.com';
  }

  private get apiKey(): string {
    const key = this.config.get<string>('LIVEAVATAR_API_KEY');
    if (!key) {
      throw new HttpException(
        'LIVEAVATAR_API_KEY is not configured on the server',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
    return key;
  }

  @Post('token')
  async createToken(): Promise<{ token: string; expiresIn: number }> {
    const res = await fetch(`${this.apiBase}/v1/streaming.create_token`, {
      method: 'POST',
      headers: {
        'x-api-key': this.apiKey,
        'Content-Type': 'application/json',
      },
    });

    if (!res.ok) {
      const text = await res.text();
      this.logger.error(`create_token failed: ${res.status} ${text}`);
      throw new HttpException(
        'Failed to mint LiveAvatar token',
        HttpStatus.BAD_GATEWAY,
      );
    }

    const json = (await res.json()) as CreateTokenResponse;
    return { token: json.data.token, expiresIn: 60 * 15 };
  }

  @Post('session/new')
  async newSession(@Body() body: NewSessionBody): Promise<NewSessionResponse['data']> {
    const tokenRes = await this.createToken();

    const payload = {
      quality: body.quality ?? 'medium',
      avatar_name:
        body.avatar_id ??
        this.config.get<string>('LIVEAVATAR_AVATAR_ID') ??
        'Anna_public_3_20240108',
      voice: {
        voice_id:
          body.voice_id ?? this.config.get<string>('LIVEAVATAR_VOICE_ID'),
      },
      language: body.language ?? 'en',
    };

    const res = await fetch(`${this.apiBase}/v1/streaming.new`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${tokenRes.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      const text = await res.text();
      this.logger.error(`streaming.new failed: ${res.status} ${text}`);
      throw new HttpException('Failed to open LiveAvatar session', HttpStatus.BAD_GATEWAY);
    }

    const json = (await res.json()) as NewSessionResponse;
    return json.data;
  }

  @Post('session/task')
  async task(
    @Body() body: { session_id: string; text: string; task_type?: 'talk' | 'repeat' },
  ): Promise<{ ok: true }> {
    const tokenRes = await this.createToken();

    const res = await fetch(`${this.apiBase}/v1/streaming.task`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${tokenRes.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        session_id: body.session_id,
        text: body.text,
        task_type: body.task_type ?? 'repeat',
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      this.logger.error(`streaming.task failed: ${res.status} ${text}`);
      throw new HttpException('Failed to send task', HttpStatus.BAD_GATEWAY);
    }
    return { ok: true };
  }

  @Post('session/stop')
  async stop(@Body() body: { session_id: string }): Promise<{ ok: true }> {
    const tokenRes = await this.createToken();

    const res = await fetch(`${this.apiBase}/v1/streaming.stop`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${tokenRes.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ session_id: body.session_id }),
    });

    if (!res.ok) {
      const text = await res.text();
      this.logger.error(`streaming.stop failed: ${res.status} ${text}`);
    }
    return { ok: true };
  }
}

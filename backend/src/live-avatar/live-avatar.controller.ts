import {
  Body,
  Controller,
  HttpException,
  HttpStatus,
  Logger,
  Post,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface TokenRequestBody {
  avatar_id?: string;
  mode?: 'LITE' | 'FULL';
  language?: string;
  voice_id?: string;
  is_sandbox?: boolean;
}

interface TokenResponse {
  session_id: string;
  session_token: string;
}

@Controller('live-avatar')
export class LiveAvatarController {
  private readonly logger = new Logger(LiveAvatarController.name);

  constructor(private readonly config: ConfigService) {}

  private get apiBase(): string {
    return (
      this.config.get<string>('LIVEAVATAR_API_BASE') ??
      'https://api.liveavatar.com'
    );
  }

  private get apiKey(): string {
    const key = this.config.get<string>('LIVEAVATAR_API_KEY');
    if (!key) {
      throw new HttpException(
        'LIVEAVATAR_API_KEY is not configured',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
    return key;
  }

  /**
   * Веб/мобильді клиент үшін қысқа мерзімді LiveAvatar session token шығарады.
   * Клиент бұл token-ды @heygen/liveavatar-web-sdk-ге беріп, өзі бастайды.
   */
  /**
   * Барлық актив сессияларды тоқтатады. Concurrency лимитіне жеткенде пайдалы.
   * GET /v1/sessions?type=active → әрқайсысын /v1/sessions/stop.
   */
  @Post('sessions/stop-all')
  async stopAll(): Promise<{ stopped: string[] }> {
    const listRes = await fetch(
      `${this.apiBase}/v1/sessions?type=active`,
      { headers: { 'X-API-KEY': this.apiKey } },
    );
    if (!listRes.ok) {
      throw new HttpException(
        `Failed to list sessions: ${await listRes.text()}`,
        HttpStatus.BAD_GATEWAY,
      );
    }
    const list = (await listRes.json()) as {
      data: { results: { id: string }[] };
    };
    const stopped: string[] = [];
    for (const s of list.data.results) {
      await fetch(`${this.apiBase}/v1/sessions/stop`, {
        method: 'POST',
        headers: {
          'X-API-KEY': this.apiKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ session_id: s.id, reason: 'USER_CLOSED' }),
      });
      stopped.push(s.id);
    }
    this.logger.log(`Stopped ${stopped.length} active sessions`);
    return { stopped };
  }

  @Post('token')
  async createToken(@Body() body: TokenRequestBody): Promise<TokenResponse> {
    const avatarId =
      body.avatar_id ?? this.config.get<string>('LIVEAVATAR_AVATAR_ID');
    if (!avatarId) {
      throw new HttpException(
        'avatar_id is required (set LIVEAVATAR_AVATAR_ID env)',
        HttpStatus.BAD_REQUEST,
      );
    }

    const sandboxEnv = this.config.get<string>('LIVEAVATAR_SANDBOX') === 'true';
    const isSandbox = body.is_sandbox ?? sandboxEnv;
    // Sandbox-та тек Wayne аватары қолдау табады — оған автоматты ауысамыз.
    const SANDBOX_AVATAR_ID = 'dd73ea75-1218-4ef3-92ce-606d5f7fbc0a';
    const effectiveAvatarId = isSandbox ? SANDBOX_AVATAR_ID : avatarId;

    const payload: Record<string, unknown> = {
      mode: body.mode ?? 'LITE',
      avatar_id: effectiveAvatarId,
      is_sandbox: isSandbox,
    };

    // FULL режим — voice_id, context_id, language тікелей avatar_persona ішінде.
    // Sandbox-та voice_id жоқ болса аватардың default дауысы қолданылады.
    if (payload.mode === 'FULL') {
      const voiceId = isSandbox
        ? body.voice_id
        : body.voice_id ?? this.config.get<string>('LIVEAVATAR_VOICE_ID');
      const contextId = this.config.get<string>('LIVEAVATAR_CONTEXT_ID');
      const persona: Record<string, unknown> = {
        language: body.language ?? 'en',
      };
      if (voiceId) persona.voice_id = voiceId;
      if (contextId && !isSandbox) persona.context_id = contextId;
      payload.avatar_persona = persona;
      payload.interactivity_type = 'CONVERSATIONAL';
    }

    const res = await fetch(`${this.apiBase}/v1/sessions/token`, {
      method: 'POST',
      headers: {
        'X-API-KEY': this.apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const text = await res.text();
    if (!res.ok) {
      this.logger.error(`sessions/token ${res.status}: ${text}`);
      throw new HttpException(
        `LiveAvatar token error: ${text}`,
        HttpStatus.BAD_GATEWAY,
      );
    }

    const json = JSON.parse(text) as { data: TokenResponse };
    return json.data;
  }
}

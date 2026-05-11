import {
  Injectable,
  Logger,
  OnApplicationShutdown,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Input, Telegraf } from 'telegraf';
import { message } from 'telegraf/filters';

import { AvatarService } from '../avatar/avatar.service';
import { CHARACTERS, CharacterId } from '../avatar/prompts/characters';
import { SttService } from '../avatar/voice/stt.service';
import { TtsService } from '../avatar/voice/tts.service';

interface BotConfig {
  character: CharacterId;
  tokenEnv: string;
  voiceFileName: string;
}

const BOT_CONFIGS: BotConfig[] = [
  {
    character: 'yassawi',
    tokenEnv: 'TELEGRAM_BOT_TOKEN',
    voiceFileName: 'yassawi.ogg',
  },
  {
    character: 'khwarizmi',
    tokenEnv: 'TELEGRAM_BOT_TOKEN_KHWARIZMI',
    voiceFileName: 'khwarizmi.ogg',
  },
];

@Injectable()
export class TelegramService implements OnModuleInit, OnApplicationShutdown {
  private readonly logger = new Logger(TelegramService.name);
  private readonly bots: Telegraf[] = [];

  constructor(
    private readonly config: ConfigService,
    private readonly avatar: AvatarService,
    private readonly stt: SttService,
    private readonly tts: TtsService,
  ) {}

  async onModuleInit() {
    if (this.config.get<string>('TELEGRAM_BOT_ENABLED') !== 'true') {
      this.logger.log('Telegram bots disabled (TELEGRAM_BOT_ENABLED != true)');
      return;
    }

    for (const cfg of BOT_CONFIGS) {
      const token = this.config.get<string>(cfg.tokenEnv);
      if (!token) {
        this.logger.warn(
          `${cfg.tokenEnv} not set — ${cfg.character} bot will not start`,
        );
        continue;
      }

      const bot = new Telegraf(token);
      this.registerHandlers(bot, cfg);
      this.bots.push(bot);

      void bot.launch();
      const me = await bot.telegram.getMe();
      this.logger.log(
        `Telegram bot @${me.username} started (${cfg.character})`,
      );
    }
  }

  async onApplicationShutdown() {
    for (const bot of this.bots) {
      bot.stop('SIGTERM');
    }
  }

  private registerHandlers(bot: Telegraf, cfg: BotConfig) {
    const character = cfg.character;
    const def = CHARACTERS[character];

    bot.start(async (ctx) => {
      this.avatar.reset(this.conversationId(ctx.from?.id), character);
      await ctx.reply(this.avatar.greeting(character));
    });

    bot.command('reset', async (ctx) => {
      this.avatar.reset(this.conversationId(ctx.from?.id), character);
      await ctx.reply('Әңгіме басынан басталды. Жаңа сұрақ қойыңыз.');
    });

    bot.command('help', async (ctx) => {
      await ctx.reply(
        [
          def.helpText,
          '',
          'Командалар:',
          '/start — әңгіме бастау',
          '/reset — әңгіме тарихын тазалау',
          '/help — осы көмек',
          '',
          'Сұрағыңызды мәтінмен немесе дауыспен жіберіңіз.',
        ].join('\n'),
      );
    });

    bot.on(message('voice'), async (ctx) => {
      try {
        await ctx.sendChatAction('record_voice');

        const fileId = ctx.message.voice.file_id;
        const audio = await this.downloadFile(bot, fileId);

        const transcript = await this.stt.transcribe(audio, 'voice.oga');
        if (!transcript) {
          await ctx.replyWithVoice(
            Input.fromBuffer(
              await this.tts.synthesize(
                'Кешіріңіз, дауысыңызды түсіне алмадым. Қайта айтып көріңіз.',
              ),
              cfg.voiceFileName,
            ),
          );
          return;
        }
        this.logger.log(
          `STT [${character}] (${ctx.from?.id}): ${transcript}`,
        );

        const reply = await this.avatar.ask(
          this.conversationId(ctx.from?.id),
          character,
          transcript,
        );
        const audioOut = await this.tts.synthesize(reply);
        await ctx.replyWithVoice(Input.fromBuffer(audioOut, cfg.voiceFileName), {
          caption: `📝 Сіз: ${transcript}\n\n🕌 ${def.displayName}: ${reply}`.slice(0, 1024),
        });
      } catch (err) {
        this.logger.error(`Voice flow failed [${character}]`, err as Error);
        await ctx.reply('Кешіріңіз, дауыспен жауап беру кезінде қате орын алды.');
      }
    });

    bot.on(message('text'), async (ctx) => {
      const text = ctx.message.text?.trim();
      if (!text) return;
      if (text.startsWith('/')) return;

      try {
        await ctx.sendChatAction('typing');
        const reply = await this.avatar.ask(
          this.conversationId(ctx.from?.id),
          character,
          text,
        );
        await ctx.reply(reply);
      } catch (err) {
        this.logger.error(`Avatar reply failed [${character}]`, err as Error);
        await ctx.reply('Кешіріңіз, қазір жауап бере алмадым. Қайта көріп көріңіз.');
      }
    });
  }

  private async downloadFile(bot: Telegraf, fileId: string): Promise<Buffer> {
    const link = await bot.telegram.getFileLink(fileId);
    const response = await fetch(link.toString());
    if (!response.ok) {
      throw new Error(`Failed to download file: ${response.status}`);
    }
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }

  private conversationId(userId?: number): string {
    return `tg:${userId ?? 'anon'}`;
  }
}

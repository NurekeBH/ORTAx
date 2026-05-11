import {
  Injectable,
  Logger,
  OnApplicationShutdown,
  OnModuleInit,
  Optional,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Input, Telegraf, Context as TelegrafContext } from 'telegraf';
import { message } from 'telegraf/filters';

import { AvatarService } from '../avatar/avatar.service';
import { CHARACTERS, CharacterId } from '../avatar/prompts/characters';
import { SttService } from '../avatar/voice/stt.service';
import { TtsService } from '../avatar/voice/tts.service';
import { TelegramUser } from './telegram-user.entity';

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
  private readonly botsByCharacter = new Map<CharacterId, Telegraf>();

  constructor(
    private readonly config: ConfigService,
    private readonly avatar: AvatarService,
    private readonly stt: SttService,
    private readonly tts: TtsService,
    @Optional()
    @InjectRepository(TelegramUser)
    private readonly tgUsers?: Repository<TelegramUser>,
  ) {}

  getBotByCharacter(character: CharacterId): Telegraf | undefined {
    return this.botsByCharacter.get(character);
  }

  async broadcast(
    character: CharacterId,
    message: string,
  ): Promise<{ sent: number; failed: number }> {
    if (!this.tgUsers) return { sent: 0, failed: 0 };
    const bot = this.getBotByCharacter(character);
    if (!bot) throw new Error(`Bot for ${character} is not running`);
    const users = await this.tgUsers.find({
      where: { banned: false, lastCharacter: character },
    });
    let sent = 0;
    let failed = 0;
    for (const u of users) {
      try {
        await bot.telegram.sendMessage(u.telegramId, message);
        sent += 1;
      } catch (err) {
        failed += 1;
        this.logger.warn(
          `Broadcast to ${u.telegramId} failed: ${(err as Error).message}`,
        );
      }
    }
    return { sent, failed };
  }

  private async upsertUser(
    ctx: TelegrafContext,
    character: CharacterId,
  ): Promise<void> {
    if (!this.tgUsers || !ctx.from) return;
    try {
      const existing = await this.tgUsers.findOne({
        where: { telegramId: String(ctx.from.id) },
      });
      if (existing) {
        existing.username = ctx.from.username;
        existing.firstName = ctx.from.first_name;
        existing.lastName = ctx.from.last_name;
        existing.languageCode = ctx.from.language_code;
        existing.lastCharacter = character;
        existing.messageCount = (existing.messageCount ?? 0) + 1;
        await this.tgUsers.save(existing);
      } else {
        await this.tgUsers.save(
          this.tgUsers.create({
            telegramId: String(ctx.from.id),
            username: ctx.from.username,
            firstName: ctx.from.first_name,
            lastName: ctx.from.last_name,
            languageCode: ctx.from.language_code,
            lastCharacter: character,
            messageCount: 1,
          }),
        );
      }
    } catch (err) {
      this.logger.warn(
        `Failed to upsert TG user: ${(err as Error).message}`,
      );
    }
  }

  private async isBanned(telegramId?: number): Promise<boolean> {
    if (!this.tgUsers || !telegramId) return false;
    const u = await this.tgUsers.findOne({
      where: { telegramId: String(telegramId) },
    });
    return !!u?.banned;
  }

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
      bot.catch((err) => {
        this.logger.error(`Bot ${cfg.character} handler error`, err as Error);
      });
      this.bots.push(bot);
      this.botsByCharacter.set(cfg.character, bot);

      bot
        .launch({ dropPendingUpdates: true })
        .catch((err) =>
          this.logger.error(`Bot ${cfg.character} polling stopped`, err as Error),
        );
      try {
        const me = await bot.telegram.getMe();
        this.logger.log(
          `Telegram bot @${me.username} started (${cfg.character})`,
        );
      } catch (err) {
        this.logger.error(
          `Bot ${cfg.character} getMe failed`,
          err as Error,
        );
      }
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
      await this.upsertUser(ctx, character);
      if (await this.isBanned(ctx.from?.id)) return;
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
        await this.upsertUser(ctx, character);
        if (await this.isBanned(ctx.from?.id)) return;
        await ctx.sendChatAction('record_voice');

        const fileId = ctx.message.voice.file_id;
        const audio = await this.downloadFile(bot, fileId);

        const transcript = await this.stt.transcribe(
          audio,
          'voice.oga',
          def.language,
        );
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
          {
            source: 'telegram',
            telegramUserId: ctx.from ? String(ctx.from.id) : undefined,
          },
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
        await this.upsertUser(ctx, character);
        if (await this.isBanned(ctx.from?.id)) return;
        await ctx.sendChatAction('typing');
        const reply = await this.avatar.ask(
          this.conversationId(ctx.from?.id),
          character,
          text,
          {
            source: 'telegram',
            telegramUserId: ctx.from ? String(ctx.from.id) : undefined,
          },
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

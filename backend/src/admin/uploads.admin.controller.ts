import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync } from 'node:fs';
import { extname, join } from 'node:path';

import {
  BadRequestException,
  Controller,
  Param,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

type UploadKind = 'image' | 'audio' | 'video' | 'model' | 'pdf' | 'file';

const KINDS: Record<UploadKind, { mimes: RegExp; exts: string[]; maxBytes: number }> = {
  image: {
    mimes: /^image\/(png|jpe?g|webp|gif|svg\+xml|avif)$/,
    exts: ['.png', '.jpg', '.jpeg', '.webp', '.gif', '.svg', '.avif'],
    maxBytes: 10 * 1024 * 1024,
  },
  audio: {
    mimes: /^audio\/(mpeg|mp3|wav|ogg|webm|x-m4a|mp4|aac)$/,
    exts: ['.mp3', '.wav', '.ogg', '.oga', '.webm', '.m4a', '.aac'],
    maxBytes: 50 * 1024 * 1024,
  },
  video: {
    mimes: /^video\/(mp4|webm|quicktime|ogg)$/,
    exts: ['.mp4', '.webm', '.mov', '.ogv'],
    maxBytes: 200 * 1024 * 1024,
  },
  model: {
    mimes: /^(model\/(gltf-binary|gltf\+json)|application\/octet-stream)$/,
    exts: ['.glb', '.gltf', '.usdz'],
    maxBytes: 100 * 1024 * 1024,
  },
  pdf: {
    mimes: /^application\/pdf$/,
    exts: ['.pdf'],
    maxBytes: 100 * 1024 * 1024,
  },
  file: {
    mimes: /.*/,
    exts: [],
    maxBytes: 50 * 1024 * 1024,
  },
};

const UPLOADS_DIR = join(process.cwd(), 'public', 'uploads');

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/uploads')
export class UploadsAdminController {
  @Post(':kind')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (req, _file, cb) => {
          const kind = String(req.params.kind ?? 'file');
          const dir = join(UPLOADS_DIR, kind);
          if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
          cb(null, dir);
        },
        filename: (_req, file, cb) => {
          const ext = extname(file.originalname).toLowerCase();
          cb(null, `${randomUUID()}${ext}`);
        },
      }),
      limits: { fileSize: 200 * 1024 * 1024 },
    }),
  )
  upload(
    @Param('kind') rawKind: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('No file uploaded');
    const kind = (KINDS[rawKind as UploadKind] ? rawKind : 'file') as UploadKind;
    const rules = KINDS[kind];

    if (file.size > rules.maxBytes) {
      throw new BadRequestException(
        `File too large (max ${Math.round(rules.maxBytes / 1024 / 1024)}MB)`,
      );
    }

    const ext = extname(file.originalname).toLowerCase();
    if (rules.exts.length > 0 && !rules.exts.includes(ext)) {
      throw new BadRequestException(
        `Extension ${ext} is not allowed for ${kind} (allowed: ${rules.exts.join(', ')})`,
      );
    }
    if (kind !== 'file' && file.mimetype && !rules.mimes.test(file.mimetype)) {
      throw new BadRequestException(
        `Mime ${file.mimetype} is not allowed for ${kind}`,
      );
    }

    const url = `/uploads/${kind}/${file.filename}`;
    return {
      url,
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      kind,
    };
  }
}

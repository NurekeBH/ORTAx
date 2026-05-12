import { existsSync, readdirSync, statSync } from 'node:fs';
import { extname, join } from 'node:path';

import { Controller, Get, Param, UseGuards } from '@nestjs/common';

import { AdminGuard } from '../auth/admin.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

const LIBRARY_ROOT = join(process.cwd(), 'public', 'uploads');

const KINDS: Record<string, { dir: string; exts: string[] }> = {
  models: { dir: 'models-library', exts: ['.glb', '.gltf', '.usdz'] },
  images: { dir: 'images-library', exts: ['.png', '.jpg', '.jpeg', '.webp', '.svg'] },
  audio: { dir: 'audio-library', exts: ['.mp3', '.wav', '.ogg', '.m4a'] },
};

@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/library')
export class LibraryAdminController {
  @Get(':kind')
  list(@Param('kind') rawKind: string) {
    const cfg = KINDS[rawKind];
    if (!cfg) return { items: [] };
    const dir = join(LIBRARY_ROOT, cfg.dir);
    if (!existsSync(dir)) return { items: [] };
    const files = readdirSync(dir)
      .filter((f) => cfg.exts.includes(extname(f).toLowerCase()))
      .map((name) => {
        const full = join(dir, name);
        const stats = statSync(full);
        return {
          name,
          url: `/uploads/${cfg.dir}/${name}`,
          size: stats.size,
          modifiedAt: stats.mtime.toISOString(),
        };
      })
      .sort((a, b) => a.name.localeCompare(b.name));
    return { items: files };
  }
}

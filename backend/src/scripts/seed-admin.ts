import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';

import { AppModule } from '../app.module';
import { UserRole } from '../users/user.entity';
import { UsersService } from '../users/users.service';

function parseArg(name: string): string | undefined {
  const flag = `--${name}`;
  const idx = process.argv.findIndex((a) => a === flag || a.startsWith(`${flag}=`));
  if (idx === -1) return undefined;
  const token = process.argv[idx];
  if (token.includes('=')) return token.slice(token.indexOf('=') + 1);
  return process.argv[idx + 1];
}

async function main() {
  const phone = parseArg('phone') ?? process.env.ADMIN_PHONE;
  const password = parseArg('password') ?? process.env.ADMIN_PASSWORD;
  const displayName = parseArg('name') ?? process.env.ADMIN_NAME ?? 'Admin';

  if (!phone || !password) {
    console.error(
      'Usage: npm run seed:admin -- --phone <phone> --password <password> [--name <name>]',
    );
    console.error('   or: ADMIN_PHONE=... ADMIN_PASSWORD=... npm run seed:admin');
    process.exit(1);
  }

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });
  const users = app.get(UsersService);

  const existing = await users.findByPhone(phone);
  if (existing) {
    await users.setRole(existing.id, UserRole.ADMIN);
    await users.setBanned(existing.id, false);
    await users.updatePassword(existing.id, password);
    await users.setDisplayName(existing.id, displayName);
    console.log(`✓ Existing user ${phone} promoted to admin; password reset.`);
  } else {
    const created = await users.create(phone, password, UserRole.ADMIN);
    await users.setDisplayName(created.id, displayName);
    console.log(`✓ Admin created: ${created.phone} (id=${created.id})`);
  }

  await app.close();
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});

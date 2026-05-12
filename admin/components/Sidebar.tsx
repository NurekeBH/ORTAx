'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

import { useI18n } from '../lib/i18n';

const links: {
  href: string;
  key: string;
  icon: string;
  child?: boolean;
}[] = [
  { href: '/', key: 'nav.dashboard', icon: '◆' },
  { href: '/users', key: 'nav.users', icon: '◉' },
  { href: '/categories', key: 'nav.categories', icon: '◈' },
  { href: '/journals', key: 'nav.journals', icon: '▤' },
  { href: '/avatar', key: 'nav.avatar', icon: '◐' },
  { href: '/avatar#khwarizmi', key: 'nav.khwarizmi', icon: '🧮', child: true },
  { href: '/avatar#yassawi', key: 'nav.yassawi', icon: '🕌', child: true },
  { href: '/onboarding', key: 'nav.onboarding', icon: '◓' },
  { href: '/telegram', key: 'nav.telegram', icon: '✈' },
];

export function Sidebar() {
  const path = usePathname();
  const { t } = useI18n();
  return (
    <aside className="w-60 shrink-0 border-r border-slate-200 bg-white">
      <div className="px-5 py-5">
        <div className="text-lg font-bold text-brand-700">{t('app.title')}</div>
        <div className="text-xs text-slate-500">{t('app.subtitle')}</div>
      </div>
      <nav className="px-3 pb-4">
        {links.map((l) => {
          const hrefBase = l.href.split('#')[0];
          const active = l.child
            ? false
            : hrefBase === '/'
              ? path === '/'
              : path?.startsWith(hrefBase);
          return (
            <Link
              key={l.href}
              href={l.href}
              className={
                'flex items-center gap-2 rounded-md py-2 text-sm transition ' +
                (l.child ? 'pl-7 pr-3 ' : 'px-3 ') +
                (active
                  ? 'bg-brand-50 text-brand-700 font-medium'
                  : 'text-slate-700 hover:bg-slate-100')
              }
            >
              <span className="w-4 text-center text-slate-400">{l.icon}</span>
              {t(l.key)}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}

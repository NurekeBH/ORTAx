'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const links = [
  { href: '/', label: 'Dashboard', icon: '◆' },
  { href: '/users', label: 'Users', icon: '◉' },
  { href: '/journals', label: 'Journals', icon: '▤' },
  { href: '/avatar', label: 'Avatar', icon: '◐' },
  { href: '/telegram', label: 'Telegram', icon: '✈' },
];

export function Sidebar() {
  const path = usePathname();
  return (
    <aside className="w-60 shrink-0 border-r border-slate-200 bg-white">
      <div className="px-5 py-5">
        <div className="text-lg font-bold text-brand-700">ORTAx Admin</div>
        <div className="text-xs text-slate-500">Backend control panel</div>
      </div>
      <nav className="px-3 pb-4">
        {links.map((l) => {
          const active = l.href === '/' ? path === '/' : path?.startsWith(l.href);
          return (
            <Link
              key={l.href}
              href={l.href}
              className={
                'flex items-center gap-2 rounded-md px-3 py-2 text-sm transition ' +
                (active
                  ? 'bg-brand-50 text-brand-700 font-medium'
                  : 'text-slate-700 hover:bg-slate-100')
              }
            >
              <span className="w-4 text-center text-slate-400">{l.icon}</span>
              {l.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}

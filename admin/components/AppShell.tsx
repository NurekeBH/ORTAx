'use client';

import { useRouter, usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';

import { clearAuth, getStoredUser, getToken } from '../lib/api';
import { I18nProvider, LOCALES, useI18n } from '../lib/i18n';
import { Sidebar } from './Sidebar';

function LanguageSwitcher() {
  const { locale, setLocale } = useI18n();
  return (
    <div className="flex items-center gap-1 rounded-md border border-slate-200 bg-white p-0.5">
      {LOCALES.map((l) => (
        <button
          key={l.code}
          onClick={() => setLocale(l.code)}
          className={
            'rounded px-2 py-0.5 text-xs transition ' +
            (locale === l.code
              ? 'bg-brand-600 text-white'
              : 'text-slate-600 hover:bg-slate-100')
          }
          title={l.label}
        >
          {l.flag} {l.label}
        </button>
      ))}
    </div>
  );
}

function ShellInner({ children }: { children: React.ReactNode }) {
  const path = usePathname();
  const router = useRouter();
  const { t } = useI18n();
  const [ready, setReady] = useState(false);
  const [userLabel, setUserLabel] = useState<string>('');

  const isLogin = path === '/login';

  useEffect(() => {
    if (isLogin) {
      setReady(true);
      return;
    }
    const token = getToken();
    if (!token) {
      router.replace('/login');
      return;
    }
    const user = getStoredUser();
    if (user) setUserLabel(user.displayName || user.phone);
    setReady(true);
  }, [isLogin, path, router]);

  function logout() {
    clearAuth();
    router.replace('/login');
  }

  if (isLogin) {
    return (
      <div className="relative">
        <div className="absolute right-4 top-4 z-10">
          <LanguageSwitcher />
        </div>
        {children}
      </div>
    );
  }

  if (!ready) {
    return (
      <div className="flex min-h-screen items-center justify-center text-slate-400">
        {t('common.loading')}
      </div>
    );
  }

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1">
        <header className="flex items-center justify-end gap-3 border-b border-slate-200 bg-white px-6 py-2 text-sm">
          <LanguageSwitcher />
          <span className="text-slate-600">{userLabel || 'admin'}</span>
          <button
            onClick={logout}
            className="rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
          >
            {t('common.logout')}
          </button>
        </header>
        <div className="mx-auto max-w-7xl px-6 py-6">{children}</div>
      </main>
    </div>
  );
}

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <I18nProvider>
      <ShellInner>{children}</ShellInner>
    </I18nProvider>
  );
}

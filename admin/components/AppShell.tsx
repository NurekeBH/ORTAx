'use client';

import { useRouter, usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';

import { clearAuth, getStoredUser, getToken } from '../lib/api';
import { Sidebar } from './Sidebar';

export function AppShell({ children }: { children: React.ReactNode }) {
  const path = usePathname();
  const router = useRouter();
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

  if (isLogin) return <>{children}</>;
  if (!ready) {
    return (
      <div className="flex min-h-screen items-center justify-center text-slate-400">
        Loading…
      </div>
    );
  }

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1">
        <header className="flex items-center justify-end border-b border-slate-200 bg-white px-6 py-2 text-sm">
          <span className="mr-3 text-slate-600">
            {userLabel || 'admin'}
          </span>
          <button
            onClick={logout}
            className="rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
          >
            Logout
          </button>
        </header>
        <div className="mx-auto max-w-7xl px-6 py-6">{children}</div>
      </main>
    </div>
  );
}

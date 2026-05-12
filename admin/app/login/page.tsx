'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';

import { login, setStoredUser, setToken } from '../../lib/api';
import { useI18n } from '../../lib/i18n';

export default function LoginPage() {
  const { t } = useI18n();
  const router = useRouter();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const { accessToken, user } = await login(phone, password);
      setToken(accessToken);
      setStoredUser(user);
      router.replace('/');
    } catch (err) {
      setError(
        err instanceof Error && err.message
          ? err.message.replace(/^.*?:\s*\d+\s*/, '')
          : 'Login failed',
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-100">
      <form
        onSubmit={onSubmit}
        className="card w-full max-w-sm space-y-4 p-6"
      >
        <div>
          <div className="text-xl font-bold text-brand-700">
            {t('login.title')}
          </div>
          <p className="text-sm text-slate-500">{t('login.subtitle')}</p>
        </div>

        <div>
          <label className="mb-1 block text-xs font-medium text-slate-600">
            {t('login.phone')}
          </label>
          <input
            className="input"
            type="tel"
            placeholder="+7..."
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            autoComplete="username"
            required
          />
        </div>

        <div>
          <label className="mb-1 block text-xs font-medium text-slate-600">
            {t('login.password')}
          </label>
          <input
            className="input"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="current-password"
            required
          />
        </div>

        {error && (
          <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
            {error}
          </div>
        )}

        <button
          type="submit"
          className="btn-primary w-full"
          disabled={loading || !phone || !password}
        >
          {loading ? t('login.submitting') : t('login.submit')}
        </button>

        <p className="text-center text-xs text-slate-400">
          {t('login.note')}
        </p>
      </form>
    </div>
  );
}

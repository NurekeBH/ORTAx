'use client';

import { useState } from 'react';
import useSWR from 'swr';

import { api, fetcher } from '../../lib/api';
import { useI18n } from '../../lib/i18n';

interface TgUser {
  telegramId: string;
  username?: string;
  firstName?: string;
  lastName?: string;
  languageCode?: string;
  lastCharacter?: string;
  messageCount: number;
  banned: boolean;
  createdAt: string;
  updatedAt: string;
}

interface ListResponse {
  items: TgUser[];
  total: number;
}

interface Character {
  id: string;
  displayName: string;
}

export default function TelegramPage() {
  const { t } = useI18n();
  const [search, setSearch] = useState('');
  const [character, setCharacter] = useState('');
  const qs = new URLSearchParams({ pageSize: '100' });
  if (search) qs.set('search', search);
  if (character) qs.set('character', character);

  const { data, mutate, isLoading } = useSWR<ListResponse>(
    `/admin/telegram/users?${qs}`,
    fetcher,
  );
  const { data: characters } = useSWR<Character[]>(
    '/admin/avatar/characters',
    fetcher,
  );

  const [broadcast, setBroadcast] = useState({
    character: '',
    message: '',
  });
  const [broadcastResult, setBroadcastResult] = useState<string | null>(null);

  async function setBan(telegramId: string, banned: boolean) {
    await api(`/admin/telegram/users/${telegramId}/ban`, {
      method: 'PATCH',
      body: JSON.stringify({ banned }),
    });
    mutate();
  }

  async function sendBroadcast() {
    if (!broadcast.character || !broadcast.message) return;
    if (!confirm(`${broadcast.character} — ${t('tg.confirm_broadcast')}`))
      return;
    const res = await api<{ sent: number; failed: number }>(
      '/admin/telegram/broadcast',
      {
        method: 'POST',
        body: JSON.stringify(broadcast),
      },
    );
    setBroadcastResult(`Sent: ${res.sent}, failed: ${res.failed}`);
    setBroadcast({ character: '', message: '' });
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-slate-900">{t('tg.title')}</h1>
      <p className="text-sm text-slate-500">{t('tg.subtitle')}</p>

      <section className="card mt-4 p-4">
        <h2 className="text-sm font-semibold text-slate-700">
          {t('tg.broadcast')}
        </h2>
        <p className="mt-1 text-xs text-slate-500">
          {t('tg.broadcast_hint')}
        </p>
        <div className="mt-3 grid gap-2 md:grid-cols-[200px_1fr_auto]">
          <select
            className="input"
            value={broadcast.character}
            onChange={(e) =>
              setBroadcast({ ...broadcast, character: e.target.value })
            }
          >
            <option value="">{t('tg.select_bot')}</option>
            {characters?.map((c) => (
              <option key={c.id} value={c.id}>
                {c.displayName}
              </option>
            ))}
          </select>
          <input
            className="input"
            placeholder={t('tg.msg_ph')}
            value={broadcast.message}
            onChange={(e) =>
              setBroadcast({ ...broadcast, message: e.target.value })
            }
          />
          <button
            className="btn-primary"
            disabled={!broadcast.character || !broadcast.message}
            onClick={sendBroadcast}
          >
            {t('tg.send')}
          </button>
        </div>
        {broadcastResult && (
          <div className="mt-2 rounded bg-emerald-50 p-2 text-xs text-emerald-700">
            {broadcastResult}
          </div>
        )}
      </section>

      <section className="mt-6">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-semibold text-slate-700">
            {t('tg.users_title')} ({data?.total ?? 0})
          </h2>
          <div className="flex gap-2">
            <input
              className="input max-w-[200px]"
              placeholder={t('tg.search_ph')}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            <select
              className="input max-w-[180px]"
              value={character}
              onChange={(e) => setCharacter(e.target.value)}
            >
              <option value="">All bots</option>
              {characters?.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.displayName}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="card mt-3 overflow-hidden">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-left text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2">TG ID</th>
                <th className="px-4 py-2">Username</th>
                <th className="px-4 py-2">Name</th>
                <th className="px-4 py-2">Lang</th>
                <th className="px-4 py-2">Bot</th>
                <th className="px-4 py-2">Msgs</th>
                <th className="px-4 py-2">Status</th>
                <th className="px-4 py-2">Last activity</th>
                <th className="px-4 py-2 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && (
                <tr>
                  <td className="px-4 py-3 text-slate-500" colSpan={9}>
                    Loading…
                  </td>
                </tr>
              )}
              {data?.items.map((u) => (
                <tr key={u.telegramId} className="border-t border-slate-100">
                  <td className="px-4 py-2 font-mono text-xs">
                    {u.telegramId}
                  </td>
                  <td className="px-4 py-2">
                    {u.username ? `@${u.username}` : '—'}
                  </td>
                  <td className="px-4 py-2 text-slate-700">
                    {[u.firstName, u.lastName].filter(Boolean).join(' ') || '—'}
                  </td>
                  <td className="px-4 py-2 text-xs text-slate-500">
                    {u.languageCode ?? '—'}
                  </td>
                  <td className="px-4 py-2 text-xs">
                    {u.lastCharacter ?? '—'}
                  </td>
                  <td className="px-4 py-2 text-slate-600">
                    {u.messageCount}
                  </td>
                  <td className="px-4 py-2">
                    {u.banned ? (
                      <span className="badge bg-red-100 text-red-700">
                        banned
                      </span>
                    ) : (
                      <span className="badge bg-emerald-100 text-emerald-700">
                        active
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-2 text-xs text-slate-500">
                    {new Date(u.updatedAt).toLocaleString()}
                  </td>
                  <td className="px-4 py-2 text-right">
                    <button
                      className="rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                      onClick={() => setBan(u.telegramId, !u.banned)}
                    >
                      {u.banned ? 'Unban' : 'Ban'}
                    </button>
                  </td>
                </tr>
              ))}
              {data && data.items.length === 0 && (
                <tr>
                  <td className="px-4 py-6 text-center text-slate-500" colSpan={9}>
                    TG пайдаланушы жоқ
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

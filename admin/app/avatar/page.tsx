'use client';

import { useState } from 'react';
import useSWR from 'swr';

import { FileUpload } from '../../components/FileUpload';
import { api, assetUrl, fetcher } from '../../lib/api';
import { useI18n } from '../../lib/i18n';

interface Character {
  id: string;
  displayName: string;
  greeting: string;
  helpText: string;
  language: string | null;
  systemPrompt: string;
  defaultImageUrl: string | null;
  imageUrl: string | null;
  hasOverride: boolean;
}

interface ChatLog {
  id: string;
  character: string;
  conversationId: string;
  role: 'user' | 'assistant';
  content: string;
  source: string;
  telegramUserId?: string;
  createdAt: string;
}

interface ListResponse {
  items: ChatLog[];
  total: number;
}

export default function AvatarPage() {
  const { t } = useI18n();
  const { data: characters, mutate: mutateCharacters } = useSWR<Character[]>(
    '/admin/avatar/characters',
    fetcher,
  );

  const [character, setCharacter] = useState('');
  const [source, setSource] = useState('');

  async function setImage(charId: string, url: string) {
    await api(`/admin/avatar/characters/${charId}/image`, {
      method: 'PATCH',
      body: JSON.stringify({ imageUrl: url || undefined }),
    });
    mutateCharacters();
  }

  async function resetImage(charId: string) {
    await api(`/admin/avatar/characters/${charId}/image`, {
      method: 'PATCH',
      body: JSON.stringify({ imageUrl: null }),
    });
    mutateCharacters();
  }

  const qs = new URLSearchParams({ pageSize: '100' });
  if (character) qs.set('character', character);
  if (source) qs.set('source', source);

  const { data: logs, isLoading } = useSWR<ListResponse>(
    `/admin/avatar/logs?${qs}`,
    fetcher,
    { refreshInterval: 15000 },
  );

  const [openPrompt, setOpenPrompt] = useState<string | null>(null);

  return (
    <div>
      <h1 className="text-2xl font-bold text-slate-900">{t('av.title')}</h1>
      <p className="text-sm text-slate-500">{t('av.subtitle')}</p>

      <section className="mt-6">
        <h2 className="mb-2 text-sm font-semibold text-slate-700">
          {t('av.characters')}
        </h2>
        <div id="characters" className="grid gap-3 md:grid-cols-2">
          {characters?.map((c) => (
            <div
              key={c.id}
              id={c.id}
              className="card scroll-mt-20 p-4"
            >
              <div className="flex items-start gap-3">
                <div className="shrink-0">
                  {c.imageUrl ? (
                    <img
                      src={assetUrl(c.imageUrl)}
                      alt={c.displayName}
                      className="h-20 w-20 rounded-lg border border-slate-200 object-cover"
                    />
                  ) : (
                    <div className="flex h-20 w-20 items-center justify-center rounded-lg border border-dashed border-slate-200 bg-slate-50 text-2xl text-slate-400">
                      ?
                    </div>
                  )}
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <div className="font-semibold text-slate-900">
                      {c.displayName}
                    </div>
                    <span className="badge bg-slate-100 text-slate-700">
                      {c.id}
                    </span>
                  </div>
                  <p className="mt-1 line-clamp-2 text-sm text-slate-600">
                    {c.greeting}
                  </p>
                  <div className="mt-1 text-xs text-slate-500">
                    {t('av.language')}: {c.language ?? 'auto'}
                  </div>
                </div>
              </div>

              <div className="mt-3 border-t border-slate-100 pt-3">
                <FileUpload
                  kind="image"
                  label={t('av.portrait')}
                  value={c.imageUrl ?? ''}
                  onChange={(url) => setImage(c.id, url)}
                />
                <div className="mt-2 flex items-center justify-between text-xs">
                  <span className="text-slate-500">
                    {c.hasOverride
                      ? t('av.custom_image')
                      : t('av.default_image')}
                  </span>
                  {c.hasOverride && (
                    <button
                      className="text-brand-700 hover:underline"
                      onClick={() => resetImage(c.id)}
                    >
                      {t('av.reset_default')}
                    </button>
                  )}
                </div>
                {c.defaultImageUrl && (
                  <div className="mt-1 font-mono text-[10px] text-slate-400">
                    {t('av.default_url')}: {c.defaultImageUrl}
                  </div>
                )}
              </div>

              <button
                className="mt-3 text-xs text-brand-700 hover:underline"
                onClick={() =>
                  setOpenPrompt(openPrompt === c.id ? null : c.id)
                }
              >
                {openPrompt === c.id
                  ? t('av.hide_prompt')
                  : t('av.show_prompt')}
              </button>
              {openPrompt === c.id && (
                <pre className="mt-2 max-h-64 overflow-auto rounded bg-slate-900 p-3 text-xs text-slate-100">
                  {c.systemPrompt}
                </pre>
              )}
            </div>
          ))}
        </div>
      </section>

      <section className="mt-8">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-semibold text-slate-700">
            {t('av.logs')}
          </h2>
          <div className="flex gap-2">
            <select
              className="input max-w-[180px]"
              value={character}
              onChange={(e) => setCharacter(e.target.value)}
            >
              <option value="">{t('av.all_chars')}</option>
              {characters?.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.displayName}
                </option>
              ))}
            </select>
            <select
              className="input max-w-[160px]"
              value={source}
              onChange={(e) => setSource(e.target.value)}
            >
              <option value="">{t('av.all_sources')}</option>
              <option value="mobile">mobile</option>
              <option value="telegram">telegram</option>
              <option value="web">web</option>
            </select>
          </div>
        </div>

        <div className="card mt-3 overflow-hidden">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-left text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2">Time</th>
                <th className="px-4 py-2">Character</th>
                <th className="px-4 py-2">Source</th>
                <th className="px-4 py-2">Role</th>
                <th className="px-4 py-2">Message</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && (
                <tr>
                  <td className="px-4 py-3 text-slate-500" colSpan={5}>
                    Loading…
                  </td>
                </tr>
              )}
              {logs?.items.map((l) => (
                <tr key={l.id} className="border-t border-slate-100 align-top">
                  <td className="whitespace-nowrap px-4 py-2 text-xs text-slate-500">
                    {new Date(l.createdAt).toLocaleString()}
                  </td>
                  <td className="px-4 py-2">
                    <span className="badge bg-slate-100 text-slate-700">
                      {l.character}
                    </span>
                  </td>
                  <td className="px-4 py-2 text-xs text-slate-500">
                    {l.source}
                  </td>
                  <td className="px-4 py-2">
                    {l.role === 'user' ? (
                      <span className="badge bg-blue-100 text-blue-700">
                        user
                      </span>
                    ) : (
                      <span className="badge bg-emerald-100 text-emerald-700">
                        assistant
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-2 text-slate-700">
                    <div className="line-clamp-3 whitespace-pre-wrap">
                      {l.content}
                    </div>
                  </td>
                </tr>
              ))}
              {logs && logs.items.length === 0 && (
                <tr>
                  <td className="px-4 py-6 text-center text-slate-500" colSpan={5}>
                    Log жоқ
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        {logs && (
          <div className="mt-2 text-xs text-slate-500">
            Showing {logs.items.length} of {logs.total} (auto-refresh 15s)
          </div>
        )}
      </section>
    </div>
  );
}

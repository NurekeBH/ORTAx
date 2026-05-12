'use client';

import useSWR from 'swr';

import { fetcher } from '../lib/api';
import { useI18n } from '../lib/i18n';

interface Overview {
  users: { total: number; dau: number; wau: number; mau: number };
  content: {
    journals: number;
    pages: number;
    arAssets: number;
    categories?: number;
  };
  avatar: { messages24h: number; messagesTotal: number };
  telegram: { total: number; banned: number };
}

function Stat({
  label,
  value,
  hint,
}: {
  label: string;
  value: number | string;
  hint?: string;
}) {
  return (
    <div className="card p-4">
      <div className="text-xs uppercase tracking-wide text-slate-500">
        {label}
      </div>
      <div className="mt-1 text-2xl font-semibold text-slate-900">{value}</div>
      {hint && <div className="mt-0.5 text-xs text-slate-400">{hint}</div>}
    </div>
  );
}

export default function DashboardPage() {
  const { t } = useI18n();
  const { data, error, isLoading } = useSWR<Overview>(
    '/admin/analytics/overview',
    fetcher,
    { refreshInterval: 30000 },
  );

  return (
    <div>
      <h1 className="text-2xl font-bold text-slate-900">{t('dash.title')}</h1>
      <p className="text-sm text-slate-500">{t('dash.subtitle')}</p>

      {isLoading && (
        <div className="mt-6 text-slate-500">{t('common.loading')}</div>
      )}
      {error && (
        <div className="mt-6 rounded-md border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          {t('dash.error')}
        </div>
      )}

      {data && (
        <div className="mt-6 space-y-6">
          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              {t('dash.users')}
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
              <Stat label={t('dash.total')} value={data.users.total} />
              <Stat
                label={t('dash.dau')}
                value={data.users.dau}
                hint={t('dash.last24h')}
              />
              <Stat
                label={t('dash.wau')}
                value={data.users.wau}
                hint={t('dash.last7d')}
              />
              <Stat
                label={t('dash.mau')}
                value={data.users.mau}
                hint={t('dash.last30d')}
              />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              {t('dash.content')}
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
              <Stat
                label={t('dash.categories')}
                value={data.content.categories ?? 0}
              />
              <Stat
                label={t('dash.journals')}
                value={data.content.journals}
              />
              <Stat label={t('dash.pages')} value={data.content.pages} />
              <Stat
                label={t('dash.ar_assets')}
                value={data.content.arAssets}
              />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              {t('dash.avatar_chat')}
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
              <Stat
                label={t('dash.messages_24h')}
                value={data.avatar.messages24h}
              />
              <Stat
                label={t('dash.messages_total')}
                value={data.avatar.messagesTotal}
              />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              {t('dash.telegram')}
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
              <Stat
                label={t('dash.tg_users')}
                value={data.telegram.total}
              />
              <Stat label={t('dash.banned')} value={data.telegram.banned} />
            </div>
          </section>
        </div>
      )}
    </div>
  );
}

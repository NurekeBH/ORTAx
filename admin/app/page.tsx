'use client';

import useSWR from 'swr';

import { fetcher } from '../lib/api';

interface Overview {
  users: { total: number; dau: number; wau: number; mau: number };
  content: { journals: number; pages: number; arAssets: number };
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
  const { data, error, isLoading } = useSWR<Overview>(
    '/admin/analytics/overview',
    fetcher,
    { refreshInterval: 30000 },
  );

  return (
    <div>
      <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
      <p className="text-sm text-slate-500">
        ORTAx platform overview (auto-refresh: 30s)
      </p>

      {isLoading && <div className="mt-6 text-slate-500">Loading…</div>}
      {error && (
        <div className="mt-6 rounded-md border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          Failed to load analytics. Make sure the backend is running and the
          database is enabled.
        </div>
      )}

      {data && (
        <div className="mt-6 space-y-6">
          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              Users
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
              <Stat label="Total" value={data.users.total} />
              <Stat label="DAU" value={data.users.dau} hint="last 24h" />
              <Stat label="WAU" value={data.users.wau} hint="last 7 days" />
              <Stat label="MAU" value={data.users.mau} hint="last 30 days" />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              Content
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
              <Stat label="Journals" value={data.content.journals} />
              <Stat label="Pages" value={data.content.pages} />
              <Stat label="AR assets" value={data.content.arAssets} />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              Avatar chat
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
              <Stat
                label="Messages (24h)"
                value={data.avatar.messages24h}
              />
              <Stat
                label="Messages (all time)"
                value={data.avatar.messagesTotal}
              />
            </div>
          </section>

          <section>
            <h2 className="mb-2 text-sm font-semibold text-slate-700">
              Telegram
            </h2>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
              <Stat label="TG users" value={data.telegram.total} />
              <Stat label="Banned" value={data.telegram.banned} />
            </div>
          </section>
        </div>
      )}
    </div>
  );
}

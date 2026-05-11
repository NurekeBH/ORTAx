'use client';

import { useState } from 'react';
import useSWR from 'swr';

import { api, fetcher } from '../../lib/api';

interface User {
  id: string;
  phone: string;
  role: 'student' | 'teacher' | 'admin';
  banned: boolean;
  gradeLevel?: string;
  displayName?: string;
  lastSeenAt?: string;
  createdAt: string;
}

interface ListResponse {
  items: User[];
  total: number;
}

const ROLES = ['student', 'teacher', 'admin'] as const;

export default function UsersPage() {
  const [search, setSearch] = useState('');
  const [role, setRole] = useState<string>('');
  const [page, setPage] = useState(1);
  const pageSize = 20;

  const qs = new URLSearchParams({
    page: String(page),
    pageSize: String(pageSize),
  });
  if (search) qs.set('search', search);
  if (role) qs.set('role', role);

  const { data, mutate, isLoading } = useSWR<ListResponse>(
    `/admin/users?${qs}`,
    fetcher,
  );

  async function setUserRole(id: string, newRole: string) {
    await api(`/admin/users/${id}/role`, {
      method: 'PATCH',
      body: JSON.stringify({ role: newRole }),
    });
    mutate();
  }

  async function setBan(id: string, banned: boolean) {
    await api(`/admin/users/${id}/ban`, {
      method: 'PATCH',
      body: JSON.stringify({ banned }),
    });
    mutate();
  }

  async function removeUser(id: string) {
    if (!confirm('Бұл пайдаланушыны жоюды растайсыз ба?')) return;
    await api(`/admin/users/${id}`, { method: 'DELETE' });
    mutate();
  }

  const total = data?.total ?? 0;
  const pages = Math.max(1, Math.ceil(total / pageSize));

  return (
    <div>
      <h1 className="text-2xl font-bold text-slate-900">Users</h1>
      <p className="text-sm text-slate-500">
        Mobile / web users (total: {total})
      </p>

      <div className="mt-4 flex flex-wrap gap-2">
        <input
          className="input max-w-xs"
          placeholder="Search by phone…"
          value={search}
          onChange={(e) => {
            setPage(1);
            setSearch(e.target.value);
          }}
        />
        <select
          className="input max-w-[160px]"
          value={role}
          onChange={(e) => {
            setPage(1);
            setRole(e.target.value);
          }}
        >
          <option value="">All roles</option>
          {ROLES.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
      </div>

      <div className="card mt-4 overflow-hidden">
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-left text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2">Phone</th>
              <th className="px-4 py-2">Role</th>
              <th className="px-4 py-2">Grade</th>
              <th className="px-4 py-2">Status</th>
              <th className="px-4 py-2">Last seen</th>
              <th className="px-4 py-2">Created</th>
              <th className="px-4 py-2 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading && (
              <tr>
                <td className="px-4 py-3 text-slate-500" colSpan={7}>
                  Loading…
                </td>
              </tr>
            )}
            {data?.items.map((u) => (
              <tr key={u.id} className="border-t border-slate-100">
                <td className="px-4 py-2 font-mono text-xs">{u.phone}</td>
                <td className="px-4 py-2">
                  <select
                    className="rounded border border-slate-200 bg-white px-2 py-1 text-xs"
                    value={u.role}
                    onChange={(e) => setUserRole(u.id, e.target.value)}
                  >
                    {ROLES.map((r) => (
                      <option key={r} value={r}>
                        {r}
                      </option>
                    ))}
                  </select>
                </td>
                <td className="px-4 py-2 text-slate-600">
                  {u.gradeLevel ?? '—'}
                </td>
                <td className="px-4 py-2">
                  {u.banned ? (
                    <span className="badge bg-red-100 text-red-700">banned</span>
                  ) : (
                    <span className="badge bg-emerald-100 text-emerald-700">
                      active
                    </span>
                  )}
                </td>
                <td className="px-4 py-2 text-slate-500">
                  {u.lastSeenAt
                    ? new Date(u.lastSeenAt).toLocaleString()
                    : '—'}
                </td>
                <td className="px-4 py-2 text-slate-500">
                  {new Date(u.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-2 text-right">
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => setBan(u.id, !u.banned)}
                  >
                    {u.banned ? 'Unban' : 'Ban'}
                  </button>
                  <button
                    className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                    onClick={() => removeUser(u.id)}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
            {data && data.items.length === 0 && (
              <tr>
                <td className="px-4 py-6 text-center text-slate-500" colSpan={7}>
                  No users found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="mt-3 flex items-center justify-between text-sm">
        <span className="text-slate-500">
          Page {page} of {pages}
        </span>
        <div className="flex gap-2">
          <button
            className="btn-secondary"
            disabled={page <= 1}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            Prev
          </button>
          <button
            className="btn-secondary"
            disabled={page >= pages}
            onClick={() => setPage((p) => Math.min(pages, p + 1))}
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
}

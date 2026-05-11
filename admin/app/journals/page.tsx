'use client';

import Link from 'next/link';
import { useState } from 'react';
import useSWR from 'swr';

import { api, fetcher } from '../../lib/api';

interface Journal {
  id: string;
  title: string;
  description: string;
  coverImage?: string;
  subject?: string;
  gradeLevel?: string;
  published: boolean;
  createdAt: string;
}

export default function JournalsPage() {
  const { data, mutate, isLoading } = useSWR<Journal[]>(
    '/admin/journals',
    fetcher,
  );
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState({
    title: '',
    description: '',
    coverImage: '',
    subject: '',
    gradeLevel: '',
    published: true,
  });

  async function createJournal() {
    await api('/admin/journals', {
      method: 'POST',
      body: JSON.stringify({
        title: form.title,
        description: form.description,
        coverImage: form.coverImage || undefined,
        subject: form.subject || undefined,
        gradeLevel: form.gradeLevel || undefined,
        published: form.published,
      }),
    });
    setCreating(false);
    setForm({
      title: '',
      description: '',
      coverImage: '',
      subject: '',
      gradeLevel: '',
      published: true,
    });
    mutate();
  }

  async function togglePublish(j: Journal) {
    await api(`/admin/journals/${j.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ published: !j.published }),
    });
    mutate();
  }

  async function remove(j: Journal) {
    if (!confirm(`"${j.title}" журналын жоюды растайсыз ба?`)) return;
    await api(`/admin/journals/${j.id}`, { method: 'DELETE' });
    mutate();
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Journals</h1>
          <p className="text-sm text-slate-500">
            Журналдар, беттер және AR ассеттер
          </p>
        </div>
        <button
          className="btn-primary"
          onClick={() => setCreating((v) => !v)}
        >
          {creating ? 'Cancel' : '+ New Journal'}
        </button>
      </div>

      {creating && (
        <div className="card mt-4 space-y-3 p-4">
          <input
            className="input"
            placeholder="Title"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
          />
          <textarea
            className="input"
            placeholder="Description"
            rows={3}
            value={form.description}
            onChange={(e) =>
              setForm({ ...form, description: e.target.value })
            }
          />
          <div className="grid grid-cols-2 gap-3">
            <input
              className="input"
              placeholder="Cover image URL"
              value={form.coverImage}
              onChange={(e) =>
                setForm({ ...form, coverImage: e.target.value })
              }
            />
            <input
              className="input"
              placeholder="Subject"
              value={form.subject}
              onChange={(e) => setForm({ ...form, subject: e.target.value })}
            />
            <input
              className="input"
              placeholder="Grade level"
              value={form.gradeLevel}
              onChange={(e) =>
                setForm({ ...form, gradeLevel: e.target.value })
              }
            />
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.published}
                onChange={(e) =>
                  setForm({ ...form, published: e.target.checked })
                }
              />
              Published
            </label>
          </div>
          <div className="flex justify-end">
            <button
              className="btn-primary"
              disabled={!form.title || !form.description}
              onClick={createJournal}
            >
              Create
            </button>
          </div>
        </div>
      )}

      <div className="card mt-4 overflow-hidden">
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-left text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2">Title</th>
              <th className="px-4 py-2">Subject</th>
              <th className="px-4 py-2">Grade</th>
              <th className="px-4 py-2">Status</th>
              <th className="px-4 py-2">Created</th>
              <th className="px-4 py-2 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading && (
              <tr>
                <td className="px-4 py-3 text-slate-500" colSpan={6}>
                  Loading…
                </td>
              </tr>
            )}
            {data?.map((j) => (
              <tr key={j.id} className="border-t border-slate-100">
                <td className="px-4 py-2">
                  <Link
                    className="font-medium text-brand-700 hover:underline"
                    href={`/journals/${j.id}`}
                  >
                    {j.title}
                  </Link>
                  <div className="line-clamp-1 text-xs text-slate-500">
                    {j.description}
                  </div>
                </td>
                <td className="px-4 py-2 text-slate-600">
                  {j.subject ?? '—'}
                </td>
                <td className="px-4 py-2 text-slate-600">
                  {j.gradeLevel ?? '—'}
                </td>
                <td className="px-4 py-2">
                  {j.published ? (
                    <span className="badge bg-emerald-100 text-emerald-700">
                      published
                    </span>
                  ) : (
                    <span className="badge bg-slate-200 text-slate-700">
                      draft
                    </span>
                  )}
                </td>
                <td className="px-4 py-2 text-slate-500">
                  {new Date(j.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-2 text-right">
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => togglePublish(j)}
                  >
                    {j.published ? 'Unpublish' : 'Publish'}
                  </button>
                  <button
                    className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                    onClick={() => remove(j)}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
            {data && data.length === 0 && (
              <tr>
                <td className="px-4 py-6 text-center text-slate-500" colSpan={6}>
                  Журнал жоқ
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

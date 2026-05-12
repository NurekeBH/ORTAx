'use client';

import { useState } from 'react';
import useSWR from 'swr';

import { FileUpload } from '../../components/FileUpload';
import { api, assetUrl, fetcher } from '../../lib/api';
import { useI18n } from '../../lib/i18n';

interface Category {
  id: string;
  slug: string;
  name: string;
  description?: string;
  icon?: string;
  color?: string;
  coverImage?: string;
  sortOrder: number;
  createdAt: string;
}

interface Form {
  slug: string;
  name: string;
  description: string;
  icon: string;
  color: string;
  coverImage: string;
  sortOrder: number;
}

const EMPTY_FORM: Form = {
  slug: '',
  name: '',
  description: '',
  icon: '',
  color: '#3b6cf2',
  coverImage: '',
  sortOrder: 0,
};

function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

export default function CategoriesPage() {
  const { t } = useI18n();
  const { data, mutate, isLoading } = useSWR<Category[]>(
    '/admin/categories',
    fetcher,
  );
  const [editing, setEditing] = useState<Category | null>(null);
  const [form, setForm] = useState<Form>(EMPTY_FORM);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function openCreate() {
    setEditing(null);
    setForm(EMPTY_FORM);
    setShowForm(true);
    setError(null);
  }

  function openEdit(cat: Category) {
    setEditing(cat);
    setForm({
      slug: cat.slug,
      name: cat.name,
      description: cat.description ?? '',
      icon: cat.icon ?? '',
      color: cat.color ?? '#3b6cf2',
      coverImage: cat.coverImage ?? '',
      sortOrder: cat.sortOrder,
    });
    setShowForm(true);
    setError(null);
  }

  async function save() {
    setError(null);
    try {
      const payload = {
        slug: form.slug || slugify(form.name),
        name: form.name,
        description: form.description || undefined,
        icon: form.icon || undefined,
        color: form.color || undefined,
        coverImage: form.coverImage || undefined,
        sortOrder: form.sortOrder,
      };
      if (editing) {
        await api(`/admin/categories/${editing.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload),
        });
      } else {
        await api('/admin/categories', {
          method: 'POST',
          body: JSON.stringify(payload),
        });
      }
      setShowForm(false);
      mutate();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Сақтау сәтсіз аяқталды');
    }
  }

  async function remove(cat: Category) {
    if (!confirm(`"${cat.name}" — ${t('cats.confirm_delete')}`)) return;
    await api(`/admin/categories/${cat.id}`, { method: 'DELETE' });
    mutate();
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">
            {t('cats.title')}
          </h1>
          <p className="text-sm text-slate-500">{t('cats.subtitle')}</p>
        </div>
        <button className="btn-primary" onClick={openCreate}>
          {t('cats.new')}
        </button>
      </div>

      {showForm && (
        <div className="card mt-4 space-y-3 p-4">
          <div className="text-sm font-semibold text-slate-700">
            {editing
              ? `${t('cats.edit_prefix')}${editing.name}`
              : t('cats.new_form')}
          </div>
          <div className="grid grid-cols-2 gap-3">
            <input
              className="input"
              placeholder={t('cats.name_ph')}
              value={form.name}
              onChange={(e) => {
                const name = e.target.value;
                setForm((prev) => ({
                  ...prev,
                  name,
                  slug:
                    !editing && (prev.slug === '' || prev.slug === slugify(prev.name))
                      ? slugify(name)
                      : prev.slug,
                }));
              }}
            />
            <input
              className="input font-mono text-xs"
              placeholder={t('cats.slug_ph')}
              value={form.slug}
              onChange={(e) => setForm({ ...form, slug: e.target.value })}
            />
          </div>
          <textarea
            className="input"
            placeholder={t('cats.desc_ph')}
            rows={2}
            value={form.description}
            onChange={(e) =>
              setForm({ ...form, description: e.target.value })
            }
          />
          <div className="grid grid-cols-3 gap-3">
            <input
              className="input"
              placeholder={t('cats.icon_ph')}
              value={form.icon}
              onChange={(e) => setForm({ ...form, icon: e.target.value })}
            />
            <div className="flex items-center gap-2">
              <input
                className="h-9 w-12 cursor-pointer rounded border border-slate-300"
                type="color"
                value={form.color}
                onChange={(e) => setForm({ ...form, color: e.target.value })}
              />
              <input
                className="input"
                placeholder={t('cats.color_ph')}
                value={form.color}
                onChange={(e) => setForm({ ...form, color: e.target.value })}
              />
            </div>
            <input
              className="input"
              type="number"
              placeholder={t('cats.sort_ph')}
              value={form.sortOrder}
              onChange={(e) =>
                setForm({
                  ...form,
                  sortOrder: parseInt(e.target.value, 10) || 0,
                })
              }
            />
          </div>
          <FileUpload
            kind="image"
            label={t('cats.cover')}
            value={form.coverImage}
            onChange={(url) => setForm({ ...form, coverImage: url })}
          />
          {error && (
            <div className="rounded border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
              {error}
            </div>
          )}
          <div className="flex justify-end gap-2">
            <button
              className="btn-secondary"
              onClick={() => setShowForm(false)}
            >
              {t('common.cancel')}
            </button>
            <button
              className="btn-primary"
              disabled={!form.name}
              onClick={save}
            >
              {editing ? t('common.save') : t('common.create')}
            </button>
          </div>
        </div>
      )}

      <div className="card mt-4 overflow-hidden">
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-left text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2">{t('cats.col.order')}</th>
              <th className="px-4 py-2">{t('cats.col.icon')}</th>
              <th className="px-4 py-2">{t('cats.col.name')}</th>
              <th className="px-4 py-2">{t('cats.col.slug')}</th>
              <th className="px-4 py-2">{t('cats.col.color')}</th>
              <th className="px-4 py-2 text-right">
                {t('common.actions')}
              </th>
            </tr>
          </thead>
          <tbody>
            {isLoading && (
              <tr>
                <td className="px-4 py-3 text-slate-500" colSpan={6}>
                  {t('common.loading')}
                </td>
              </tr>
            )}
            {data?.map((c) => (
              <tr key={c.id} className="border-t border-slate-100">
                <td className="px-4 py-2 text-slate-500">{c.sortOrder}</td>
                <td className="px-4 py-2 text-lg">{c.icon ?? '—'}</td>
                <td className="px-4 py-2 font-medium text-slate-900">
                  {c.name}
                  {c.description && (
                    <div className="line-clamp-1 text-xs text-slate-500">
                      {c.description}
                    </div>
                  )}
                </td>
                <td className="px-4 py-2 font-mono text-xs text-slate-600">
                  {c.slug}
                </td>
                <td className="px-4 py-2">
                  {c.color ? (
                    <span className="inline-flex items-center gap-1.5">
                      <span
                        className="inline-block h-4 w-4 rounded border border-slate-200"
                        style={{ backgroundColor: c.color }}
                      />
                      <span className="font-mono text-xs text-slate-500">
                        {c.color}
                      </span>
                    </span>
                  ) : (
                    '—'
                  )}
                </td>
                <td className="px-4 py-2 text-right">
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => openEdit(c)}
                  >
                    {t('common.edit')}
                  </button>
                  <button
                    className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                    onClick={() => remove(c)}
                  >
                    {t('common.delete')}
                  </button>
                </td>
              </tr>
            ))}
            {data && data.length === 0 && (
              <tr>
                <td className="px-4 py-6 text-center text-slate-500" colSpan={6}>
                  {t('cats.empty')}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

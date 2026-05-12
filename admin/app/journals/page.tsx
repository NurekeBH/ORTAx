'use client';

import Link from 'next/link';
import { useState } from 'react';
import useSWR from 'swr';

import { FileUpload } from '../../components/FileUpload';
import { api, assetUrl, fetcher } from '../../lib/api';
import { useI18n } from '../../lib/i18n';

interface Category {
  id: string;
  slug: string;
  name: string;
  icon?: string;
  color?: string;
}

interface Journal {
  id: string;
  title: string;
  description: string;
  coverImage?: string;
  pdfUrl?: string;
  trailerVideoUrl?: string;
  subject?: string;
  gradeLevel?: string;
  slug?: string;
  author?: string;
  language: string;
  tags?: string[];
  featured: boolean;
  published: boolean;
  publishedAt?: string;
  viewsCount: number;
  pagesCount?: number;
  categoryId?: string;
  category?: Category;
  createdAt: string;
}

interface ListResponse {
  items: Journal[];
  total: number;
}

interface Form {
  title: string;
  description: string;
  coverImage: string;
  pdfUrl: string;
  trailerVideoUrl: string;
  subject: string;
  gradeLevel: string;
  slug: string;
  author: string;
  language: string;
  tagsRaw: string;
  featured: boolean;
  published: boolean;
  categoryId: string;
}

const EMPTY_FORM: Form = {
  title: '',
  description: '',
  coverImage: '',
  pdfUrl: '',
  trailerVideoUrl: '',
  subject: '',
  gradeLevel: '',
  slug: '',
  author: '',
  language: 'kk',
  tagsRaw: '',
  featured: false,
  published: true,
  categoryId: '',
};

function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

export default function JournalsPage() {
  const { t } = useI18n();
  const [category, setCategory] = useState('');
  const [published, setPublished] = useState('');
  const [search, setSearch] = useState('');

  const qs = new URLSearchParams({ pageSize: '100' });
  if (category) qs.set('category', category);
  if (published) qs.set('published', published);
  if (search) qs.set('search', search);

  const { data: response, mutate, isLoading } = useSWR<ListResponse>(
    `/admin/journals?${qs}`,
    fetcher,
  );
  const data = response?.items;
  const { data: categories } = useSWR<Category[]>(
    '/admin/categories',
    fetcher,
  );

  const [editing, setEditing] = useState<Journal | null>(null);
  const [form, setForm] = useState<Form>(EMPTY_FORM);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function openCreate() {
    setEditing(null);
    setForm(EMPTY_FORM);
    setShowForm(true);
    setError(null);
  }

  function openEdit(j: Journal) {
    setEditing(j);
    setForm({
      title: j.title,
      description: j.description,
      coverImage: j.coverImage ?? '',
      pdfUrl: j.pdfUrl ?? '',
      trailerVideoUrl: j.trailerVideoUrl ?? '',
      subject: j.subject ?? '',
      gradeLevel: j.gradeLevel ?? '',
      slug: j.slug ?? '',
      author: j.author ?? '',
      language: j.language ?? 'kk',
      tagsRaw: (j.tags ?? []).join(', '),
      featured: j.featured,
      published: j.published,
      categoryId: j.categoryId ?? '',
    });
    setShowForm(true);
    setError(null);
  }

  async function save() {
    setError(null);
    try {
      const tags = form.tagsRaw
        .split(',')
        .map((t) => t.trim())
        .filter(Boolean);
      const payload = {
        title: form.title,
        description: form.description,
        coverImage: form.coverImage || undefined,
        pdfUrl: form.pdfUrl || undefined,
        trailerVideoUrl: form.trailerVideoUrl || undefined,
        subject: form.subject || undefined,
        gradeLevel: form.gradeLevel || undefined,
        slug: form.slug || undefined,
        author: form.author || undefined,
        language: form.language || 'kk',
        tags: tags.length ? tags : undefined,
        featured: form.featured,
        published: form.published,
        categoryId: form.categoryId || undefined,
      };
      if (editing) {
        await api(`/admin/journals/${editing.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload),
        });
      } else {
        await api('/admin/journals', {
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

  async function togglePublish(j: Journal) {
    await api(`/admin/journals/${j.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ published: !j.published }),
    });
    mutate();
  }

  async function toggleFeatured(j: Journal) {
    await api(`/admin/journals/${j.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ featured: !j.featured }),
    });
    mutate();
  }

  async function remove(j: Journal) {
    if (!confirm(`"${j.title}" — ${t('jr.confirm_delete')}`)) return;
    await api(`/admin/journals/${j.id}`, { method: 'DELETE' });
    mutate();
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">
            {t('jr.title')}
          </h1>
          <p className="text-sm text-slate-500">
            {t('jr.subtitle')} ({t('common.total')}: {response?.total ?? 0})
          </p>
        </div>
        <button className="btn-primary" onClick={openCreate}>
          {t('jr.new')}
        </button>
      </div>

      <div className="mt-4 flex flex-wrap gap-2">
        <input
          className="input max-w-xs"
          placeholder={t('jr.search_ph')}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          className="input max-w-[180px]"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        >
          <option value="">{t('jr.all_cats')}</option>
          {categories?.map((c) => (
            <option key={c.id} value={c.slug}>
              {c.icon ? `${c.icon} ` : ''}
              {c.name}
            </option>
          ))}
        </select>
        <select
          className="input max-w-[160px]"
          value={published}
          onChange={(e) => setPublished(e.target.value)}
        >
          <option value="">{t('jr.all_statuses')}</option>
          <option value="true">{t('common.published')}</option>
          <option value="false">{t('common.draft')}</option>
        </select>
      </div>

      {showForm && (
        <div className="card mt-4 space-y-3 p-4">
          <div className="text-sm font-semibold text-slate-700">
            {editing
              ? `${t('jr.edit_prefix')}${editing.title}`
              : t('jr.new_form')}
          </div>
          <div className="grid grid-cols-2 gap-3">
            <input
              className="input"
              placeholder={t('jr.title_ph')}
              value={form.title}
              onChange={(e) => {
                const title = e.target.value;
                setForm((prev) => ({
                  ...prev,
                  title,
                  slug:
                    !editing && (prev.slug === '' || prev.slug === slugify(prev.title))
                      ? slugify(title)
                      : prev.slug,
                }));
              }}
            />
            <input
              className="input font-mono text-xs"
              placeholder={t('jr.slug_ph')}
              value={form.slug}
              onChange={(e) => setForm({ ...form, slug: e.target.value })}
            />
          </div>
          <textarea
            className="input"
            placeholder={t('jr.desc_ph')}
            rows={3}
            value={form.description}
            onChange={(e) =>
              setForm({ ...form, description: e.target.value })
            }
          />
          <div className="grid grid-cols-3 gap-3">
            <select
              className="input"
              value={form.categoryId}
              onChange={(e) =>
                setForm({ ...form, categoryId: e.target.value })
              }
            >
              <option value="">{t('jr.no_category')}</option>
              {categories?.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.icon ? `${c.icon} ` : ''}
                  {c.name}
                </option>
              ))}
            </select>
            <input
              className="input"
              placeholder={t('jr.subject_ph')}
              value={form.subject}
              onChange={(e) => setForm({ ...form, subject: e.target.value })}
            />
            <input
              className="input"
              placeholder={t('jr.grade_ph')}
              value={form.gradeLevel}
              onChange={(e) =>
                setForm({ ...form, gradeLevel: e.target.value })
              }
            />
          </div>
          <div className="grid grid-cols-3 gap-3">
            <input
              className="input"
              placeholder={t('jr.author_ph')}
              value={form.author}
              onChange={(e) => setForm({ ...form, author: e.target.value })}
            />
            <select
              className="input"
              value={form.language}
              onChange={(e) =>
                setForm({ ...form, language: e.target.value })
              }
            >
              <option value="kk">Қазақша (kk)</option>
              <option value="ru">Русский (ru)</option>
              <option value="en">English (en)</option>
            </select>
            <input
              className="input"
              placeholder={t('jr.tags_ph')}
              value={form.tagsRaw}
              onChange={(e) => setForm({ ...form, tagsRaw: e.target.value })}
            />
          </div>
          <div className="grid grid-cols-3 gap-3">
            <FileUpload
              kind="image"
              label={t('jr.cover')}
              value={form.coverImage}
              onChange={(url) => setForm({ ...form, coverImage: url })}
            />
            <FileUpload
              kind="pdf"
              label={t('jr.pdf')}
              value={form.pdfUrl}
              onChange={(url) => setForm({ ...form, pdfUrl: url })}
            />
            <FileUpload
              kind="video"
              label={t('jr.trailer')}
              value={form.trailerVideoUrl}
              onChange={(url) =>
                setForm({ ...form, trailerVideoUrl: url })
              }
            />
          </div>
          <div className="flex gap-4">
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.published}
                onChange={(e) =>
                  setForm({ ...form, published: e.target.checked })
                }
              />
              {t('common.published')}
            </label>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.featured}
                onChange={(e) =>
                  setForm({ ...form, featured: e.target.checked })
                }
              />
              {t('common.featured')}
            </label>
          </div>
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
              disabled={!form.title || !form.description}
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
              <th className="px-4 py-2">{t('jr.col.title')}</th>
              <th className="px-4 py-2">{t('jr.col.category')}</th>
              <th className="px-4 py-2">{t('jr.col.pages')}</th>
              <th className="px-4 py-2">{t('jr.col.lang')}</th>
              <th className="px-4 py-2">{t('jr.col.views')}</th>
              <th className="px-4 py-2">{t('common.status')}</th>
              <th className="px-4 py-2 text-right">
                {t('common.actions')}
              </th>
            </tr>
          </thead>
          <tbody>
            {isLoading && (
              <tr>
                <td className="px-4 py-3 text-slate-500" colSpan={7}>
                  {t('common.loading')}
                </td>
              </tr>
            )}
            {data?.map((j) => (
              <tr key={j.id} className="border-t border-slate-100">
                <td className="px-4 py-2">
                  <div className="flex items-start gap-2">
                    {j.coverImage ? (
                      <img
                        src={assetUrl(j.coverImage)}
                        alt=""
                        className="h-12 w-9 shrink-0 rounded border border-slate-200 object-cover"
                      />
                    ) : (
                      <div className="h-12 w-9 shrink-0 rounded border border-dashed border-slate-200 bg-slate-50" />
                    )}
                    <div>
                      <div className="flex items-center gap-1.5">
                        {j.featured && (
                          <span className="badge bg-amber-100 text-amber-700">
                            ★
                          </span>
                        )}
                        <Link
                          className="font-medium text-brand-700 hover:underline"
                          href={`/journals/${j.id}`}
                        >
                          {j.title}
                        </Link>
                        {j.pdfUrl && (
                          <span className="badge bg-rose-50 text-rose-700">
                            PDF
                          </span>
                        )}
                      </div>
                      <div className="line-clamp-1 text-xs text-slate-500">
                        {j.description}
                      </div>
                    </div>
                  </div>
                  {j.tags && j.tags.length > 0 && (
                    <div className="mt-1 flex flex-wrap gap-1">
                      {j.tags.map((t) => (
                        <span
                          key={t}
                          className="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] text-slate-600"
                        >
                          #{t}
                        </span>
                      ))}
                    </div>
                  )}
                </td>
                <td className="px-4 py-2">
                  {j.category ? (
                    <span
                      className="badge"
                      style={{
                        backgroundColor: `${j.category.color ?? '#e2e8f0'}22`,
                        color: j.category.color ?? '#475569',
                      }}
                    >
                      {j.category.icon ? `${j.category.icon} ` : ''}
                      {j.category.name}
                    </span>
                  ) : (
                    <span className="text-slate-400">—</span>
                  )}
                </td>
                <td className="px-4 py-2">
                  <Link
                    href={`/journals/${j.id}`}
                    className="inline-flex items-center gap-1 rounded bg-slate-100 px-2 py-0.5 text-xs text-slate-700 hover:bg-brand-50 hover:text-brand-700"
                  >
                    {j.pagesCount ?? 0} {t('jr.pages_link')} →
                  </Link>
                </td>
                <td className="px-4 py-2 font-mono text-xs text-slate-500">
                  {j.language}
                </td>
                <td className="px-4 py-2 text-slate-600">{j.viewsCount}</td>
                <td className="px-4 py-2">
                  {j.published ? (
                    <span className="badge bg-emerald-100 text-emerald-700">
                      {t('common.published').toLowerCase()}
                    </span>
                  ) : (
                    <span className="badge bg-slate-200 text-slate-700">
                      {t('common.draft').toLowerCase()}
                    </span>
                  )}
                </td>
                <td className="px-4 py-2 text-right">
                  <Link
                    href={`/journals/${j.id}`}
                    className="mr-1 rounded border border-brand-200 bg-brand-50 px-2 py-1 text-xs text-brand-700 hover:bg-brand-100"
                  >
                    {t('common.open')}
                  </Link>
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => openEdit(j)}
                  >
                    {t('common.edit')}
                  </button>
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => toggleFeatured(j)}
                  >
                    {j.featured ? t('jr.unfeature') : t('jr.feature')}
                  </button>
                  <button
                    className="mr-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                    onClick={() => togglePublish(j)}
                  >
                    {j.published ? t('jr.unpublish') : t('jr.publish')}
                  </button>
                  <button
                    className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                    onClick={() => remove(j)}
                  >
                    {t('common.delete')}
                  </button>
                </td>
              </tr>
            ))}
            {data && data.length === 0 && (
              <tr>
                <td className="px-4 py-6 text-center text-slate-500" colSpan={7}>
                  {t('common.empty')}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

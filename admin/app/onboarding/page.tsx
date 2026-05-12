'use client';

import { useEffect, useState } from 'react';

import { api, ApiError } from '../../lib/api';

interface Slide {
  id: string;
  position: number;
  iconSvg?: string;
  titleKk: string;
  titleRu?: string;
  titleEn?: string;
  descriptionKk: string;
  descriptionRu?: string;
  descriptionEn?: string;
  published: boolean;
  createdAt: string;
  updatedAt: string;
}

interface SlideForm {
  position: number;
  iconSvg: string;
  titleKk: string;
  titleRu: string;
  titleEn: string;
  descriptionKk: string;
  descriptionRu: string;
  descriptionEn: string;
  published: boolean;
}

const emptyForm: SlideForm = {
  position: 0,
  iconSvg: '',
  titleKk: '',
  titleRu: '',
  titleEn: '',
  descriptionKk: '',
  descriptionRu: '',
  descriptionEn: '',
  published: true,
};

export default function OnboardingAdminPage() {
  const [slides, setSlides] = useState<Slide[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<SlideForm>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [showForm, setShowForm] = useState(false);

  async function load() {
    setLoading(true);
    setError(null);
    try {
      const data = await api<Slide[]>('/admin/onboarding');
      setSlides(data.sort((a, b) => a.position - b.position));
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  function startEdit(s: Slide) {
    setEditingId(s.id);
    setForm({
      position: s.position,
      iconSvg: s.iconSvg ?? '',
      titleKk: s.titleKk,
      titleRu: s.titleRu ?? '',
      titleEn: s.titleEn ?? '',
      descriptionKk: s.descriptionKk,
      descriptionRu: s.descriptionRu ?? '',
      descriptionEn: s.descriptionEn ?? '',
      published: s.published,
    });
    setShowForm(true);
  }

  function startCreate() {
    setEditingId(null);
    setForm({ ...emptyForm, position: slides.length });
    setShowForm(true);
  }

  function cancel() {
    setShowForm(false);
    setEditingId(null);
    setForm(emptyForm);
  }

  async function onSvgFile(file: File) {
    const text = await file.text();
    setForm((f) => ({ ...f, iconSvg: text }));
  }

  async function save() {
    setSaving(true);
    setError(null);
    try {
      const payload = {
        position: Number(form.position),
        iconSvg: form.iconSvg || undefined,
        titleKk: form.titleKk,
        titleRu: form.titleRu || undefined,
        titleEn: form.titleEn || undefined,
        descriptionKk: form.descriptionKk,
        descriptionRu: form.descriptionRu || undefined,
        descriptionEn: form.descriptionEn || undefined,
        published: form.published,
      };
      if (editingId) {
        await api(`/admin/onboarding/${editingId}`, {
          method: 'PUT',
          body: JSON.stringify(payload),
        });
      } else {
        await api('/admin/onboarding', {
          method: 'POST',
          body: JSON.stringify(payload),
        });
      }
      cancel();
      await load();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
    } finally {
      setSaving(false);
    }
  }

  async function remove(id: string) {
    if (!confirm('Жоюға сенімдісіз бе?')) return;
    try {
      await api(`/admin/onboarding/${id}`, { method: 'DELETE' });
      await load();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
    }
  }

  return (
    <div className="p-6">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Onboarding слайдтары</h1>
          <p className="text-sm text-slate-500">
            Мобильді қосымшадағы алғашқы экрандар. Реті — position өрісі бойынша.
          </p>
        </div>
        <button
          onClick={startCreate}
          className="rounded-md bg-brand-600 px-4 py-2 text-sm font-medium text-white hover:bg-brand-700"
        >
          + Жаңа слайд
        </button>
      </div>

      {error && (
        <div className="mb-4 rounded border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
          {error}
        </div>
      )}

      {showForm && (
        <div className="mb-6 rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold">
            {editingId ? 'Слайдты өзгерту' : 'Жаңа слайд'}
          </h2>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <div>
              <label className="mb-1 block text-xs font-medium text-slate-600">
                Position
              </label>
              <input
                type="number"
                value={form.position}
                onChange={(e) =>
                  setForm((f) => ({ ...f, position: Number(e.target.value) }))
                }
                className="w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
              />
            </div>
            <div className="md:col-span-2">
              <label className="mb-1 block text-xs font-medium text-slate-600">
                Published
              </label>
              <select
                value={form.published ? '1' : '0'}
                onChange={(e) =>
                  setForm((f) => ({ ...f, published: e.target.value === '1' }))
                }
                className="w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
              >
                <option value="1">Жарияланған</option>
                <option value="0">Жасырын</option>
              </select>
            </div>

            <div className="md:col-span-3">
              <label className="mb-1 block text-xs font-medium text-slate-600">
                Icon (SVG) — файл жүктеу немесе мәтінге қою
              </label>
              <input
                type="file"
                accept=".svg,image/svg+xml"
                onChange={(e) => {
                  const f = e.target.files?.[0];
                  if (f) void onSvgFile(f);
                }}
                className="mb-2 block text-sm"
              />
              <textarea
                value={form.iconSvg}
                onChange={(e) =>
                  setForm((f) => ({ ...f, iconSvg: e.target.value }))
                }
                rows={4}
                placeholder="<svg xmlns='...' viewBox='0 0 64 64'>...</svg>"
                className="w-full rounded border border-slate-300 px-2 py-1.5 font-mono text-xs"
              />
              {form.iconSvg && (
                <div className="mt-2 flex items-center gap-3">
                  <span className="text-xs text-slate-500">Preview:</span>
                  <div
                    className="h-12 w-12 text-brand-700"
                    dangerouslySetInnerHTML={{ __html: form.iconSvg }}
                  />
                </div>
              )}
            </div>

            <Field
              label="Title (KK)"
              value={form.titleKk}
              onChange={(v) => setForm((f) => ({ ...f, titleKk: v }))}
            />
            <Field
              label="Title (RU)"
              value={form.titleRu}
              onChange={(v) => setForm((f) => ({ ...f, titleRu: v }))}
            />
            <Field
              label="Title (EN)"
              value={form.titleEn}
              onChange={(v) => setForm((f) => ({ ...f, titleEn: v }))}
            />
            <TextField
              label="Description (KK)"
              value={form.descriptionKk}
              onChange={(v) => setForm((f) => ({ ...f, descriptionKk: v }))}
            />
            <TextField
              label="Description (RU)"
              value={form.descriptionRu}
              onChange={(v) => setForm((f) => ({ ...f, descriptionRu: v }))}
            />
            <TextField
              label="Description (EN)"
              value={form.descriptionEn}
              onChange={(v) => setForm((f) => ({ ...f, descriptionEn: v }))}
            />
          </div>

          <div className="mt-5 flex justify-end gap-2">
            <button
              onClick={cancel}
              className="rounded border border-slate-300 px-3 py-1.5 text-sm hover:bg-slate-50"
            >
              Болдырмау
            </button>
            <button
              onClick={save}
              disabled={saving || !form.titleKk || !form.descriptionKk}
              className="rounded bg-brand-600 px-4 py-1.5 text-sm font-medium text-white hover:bg-brand-700 disabled:opacity-50"
            >
              {saving ? 'Сақталуда…' : 'Сақтау'}
            </button>
          </div>
        </div>
      )}

      {loading ? (
        <div className="text-sm text-slate-500">Жүктелуде…</div>
      ) : (
        <div className="grid gap-4">
          {slides.map((s) => (
            <div
              key={s.id}
              className="flex items-start gap-4 rounded-lg border border-slate-200 bg-white p-4"
            >
              <div className="flex h-16 w-16 flex-shrink-0 items-center justify-center rounded bg-slate-50 text-brand-700">
                {s.iconSvg ? (
                  <div
                    className="h-12 w-12"
                    dangerouslySetInnerHTML={{ __html: s.iconSvg }}
                  />
                ) : (
                  <span className="text-2xl">○</span>
                )}
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 text-xs text-slate-500">
                  <span>#{s.position}</span>
                  {!s.published && (
                    <span className="rounded bg-slate-200 px-1.5 text-slate-700">
                      жасырын
                    </span>
                  )}
                </div>
                <div className="mt-0.5 font-semibold">{s.titleKk}</div>
                <div className="text-sm text-slate-600">{s.descriptionKk}</div>
                <div className="mt-1 text-xs text-slate-400">
                  {s.titleRu && `RU: ${s.titleRu} · `}
                  {s.titleEn && `EN: ${s.titleEn}`}
                </div>
              </div>
              <div className="flex flex-col gap-1">
                <button
                  onClick={() => startEdit(s)}
                  className="rounded border border-slate-300 px-3 py-1 text-xs hover:bg-slate-50"
                >
                  Өзгерту
                </button>
                <button
                  onClick={() => remove(s.id)}
                  className="rounded border border-red-300 px-3 py-1 text-xs text-red-700 hover:bg-red-50"
                >
                  Жою
                </button>
              </div>
            </div>
          ))}
          {slides.length === 0 && (
            <div className="rounded border border-dashed border-slate-300 p-8 text-center text-sm text-slate-500">
              Слайд жоқ. «Жаңа слайд» басып қосыңыз.
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="mb-1 block text-xs font-medium text-slate-600">{label}</label>
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
      />
    </div>
  );
}

function TextField({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="mb-1 block text-xs font-medium text-slate-600">{label}</label>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={3}
        className="w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
      />
    </div>
  );
}

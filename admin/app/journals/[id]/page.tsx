'use client';

import Link from 'next/link';
import { use, useState } from 'react';
import useSWR from 'swr';

import { FileUpload } from '../../../components/FileUpload';
import { api, assetUrl, fetcher } from '../../../lib/api';
import { useI18n } from '../../../lib/i18n';

interface ArAsset {
  id: string;
  triggerMarker: string;
  modelUrl: string;
  audioUrl?: string;
  animationSet?: string;
}

interface Page {
  id: string;
  pageNumber: number;
  title?: string;
  imageUrl?: string;
  audioUrl?: string;
  videoUrl?: string;
  text?: string;
  arAssets: ArAsset[];
}

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
  slug?: string;
  author?: string;
  language: string;
  tags?: string[];
  featured: boolean;
  published: boolean;
  viewsCount: number;
  coverImage?: string;
  pdfUrl?: string;
  trailerVideoUrl?: string;
  category?: Category;
  pages: Page[];
}

export default function JournalDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { t } = useI18n();
  const { id } = use(params);
  const { data, mutate, isLoading } = useSWR<Journal>(
    `/admin/journals/${id}`,
    fetcher,
  );

  const [addingPage, setAddingPage] = useState(false);
  const [pageForm, setPageForm] = useState({
    pageNumber: 1,
    title: '',
    imageUrl: '',
    audioUrl: '',
    videoUrl: '',
    text: '',
  });

  async function addPage() {
    await api(`/admin/journals/${id}/pages`, {
      method: 'POST',
      body: JSON.stringify({
        pageNumber: pageForm.pageNumber,
        title: pageForm.title || undefined,
        imageUrl: pageForm.imageUrl || undefined,
        audioUrl: pageForm.audioUrl || undefined,
        videoUrl: pageForm.videoUrl || undefined,
        text: pageForm.text || undefined,
      }),
    });
    setAddingPage(false);
    setPageForm({
      pageNumber: (data?.pages.length ?? 0) + 1,
      title: '',
      imageUrl: '',
      audioUrl: '',
      videoUrl: '',
      text: '',
    });
    mutate();
  }

  async function deletePage(pageId: string) {
    if (!confirm(t('jrd.confirm_delete_page'))) return;
    await api(`/admin/journals/pages/${pageId}`, { method: 'DELETE' });
    mutate();
  }

  const [assetFor, setAssetFor] = useState<string | null>(null);
  const [assetForm, setAssetForm] = useState({
    triggerMarker: '',
    modelUrl: '',
    audioUrl: '',
    animationSet: '',
  });

  const DEFAULT_AR_MODEL_URL = '/uploads/models-library/solarsystem.glb';

  function openAddAsset(pageId: string) {
    setAssetFor(pageId);
    setAssetForm({
      triggerMarker: '',
      modelUrl: DEFAULT_AR_MODEL_URL,
      audioUrl: '',
      animationSet: '',
    });
  }

  async function submitAsset() {
    if (!assetFor) return;
    await api(`/admin/journals/pages/${assetFor}/assets`, {
      method: 'POST',
      body: JSON.stringify({
        triggerMarker: assetForm.triggerMarker,
        modelUrl: assetForm.modelUrl,
        audioUrl: assetForm.audioUrl || undefined,
        animationSet: assetForm.animationSet || undefined,
      }),
    });
    setAssetFor(null);
    mutate();
  }

  async function deleteAsset(assetId: string) {
    if (!confirm(t('jrd.confirm_delete_asset'))) return;
    await api(`/admin/journals/assets/${assetId}`, { method: 'DELETE' });
    mutate();
  }

  return (
    <div>
      <Link
        href="/journals"
        className="text-sm text-brand-700 hover:underline"
      >
        {t('jrd.back')}
      </Link>

      {isLoading && (
        <div className="mt-4 text-slate-500">{t('common.loading')}</div>
      )}

      {data && (
        <>
          <h1 className="mt-2 text-2xl font-bold text-slate-900">
            {data.title}
            {data.featured && (
              <span className="ml-2 align-middle text-amber-500">★</span>
            )}
          </h1>
          <p className="text-sm text-slate-500">{data.description}</p>
          <div className="mt-3 flex flex-wrap gap-2 text-xs text-slate-600">
            {data.category && (
              <span
                className="rounded px-2 py-0.5"
                style={{
                  backgroundColor: `${data.category.color ?? '#e2e8f0'}22`,
                  color: data.category.color ?? '#475569',
                }}
              >
                {data.category.icon ? `${data.category.icon} ` : ''}
                {data.category.name}
              </span>
            )}
            {data.author && (
              <span className="rounded bg-slate-100 px-2 py-0.5">
                ✎ {data.author}
              </span>
            )}
            <span className="rounded bg-slate-100 px-2 py-0.5 font-mono">
              {data.language}
            </span>
            <span className="rounded bg-slate-100 px-2 py-0.5">
              👁 {data.viewsCount}
            </span>
            {data.slug && (
              <span className="rounded bg-slate-100 px-2 py-0.5 font-mono">
                /{data.slug}
              </span>
            )}
            {(data.tags ?? []).map((t) => (
              <span
                key={t}
                className="rounded bg-slate-100 px-2 py-0.5"
              >
                #{t}
              </span>
            ))}
          </div>

          {(data.coverImage || data.pdfUrl || data.trailerVideoUrl) && (
            <div className="mt-4 grid gap-3 md:grid-cols-3">
              {data.coverImage && (
                <div className="card p-2">
                  <div className="mb-1 text-[10px] uppercase text-slate-400">
                    {t('jrd.cover')}
                  </div>
                  <img
                    src={assetUrl(data.coverImage)}
                    alt="cover"
                    className="max-h-48 w-full rounded object-contain"
                  />
                </div>
              )}
              {data.trailerVideoUrl && (
                <div className="card p-2">
                  <div className="mb-1 text-[10px] uppercase text-slate-400">
                    {t('jrd.trailer')}
                  </div>
                  <video
                    src={assetUrl(data.trailerVideoUrl)}
                    controls
                    className="max-h-48 w-full rounded"
                  />
                </div>
              )}
              {data.pdfUrl && (
                <div className="card p-2 md:col-span-1">
                  <div className="mb-1 flex items-center justify-between">
                    <span className="text-[10px] uppercase text-slate-400">
                      {t('jrd.pdf_preview')}
                    </span>
                    <a
                      href={assetUrl(data.pdfUrl)}
                      target="_blank"
                      rel="noreferrer"
                      className="text-xs text-brand-700 hover:underline"
                    >
                      {t('jrd.pdf_open')}
                    </a>
                  </div>
                  <iframe
                    src={assetUrl(data.pdfUrl)}
                    title="journal-pdf"
                    className="h-48 w-full rounded border border-slate-200"
                  />
                </div>
              )}
            </div>
          )}

          <div className="mt-6 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-slate-800">
              {t('jrd.pages_count')} ({data.pages.length})
            </h2>
            <button
              className="btn-primary"
              onClick={() => {
                setAddingPage((v) => !v);
                setPageForm({
                  pageNumber: data.pages.length + 1,
                  title: '',
                  imageUrl: '',
                  audioUrl: '',
                  videoUrl: '',
                  text: '',
                });
              }}
            >
              {addingPage ? t('common.cancel') : t('jrd.add_page')}
            </button>
          </div>

          {addingPage && (
            <div className="card mt-3 space-y-3 p-4">
              <div className="grid grid-cols-3 gap-3">
                <input
                  className="input"
                  type="number"
                  placeholder={t('jrd.page_num_ph')}
                  value={pageForm.pageNumber}
                  onChange={(e) =>
                    setPageForm({
                      ...pageForm,
                      pageNumber: parseInt(e.target.value, 10) || 1,
                    })
                  }
                />
                <input
                  className="input col-span-2"
                  placeholder={t('jrd.page_title_ph')}
                  value={pageForm.title}
                  onChange={(e) =>
                    setPageForm({ ...pageForm, title: e.target.value })
                  }
                />
              </div>
              <div className="grid grid-cols-3 gap-3">
                <FileUpload
                  kind="image"
                  label={t('jrd.page_image')}
                  value={pageForm.imageUrl}
                  onChange={(url) =>
                    setPageForm({ ...pageForm, imageUrl: url })
                  }
                />
                <FileUpload
                  kind="audio"
                  label={t('jrd.page_audio')}
                  value={pageForm.audioUrl}
                  onChange={(url) =>
                    setPageForm({ ...pageForm, audioUrl: url })
                  }
                />
                <FileUpload
                  kind="video"
                  label={t('jrd.page_video')}
                  value={pageForm.videoUrl}
                  onChange={(url) =>
                    setPageForm({ ...pageForm, videoUrl: url })
                  }
                />
              </div>
              <textarea
                className="input"
                placeholder={t('jrd.page_text_ph')}
                rows={3}
                value={pageForm.text}
                onChange={(e) =>
                  setPageForm({ ...pageForm, text: e.target.value })
                }
              />
              <div className="flex justify-end">
                <button className="btn-primary" onClick={addPage}>
                  {t('jrd.create_page')}
                </button>
              </div>
            </div>
          )}

          <div className="mt-4 space-y-3">
            {data.pages.map((p) => (
              <div key={p.id} className="card p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="text-xs uppercase text-slate-500">
                      Page {p.pageNumber}
                    </div>
                    {p.title && (
                      <div className="mt-0.5 text-base font-medium text-slate-800">
                        {p.title}
                      </div>
                    )}
                    {p.text && (
                      <p className="mt-2 text-sm text-slate-700">{p.text}</p>
                    )}
                    <div className="mt-3 grid gap-3 md:grid-cols-3">
                      {p.imageUrl && (
                        <div>
                          <div className="text-[10px] uppercase text-slate-400">
                            {t('jrd.page_image')}
                          </div>
                          <img
                            src={assetUrl(p.imageUrl)}
                            alt=""
                            className="mt-1 max-h-32 rounded border border-slate-200 object-contain"
                          />
                        </div>
                      )}
                      {p.audioUrl && (
                        <div>
                          <div className="text-[10px] uppercase text-slate-400">
                            {t('jrd.page_audio')}
                          </div>
                          <audio
                            src={assetUrl(p.audioUrl)}
                            controls
                            className="mt-1 w-full"
                          />
                        </div>
                      )}
                      {p.videoUrl && (
                        <div>
                          <div className="text-[10px] uppercase text-slate-400">
                            {t('jrd.page_video')}
                          </div>
                          <video
                            src={assetUrl(p.videoUrl)}
                            controls
                            className="mt-1 max-h-32 w-full rounded"
                          />
                        </div>
                      )}
                    </div>
                  </div>
                  <div className="flex shrink-0 flex-col gap-2">
                    <button
                      className="rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                      onClick={() => openAddAsset(p.id)}
                    >
                      {t('jrd.ar_add_btn')}
                    </button>
                    <button
                      className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                      onClick={() => deletePage(p.id)}
                    >
                      {t('common.delete')}
                    </button>
                  </div>
                </div>

                {assetFor === p.id && (
                  <div className="mt-3 space-y-2 rounded-md border border-slate-200 bg-slate-50 p-3">
                    <div className="text-xs font-semibold uppercase text-slate-500">
                      {t('jrd.ar_new')}
                    </div>
                    <input
                      className="input"
                      placeholder={t('jrd.ar_marker_ph')}
                      value={assetForm.triggerMarker}
                      onChange={(e) =>
                        setAssetForm({
                          ...assetForm,
                          triggerMarker: e.target.value,
                        })
                      }
                    />
                    <FileUpload
                      kind="model"
                      label={t('jrd.ar_model')}
                      library="models"
                      value={assetForm.modelUrl}
                      onChange={(url) =>
                        setAssetForm({ ...assetForm, modelUrl: url })
                      }
                    />
                    <FileUpload
                      kind="audio"
                      label={t('jrd.ar_audio')}
                      value={assetForm.audioUrl}
                      onChange={(url) =>
                        setAssetForm({ ...assetForm, audioUrl: url })
                      }
                    />
                    <input
                      className="input"
                      placeholder={t('jrd.ar_anim_ph')}
                      value={assetForm.animationSet}
                      onChange={(e) =>
                        setAssetForm({
                          ...assetForm,
                          animationSet: e.target.value,
                        })
                      }
                    />
                    <div className="flex justify-end gap-2">
                      <button
                        className="btn-secondary"
                        onClick={() => setAssetFor(null)}
                      >
                        {t('common.cancel')}
                      </button>
                      <button
                        className="btn-primary"
                        disabled={
                          !assetForm.triggerMarker || !assetForm.modelUrl
                        }
                        onClick={submitAsset}
                      >
                        {t('jrd.ar_add')}
                      </button>
                    </div>
                  </div>
                )}

                {p.arAssets.length > 0 && (
                  <div className="mt-3 rounded-md border border-slate-100 bg-slate-50 p-3">
                    <div className="mb-2 text-xs font-semibold uppercase text-slate-500">
                      {t('jrd.ar_assets')} ({p.arAssets.length})
                    </div>
                    <ul className="space-y-1 text-sm">
                      {p.arAssets.map((a) => (
                        <li
                          key={a.id}
                          className="flex items-center justify-between rounded bg-white px-2 py-1.5"
                        >
                          <div>
                            <span className="badge bg-brand-50 text-brand-700">
                              {a.triggerMarker}
                            </span>
                            <span className="ml-2 font-mono text-xs text-slate-600">
                              {a.modelUrl}
                            </span>
                            {a.audioUrl && (
                              <span className="ml-2 text-xs text-slate-500">
                                🔊 {a.audioUrl}
                              </span>
                            )}
                          </div>
                          <button
                            className="rounded border border-red-200 px-2 py-0.5 text-xs text-red-700 hover:bg-red-50"
                            onClick={() => deleteAsset(a.id)}
                          >
                            {t('common.delete')}
                          </button>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            ))}

            {data.pages.length === 0 && (
              <div className="card p-6 text-center text-slate-500">
                {t('jrd.no_pages')}
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

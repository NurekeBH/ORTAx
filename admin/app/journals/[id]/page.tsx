'use client';

import Link from 'next/link';
import { use, useState } from 'react';
import useSWR from 'swr';

import { api, fetcher } from '../../../lib/api';

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
  imageUrl?: string;
  text?: string;
  arAssets: ArAsset[];
}

interface Journal {
  id: string;
  title: string;
  description: string;
  pages: Page[];
}

export default function JournalDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { data, mutate, isLoading } = useSWR<Journal>(
    `/admin/journals/${id}`,
    fetcher,
  );

  const [addingPage, setAddingPage] = useState(false);
  const [pageForm, setPageForm] = useState({
    pageNumber: 1,
    imageUrl: '',
    text: '',
  });

  async function addPage() {
    await api(`/admin/journals/${id}/pages`, {
      method: 'POST',
      body: JSON.stringify({
        pageNumber: pageForm.pageNumber,
        imageUrl: pageForm.imageUrl || undefined,
        text: pageForm.text || undefined,
      }),
    });
    setAddingPage(false);
    setPageForm({ pageNumber: (data?.pages.length ?? 0) + 1, imageUrl: '', text: '' });
    mutate();
  }

  async function deletePage(pageId: string) {
    if (!confirm('Бұл бетті жоюды растайсыз ба?')) return;
    await api(`/admin/journals/pages/${pageId}`, { method: 'DELETE' });
    mutate();
  }

  async function addAsset(pageId: string) {
    const triggerMarker = prompt('Trigger marker (e.g. "p1-marker"):');
    if (!triggerMarker) return;
    const modelUrl = prompt('Model URL (.glb):');
    if (!modelUrl) return;
    const audioUrl = prompt('Audio URL (optional):') || undefined;
    await api(`/admin/journals/pages/${pageId}/assets`, {
      method: 'POST',
      body: JSON.stringify({ triggerMarker, modelUrl, audioUrl }),
    });
    mutate();
  }

  async function deleteAsset(assetId: string) {
    if (!confirm('AR ассетті жоюды растайсыз ба?')) return;
    await api(`/admin/journals/assets/${assetId}`, { method: 'DELETE' });
    mutate();
  }

  return (
    <div>
      <Link
        href="/journals"
        className="text-sm text-brand-700 hover:underline"
      >
        ← All journals
      </Link>

      {isLoading && <div className="mt-4 text-slate-500">Loading…</div>}

      {data && (
        <>
          <h1 className="mt-2 text-2xl font-bold text-slate-900">
            {data.title}
          </h1>
          <p className="text-sm text-slate-500">{data.description}</p>

          <div className="mt-6 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-slate-800">
              Pages ({data.pages.length})
            </h2>
            <button
              className="btn-primary"
              onClick={() => {
                setAddingPage((v) => !v);
                setPageForm({
                  pageNumber: data.pages.length + 1,
                  imageUrl: '',
                  text: '',
                });
              }}
            >
              {addingPage ? 'Cancel' : '+ Add page'}
            </button>
          </div>

          {addingPage && (
            <div className="card mt-3 space-y-3 p-4">
              <div className="grid grid-cols-2 gap-3">
                <input
                  className="input"
                  type="number"
                  placeholder="Page number"
                  value={pageForm.pageNumber}
                  onChange={(e) =>
                    setPageForm({
                      ...pageForm,
                      pageNumber: parseInt(e.target.value, 10) || 1,
                    })
                  }
                />
                <input
                  className="input"
                  placeholder="Image URL"
                  value={pageForm.imageUrl}
                  onChange={(e) =>
                    setPageForm({ ...pageForm, imageUrl: e.target.value })
                  }
                />
              </div>
              <textarea
                className="input"
                placeholder="Text"
                rows={3}
                value={pageForm.text}
                onChange={(e) =>
                  setPageForm({ ...pageForm, text: e.target.value })
                }
              />
              <div className="flex justify-end">
                <button className="btn-primary" onClick={addPage}>
                  Create page
                </button>
              </div>
            </div>
          )}

          <div className="mt-4 space-y-3">
            {data.pages.map((p) => (
              <div key={p.id} className="card p-4">
                <div className="flex items-start justify-between">
                  <div>
                    <div className="text-xs uppercase text-slate-500">
                      Page {p.pageNumber}
                    </div>
                    {p.imageUrl && (
                      <div className="mt-1 font-mono text-xs text-slate-600">
                        {p.imageUrl}
                      </div>
                    )}
                    {p.text && (
                      <p className="mt-2 text-sm text-slate-700">{p.text}</p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button
                      className="rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50"
                      onClick={() => addAsset(p.id)}
                    >
                      + AR asset
                    </button>
                    <button
                      className="rounded border border-red-200 px-2 py-1 text-xs text-red-700 hover:bg-red-50"
                      onClick={() => deletePage(p.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>

                {p.arAssets.length > 0 && (
                  <div className="mt-3 rounded-md border border-slate-100 bg-slate-50 p-3">
                    <div className="mb-2 text-xs font-semibold uppercase text-slate-500">
                      AR Assets ({p.arAssets.length})
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
                            Delete
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
                Бет жоқ. Жаңа бет қосыңыз.
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

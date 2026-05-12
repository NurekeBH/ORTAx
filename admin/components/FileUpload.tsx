'use client';

import { useEffect, useId, useRef, useState } from 'react';

import {
  ApiError,
  UploadKind,
  api,
  assetUrl,
  uploadFile,
} from '../lib/api';

interface Props {
  kind: UploadKind;
  value?: string;
  onChange: (url: string) => void;
  label?: string;
  placeholder?: string;
  accept?: string;
  preview?: 'image' | 'audio' | 'video' | 'pdf' | 'model' | 'none';
  className?: string;
  /** Show "Library" dropdown with prebundled assets (models/images/audio). */
  library?: 'models' | 'images' | 'audio';
}

interface LibraryItem {
  name: string;
  url: string;
  size: number;
}

const DEFAULT_ACCEPT: Record<UploadKind, string> = {
  image: 'image/*',
  audio: 'audio/*',
  video: 'video/*',
  model: '.glb,.gltf,.usdz,model/*',
  pdf: 'application/pdf,.pdf',
  file: '*/*',
};

const DEFAULT_PREVIEW: Record<UploadKind, Props['preview']> = {
  image: 'image',
  audio: 'audio',
  video: 'video',
  model: 'model',
  pdf: 'pdf',
  file: 'none',
};

export function FileUpload({
  kind,
  value,
  onChange,
  label,
  placeholder,
  accept,
  preview,
  className,
  library,
}: Props) {
  const inputId = useId();
  const fileRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [libraryItems, setLibraryItems] = useState<LibraryItem[]>([]);

  const previewKind = preview ?? DEFAULT_PREVIEW[kind];

  useEffect(() => {
    if (!library) return;
    let cancelled = false;
    api<{ items: LibraryItem[] }>(`/admin/library/${library}`)
      .then((res) => {
        if (!cancelled) setLibraryItems(res.items ?? []);
      })
      .catch(() => undefined);
    return () => {
      cancelled = true;
    };
  }, [library]);

  async function onPick(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    setError(null);
    try {
      const res = await uploadFile(kind, file);
      onChange(res.url);
    } catch (err) {
      const msg =
        err instanceof ApiError
          ? (() => {
              try {
                const parsed = JSON.parse(err.message);
                return parsed.message ?? err.message;
              } catch {
                return err.message;
              }
            })()
          : err instanceof Error
            ? err.message
            : 'Upload failed';
      setError(typeof msg === 'string' ? msg : JSON.stringify(msg));
    } finally {
      setUploading(false);
      if (fileRef.current) fileRef.current.value = '';
    }
  }

  return (
    <div className={className}>
      {label && (
        <label className="mb-1 block text-xs font-medium text-slate-600">
          {label}
        </label>
      )}
      <div className="flex gap-2">
        <input
          className="input flex-1 font-mono text-xs"
          placeholder={placeholder ?? '/uploads/... or https://...'}
          value={value ?? ''}
          onChange={(e) => onChange(e.target.value)}
        />
        <button
          type="button"
          className="btn-secondary whitespace-nowrap"
          onClick={() => fileRef.current?.click()}
          disabled={uploading}
        >
          {uploading ? 'Uploading…' : 'Upload'}
        </button>
        {value && (
          <button
            type="button"
            className="btn-secondary"
            onClick={() => onChange('')}
            title="Clear"
          >
            ×
          </button>
        )}
      </div>
      <input
        ref={fileRef}
        id={inputId}
        type="file"
        className="hidden"
        accept={accept ?? DEFAULT_ACCEPT[kind]}
        onChange={onPick}
      />
      {library && libraryItems.length > 0 && (
        <div className="mt-1">
          <select
            className="input text-xs"
            value={
              libraryItems.find((it) => it.url === value)?.url ?? ''
            }
            onChange={(e) => {
              if (e.target.value) onChange(e.target.value);
            }}
          >
            <option value="">— Pick from library —</option>
            {libraryItems.map((it) => (
              <option key={it.url} value={it.url}>
                📦 {it.name} ({(it.size / 1024 / 1024).toFixed(1)}MB)
              </option>
            ))}
          </select>
        </div>
      )}
      {error && (
        <div className="mt-1 text-xs text-red-600">{error}</div>
      )}
      {value && previewKind && previewKind !== 'none' && (
        <div className="mt-2 rounded border border-slate-200 bg-slate-50 p-2">
          {previewKind === 'image' && (
            <img
              src={assetUrl(value)}
              alt="preview"
              className="max-h-40 rounded object-contain"
            />
          )}
          {previewKind === 'audio' && (
            <audio
              src={assetUrl(value)}
              controls
              className="w-full"
            />
          )}
          {previewKind === 'video' && (
            <video
              src={assetUrl(value)}
              controls
              className="max-h-48 w-full rounded"
            />
          )}
          {previewKind === 'pdf' && (
            <a
              href={assetUrl(value)}
              target="_blank"
              rel="noreferrer"
              className="text-xs text-brand-700 underline"
            >
              📄 Open PDF in new tab
            </a>
          )}
          {previewKind === 'model' && (
            <a
              href={assetUrl(value)}
              target="_blank"
              rel="noreferrer"
              className="text-xs text-brand-700 underline"
            >
              🧊 Download 3D model
            </a>
          )}
        </div>
      )}
    </div>
  );
}

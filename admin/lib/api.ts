export const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE ?? 'http://localhost:3000/api';

export const STATIC_BASE = API_BASE.replace(/\/api\/?$/, '');

export function assetUrl(path?: string | null): string {
  if (!path) return '';
  if (/^https?:\/\//.test(path)) return path;
  if (path.startsWith('/')) return `${STATIC_BASE}${path}`;
  return `${STATIC_BASE}/${path}`;
}

export type UploadKind = 'image' | 'audio' | 'video' | 'model' | 'pdf' | 'file';

export interface UploadResult {
  url: string;
  filename: string;
  originalName: string;
  size: number;
  mimeType: string;
  kind: UploadKind;
}

export async function uploadFile(
  kind: UploadKind,
  file: File,
): Promise<UploadResult> {
  const token = getToken();
  const form = new FormData();
  form.append('file', file);
  const res = await fetch(`${API_BASE}/admin/uploads/${kind}`, {
    method: 'POST',
    body: form,
    headers: token ? { Authorization: `Bearer ${token}` } : undefined,
  });
  if (res.status === 401 || res.status === 403) {
    if (typeof window !== 'undefined') {
      clearAuth();
      window.location.href = '/login';
    }
    throw new ApiError(res.status, 'Unauthorized');
  }
  if (!res.ok) {
    let detail = '';
    try {
      detail = await res.text();
    } catch {
      // ignore
    }
    throw new ApiError(res.status, detail || `Upload failed: ${res.status}`);
  }
  return (await res.json()) as UploadResult;
}

const TOKEN_KEY = 'ortax-admin-token';
const USER_KEY = 'ortax-admin-user';

export interface AdminUser {
  id: string;
  phone: string;
  role: string;
  displayName?: string;
}

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem(TOKEN_KEY, token);
}

export function getStoredUser(): AdminUser | null {
  if (typeof window === 'undefined') return null;
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as AdminUser;
  } catch {
    return null;
  }
}

export function setStoredUser(user: AdminUser): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearAuth(): void {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
  }
}

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const token = getToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...((init?.headers as Record<string, string>) ?? {}),
  };
  if (token) headers.Authorization = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers,
    cache: 'no-store',
  });
  if (res.status === 401 || res.status === 403) {
    if (typeof window !== 'undefined') {
      clearAuth();
      if (!window.location.pathname.startsWith('/login')) {
        window.location.href = '/login';
      }
    }
    throw new ApiError(res.status, 'Unauthorized');
  }
  if (!res.ok) {
    const text = await res.text();
    throw new ApiError(res.status, `API ${path} failed: ${res.status} ${text}`);
  }
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

export const fetcher = <T>(path: string) => api<T>(path);

export async function login(
  phone: string,
  password: string,
): Promise<{ accessToken: string; user: AdminUser }> {
  const res = await fetch(`${API_BASE}/auth/admin/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone, password }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new ApiError(res.status, text || 'Login failed');
  }
  return (await res.json()) as { accessToken: string; user: AdminUser };
}

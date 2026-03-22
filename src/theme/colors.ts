export const colors = {
  primary: '#4F46E5',
  primaryDark: '#4338CA',
  secondary: '#22C55E',
  accent: '#F59E0B',
  background: '#F8FAFC',
  text: '#0F172A',
  textSecondary: '#64748B',
  border: '#E2E8F0',
  white: '#FFFFFF',
  error: '#EF4444',
  success: '#22C55E',
} as const;

export type ColorName = keyof typeof colors;

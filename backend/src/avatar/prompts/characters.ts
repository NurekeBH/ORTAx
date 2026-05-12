import { YASSAWI_GREETING, YASSAWI_SYSTEM_PROMPT } from './yassawi.prompt';
import { KHWARIZMI_GREETING, KHWARIZMI_SYSTEM_PROMPT } from './khwarizmi.prompt';

export type CharacterId = 'yassawi' | 'khwarizmi';

export interface CharacterDefinition {
  id: CharacterId;
  displayName: string;
  systemPrompt: string;
  greeting: string;
  helpText: string;
  /** ISO-639-1 language hint for STT and replies. Undefined = auto-detect. */
  language?: string;
  /** Default portrait URL shipped with the codebase. Admin can override per-character via `AvatarOverride`. */
  defaultImageUrl?: string;
}

export const CHARACTERS: Record<CharacterId, CharacterDefinition> = {
  yassawi: {
    id: 'yassawi',
    displayName: 'Қожа Ахмет Яссауи',
    systemPrompt: YASSAWI_SYSTEM_PROMPT,
    greeting: YASSAWI_GREETING,
    helpText: 'ORTAx — Қожа Ахмет Яссауи AI-аватары.',
    defaultImageUrl: '/uploads/defaults/yassawi.png',
  },
  khwarizmi: {
    id: 'khwarizmi',
    displayName: 'Әл-Хорезми',
    systemPrompt: KHWARIZMI_SYSTEM_PROMPT,
    greeting: KHWARIZMI_GREETING,
    helpText: 'ORTAx — Әл-Хорезми AI-аватары (математика, алгебра, астрономия). Тек қазақ тілінде.',
    language: 'kk',
    defaultImageUrl: '/uploads/defaults/khwarizmi.png',
  },
};

export function isCharacterId(value: string): value is CharacterId {
  return value === 'yassawi' || value === 'khwarizmi';
}

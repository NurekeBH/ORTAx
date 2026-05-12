import { Logger } from '@nestjs/common';
import { Repository } from 'typeorm';

import { OnboardingSlide } from './onboarding-slide.entity';

const AR_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M32 8 L56 20 L56 44 L32 56 L8 44 L8 20 Z"/>
  <path d="M8 20 L32 32 L56 20"/>
  <line x1="32" y1="32" x2="32" y2="56"/>
</svg>`;

const BOOK_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M8 14 L32 20 L56 14 L56 50 L32 56 L8 50 Z"/>
  <line x1="32" y1="20" x2="32" y2="56"/>
  <path d="M14 22 L26 25"/>
  <path d="M14 32 L26 35"/>
  <path d="M38 25 L50 22"/>
  <path d="M38 35 L50 32"/>
</svg>`;

const CHAT_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 14 H52 a4 4 0 0 1 4 4 V40 a4 4 0 0 1 -4 4 H30 L20 54 V44 H12 a4 4 0 0 1 -4 -4 V18 a4 4 0 0 1 4 -4 Z"/>
  <circle cx="22" cy="29" r="2.5" fill="currentColor" stroke="none"/>
  <circle cx="32" cy="29" r="2.5" fill="currentColor" stroke="none"/>
  <circle cx="42" cy="29" r="2.5" fill="currentColor" stroke="none"/>
</svg>`;

interface DefaultSlide {
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

const defaults: DefaultSlide[] = [
  {
    position: 0,
    iconSvg: AR_SVG,
    titleKk: 'AR кейіпкерлер',
    titleRu: 'AR-герои',
    titleEn: 'AR characters',
    descriptionKk: 'Журнал бетінен тарихи тұлғалар тірілеп шығады',
    descriptionRu: 'Исторические личности оживают со страниц журнала',
    descriptionEn: 'Historical figures come alive from the journal pages',
    published: true,
  },
  {
    position: 1,
    iconSvg: BOOK_SVG,
    titleKk: 'Ғылыми журнал',
    titleRu: 'Научный журнал',
    titleEn: 'Science journal',
    descriptionKk: 'Қызықты, түсінікті — оқушыларға арналған',
    descriptionRu: 'Интересно и понятно — для школьников',
    descriptionEn: 'Engaging, clear — made for students',
    published: true,
  },
  {
    position: 2,
    iconSvg: CHAT_SVG,
    titleKk: 'AI-сөйлесу',
    titleRu: 'AI-диалог',
    titleEn: 'AI conversations',
    descriptionKk: 'Тарихи тұлғадан тікелей сұрақ қойып, жауап ал',
    descriptionRu: 'Задай вопрос исторической личности напрямую и получи ответ',
    descriptionEn: 'Ask questions directly to historical figures',
    published: true,
  },
];

export async function seedOnboardingSlides(
  repo: Repository<OnboardingSlide>,
  logger: Logger,
): Promise<void> {
  const count = await repo.count();
  if (count > 0) {
    logger.log(`Onboarding slides already present (${count}), skipping seed`);
    return;
  }
  for (const slide of defaults) {
    await repo.save(repo.create(slide));
  }
  logger.log(`Seeded ${defaults.length} onboarding slides`);
}

# ORTAx Техникалық Тапсырма (ТЗ v2)

> **Версия:** 2.0
> **Күні:** 2026-04-30
> **Статусы:** Phased roadmap (3 фаза)

---

## 1. Жоба сипаттамасы

**ORTAx** — қазақстандық мектеп оқушыларына арналған иммерсивті білім беру платформасы. Жоба ғылыми және тарихи контентті **AR (мобильді) → AI аватар → VR (мектеп)** үш фазалы архитектура арқылы ұсынады.

### Негізгі идея
Оқушы тек оқып қана қоймай, тарихи және ғылыми тұлғалармен **тікелей сөйлесе алады**: журналдан Қожа Ахмет Яссауи AR-да шығады, мектеп VR сабағында Әл-Фараби философияны түсіндіреді, оқушы Абайдан "Қара сөздер" туралы сұрақ қоя алады.

### Бәсекелестік артықшылық
- **Қазақ тілінде** — әлемдік аналогтарда (ENGAGE XR School of AI, ALiVE) қазақ тілі жоқ
- **Жергілікті тарихи тұлғалар** — Яссауи, Әл-Фараби, Абай, Шоқан Уәлиханов, Махамбет
- **МЖМБС-ке байланған контент** — Қазақстан Республикасының мемлекеттік білім беру стандарттарына сай
- **Гибрид модель** — телефон AR-дан VR класс жабдықтауға дейінгі толық экожүйе

---

## 2. Миссия мен мақсат

### Миссия
Қазақстандық оқушылар үшін **тарих пен ғылымды тірі** ету — AI және XR технологиялары арқылы ұлттық мұраны цифрлық форматта жеткізу.

### Стратегиялық мақсаттар
- Балаларға ғылыми/тарихи контентті интерактивті форматта ұсыну
- Журнал беттерін AR кейіпкерлермен жандандыру
- AI-powered conversational аватарлар арқылы оқушылардың сұрақтарына тарихи дәл жауаптар беру
- VR арқылы мектеп класс кеңістігін иммерсивті оқу ортасына айналдыру

---

## 3. Фазалық Roadmap

| Фаза | Мерзімі | Платформа | Негізгі функционал | Мақсат |
|---|---|---|---|---|
| **Фаза 1: Mobile AR MVP** | 3–4 ай | iOS, Android | Журнал + marker-based AR кейіпкерлер | Нарықты валидация, контент pipeline-ды құру |
| **Фаза 2: AI Avatar (Mobile)** | +6–9 ай | iOS, Android | AI conversational аватар (Яссауи bootstrap) | AI-сөйлесу UX-ін smartphone-да тексеру |
| **Фаза 3: VR Classroom** | +12–18 ай | Meta Quest 3/3S, Pico 4 | Толық VR сабақ, 5+ тұлғалы AI ансамбль | Мектептерге B2B енгізу |

> **Себебі:** Бірден VR-ге секіру — контент production құны мен деплоймент проблемасы жағынан қауіпті (Google Expeditions осы себептен жабылды). Mobile AR-да validate жасап, барып VR-ге ауысу — риск-ті азайтады.

---

## 4. Қамтылатын платформалар

### Фаза 1–2 (Mobile)
- iOS 14+
- Android 9+

### Фаза 3 (VR)
- Meta Quest 3 / Quest 3S (priority — Meta for Education program бар)
- Pico 4 Enterprise (alternative — bulk pricing, мектеп ұзақ батарея)

---

## 5. Фаза 1 — Mobile AR MVP

### 5.1 Splash Screen
- ORTAx логотипі
- Жүктеу индикаторы
- Auto redirect (login / home)

### 5.2 Onboarding
- 3–4 интро экран:
  - AR кейіпкерлер
  - Ғылыми/тарихи журнал
  - Интерактив оқу тәжірибесі
  - Болашақ AI-сөйлесу мүмкіндігі (teaser)
- Skip батырмасы

### 5.3 Authentication
- **Login:** Phone number + Password
- **Register:** Phone + Password + SMS OTP
- **Reset Password:** Phone → SMS → New password

### 5.4 Home (Journal Feed)
- Журналдар тізімі (карточка):
  - Title, cover image, short description
  - Жас санаты тегі (1–4, 5–9, 10–11 сынып)
  - Пән тегі (тарих, физика, биология, әдебиет)
- Фильтр + іздеу

### 5.5 Journal Detail
- Page-based контент
- Text + image layout
- AR trigger маркерлері (бет ішінде)
- "Бұл тұлғамен сөйлесу" батырмасы (Фаза 2-де ашылады, MVP-де "Жақында" статусы)

### 5.6 AR Module (MVP)
- Камера арқылы маркерді сканерлеу
- 3D кейіпкер + анимация + қысқа дауыстық түсіндірме (pre-recorded)
- Offline support (модельдер алдын ала кэштеледі)
- Photo capture мүмкіндігі (оқушы достарына жібере алады)

### 5.7 Notification
- Жаңа журнал шықты
- Жаңа AR контент қосылды
- (Фаза 2) AI аватар жаңа тұлға қосылды

### 5.8 Фаза 1 Acceptance Criteria
- User SMS арқылы тіркеле алады
- Journal list ашылады, фильтр жұмыс істейді
- AR trigger marker-арқылы сценаға кейіпкер шығады
- Кейіпкер анимациясы + дауысы offline режимде жұмыс істейді
- Crash-free негізгі flow

---

## 6. Фаза 2 — AI Conversational Avatar (Mobile)

### 6.1 AI Avatar UX
- Журнал ішінде "X тұлғасымен сөйлесу" батырмасы
- AR режимде кейіпкер шығып, оқушы микрофон арқылы сұрақ қояды
- Кейіпкер дауыспен жауап береді (lip-sync + анимация)
- Чат тарихы сақталады

### 6.2 Bootstrap кейіпкер: Қожа Ахмет Яссауи
**Себебі бірінші** — Түркістан туристік дестинация, мұфтиятпен серіктестік мүмкіндігі, оқушыларға қызықты, тарихи дереккөздер жеткілікті.

### 6.3 AI Avatar архитектурасы

```
┌─────────────────────────────────────────────────────┐
│  Mobile App (React Native + AR module)              │
│  ↓                                                   │
│  STT (Speech-to-Text) — қазақ тілі                  │
│      → Yandex SpeechKit / Whisper                   │
│  ↓                                                   │
│  Backend API (Node.js)                              │
│  ↓                                                   │
│  LLM + RAG (Retrieval-Augmented Generation)         │
│      → GPT-4 / Claude + кейіпкер knowledge base    │
│  ↓                                                   │
│  Safety Filter (теологиялық/этикалық тексеру)       │
│  ↓                                                   │
│  TTS (Text-to-Speech) — қазақ тілі                  │
│      → ElevenLabs / Yandex / Sber                  │
│  ↓                                                   │
│  Lip-sync + анимация (Convai SDK немесе custom)     │
└─────────────────────────────────────────────────────┘
```

### 6.4 RAG Knowledge Base (Яссауи мысалында)
1. **"Диуани Хикмет"** — толық қазақша/түрік мәтіні
2. Тарихи деректер: 1093–1166 ж., Сайрам, Түркістан, Жүсіп Хамадани
3. Сопылық/тариқат туралы академиялық еңбектер (М. Көпеев, А. Машани)
4. Хадис жинақтары (Яссауи қолданғандары)
5. **Citation мәжбүрлеу:** әр жауап дереккөзімен ("Хикметтен X бет")
6. **Шектеулер списогі:** AI өзінше қосып айтпайтын тақырыптар (заманауи саясат, нақты теологиялық фатва, басқа дін өкілдеріне бағалау)
7. **"Білмеймін" режимі:** деректер жоқ болса — AI ойдан шығармайды

### 6.5 Voice & Visual
- **Voice:** актер дауысын клондау (тарихи дауыс белгісіз). Стиль: тыныш, терең, баяу
- **3D модель:** тарихи дұрыс киім (хирка, тақия), сопылық қол қимылдары
- **Lip-sync:** Convai немесе Oculus LipSync (open-source)

### 6.6 Фаза 2 Acceptance Criteria
- Оқушы микрофон арқылы сұрақ қоя алады (қазақ/орыс)
- AI 3 секундтан аз уақытта жауап бастайды
- Әр жауап дереккөзімен бірге келеді
- Safety filter рұқсат етілмеген тақырыптарды блоктайды
- Мұфтиятпен бекітілген контент режимі

---

## 7. Фаза 3 — VR Classroom

### 7.1 Мақсат
Мектеп класс кеңістігін иммерсивті оқу ортасына айналдыру. Сабақ ішінде оқушы VR headset кигенде Яссауи Түркістан кесенесінде шығып, оқушының сұрағына тірі жауап береді.

### 7.2 VR Content Modules

| Модуль | Сынып | Тұлға / Контент |
|---|---|---|
| Тарих 1 | 6–7 | Қожа Ахмет Яссауи, Түркістан кесенесі, сопылық тариқат |
| Тарих 2 | 8 | Махамбет, Кенесары, Қазақ хандығы |
| Әдебиет | 8–10 | Абай Құнанбайұлы, "Қара сөздер" |
| Философия/Музыка | 10–11 | Әл-Фараби |
| География/Этнография | 7–9 | Шоқан Уәлиханов |
| Жаратылыстану | 9–11 | Аль-Бируни, Ибн Сина |
| Педагогика | 8–9 | Ыбырай Алтынсарин |

### 7.3 VR Технологиялық стек
- **Engine:** Unity (AR Foundation + XR Interaction Toolkit)
- **AI Avatar:** Convai Unity plugin (low-latency conversation + facial animation)
- **LLM:** Backend RAG service (Фаза 2-ден қайта пайдаланылады)
- **Headset:** Meta Quest 3S (priority), Pico 4 Enterprise (alternative)
- **Device Management:** Meta for Education / Pico Business Suite

### 7.4 Teacher Dashboard
- Мұғалім сабақты бастайды → барлық headset-терге бір контент жіберіледі (ClassVR моделі)
- Оқушы прогресі real-time көрінеді
- Тапсырма / викторина жіберу
- Сабақ соңы есебі (қанша сұрақ қойды, қандай тақырыптар ашты)

### 7.5 Pilot Deployment
- 5–10 пилот мектеп (Алматы, Астана, Түркістан, Шымкент)
- Әр сыныпқа 5–10 headset
- Мұғалімдерге training (2 күн)
- 6 ай pilot → нәтижелерді өлшеу → масштабтау

### 7.6 Фаза 3 Acceptance Criteria
- Мұғалім бір батырмамен барлық headset-терге сабақ жіберіп жатыр
- Оқушы VR-да AI аватармен 5 минуттан көп сөйлесе алады
- Сабақ соңы есебі автоматты түрде PDF-те қалыптасады
- Headset device management орталықтандырылған

---

## 8. Технологиялық стек (жалпы)

### Frontend
- **Mobile:** Flutter (Dart) — Фаза 1, 2
- **VR:** Unity (XR Interaction Toolkit) — Фаза 3

### AR Engine
- **Mobile AR:** `ar_flutter_plugin` (бірыңғай API), немесе платформа-арнайы: `arcore_flutter_plugin` (Android), `arkit_plugin` (iOS)
- **Marker tracking:** ARKit Image Tracking (iOS) + ARCore Augmented Images (Android)

### AI / Conversational
- **LLM:** GPT-4o / Claude Sonnet (provider абстракциясы арқылы)
- **RAG:** Pinecone / Weaviate vector DB
- **STT:** Yandex SpeechKit / OpenAI Whisper
- **TTS:** ElevenLabs (тексеру керек) / Yandex / Sber SaluteSpeech
- **NPC SDK:** Convai (Unity + mobile)

### Backend
- **Framework:** Node.js (NestJS)
- **DB:** PostgreSQL
- **Vector DB:** Pinecone / Weaviate
- **Object Storage:** S3-compatible (3D модельдер, аудио, видео)
- **Auth:** JWT + SMS provider (Twilio / local SMS API)
- **CDN:** CloudFront / local provider

### DevOps
- CI/CD: GitHub Actions
- Monitoring: Sentry + Grafana
- Analytics: Mixpanel / PostHog

---

## 9. Деректер моделі (кеңейтілген)

### User
- id, phone, password_hash, role (student/teacher/admin), grade_level, created_at

### Journal
- id, title, description, cover_image, grade_tags[], subject_tags[], pages[]

### Page
- id, journal_id, content_blocks[] (text/image/ar_marker/avatar_trigger)

### AR Asset
- id, journal_id, model_url, trigger_marker, animation_set, audio_url

### **Avatar** (жаңа — Фаза 2)
- id, name (Яссауи, Әл-Фараби...), model_3d_url, voice_profile_id, knowledge_base_id, status (active/draft)

### **KnowledgeBase** (жаңа — Фаза 2)
- id, avatar_id, source_documents[], embeddings_index_id, citation_required (bool), restricted_topics[]

### **Conversation** (жаңа — Фаза 2)
- id, user_id, avatar_id, started_at, ended_at, messages[]

### **Message** (жаңа — Фаза 2)
- id, conversation_id, role (user/avatar), text, audio_url, citations[], timestamp

### **VRSession** (жаңа — Фаза 3)
- id, teacher_id, lesson_id, school_id, student_ids[], started_at, ended_at, headset_ids[]

### **School** (жаңа — Фаза 3)
- id, name, region, headset_count, license_tier, contact

---

## 10. Контент Production Pipeline

### Әр тұлға үшін стандарт процесс (Pipeline)
1. **Researcher** — тарихи дереккөздер жинақтайды (мақалалар, кітаптар, академиялық еңбектер)
2. **Domain expert** — мұфтият / университет ғалымы дереккөзді бекітеді
3. **Editor** — RAG-қа дайын форматқа айналдырады (chunking, metadata, citations)
4. **Restricted topics list** — қандай тақырыптарға жауап бермейді
5. **3D artist** — кейіпкер моделі (тарихи дұрыс киім + анимациялар)
6. **Voice actor + clone** — дауысты жазу + клондау
7. **QA** — 200+ тестілік сұрақ → жауаптарды эксперт тексереді
8. **Mufti / academic approval** — діни/тарихи дұрыстығы
9. **Soft launch** — 100 user → feedback → fix
10. **Public launch**

### Бір тұлғаның бағасы (естимат)
- 3D модель + анимация: $5,000–10,000
- Дауыс актер + clone: $2,000–5,000
- Knowledge base + RAG setup: $3,000–7,000
- QA + approval: $2,000
- **Барлығы:** ~$12,000–24,000 / тұлға

---

## 11. Этикалық және діни ескертулер

| Қауіп | Шешімі |
|---|---|
| AI Яссауи атынан қате теологиялық пікір | RAG қатаң шектеу + "білмеймін" режимі + safety filter + мұфтиятпен бекіту |
| Ата-аналар "пайғамбар/әулиемен ойнау" деп қарсы | Educational reconstruction фрейминг, мұфтият бекітуі, "tribute" позиционирование |
| AI жалған дәйексөз келтіруі (Einstein chatbot incident прецеденті) | Citation мәжбүрлеу — әр жауап дереккөзімен |
| 12 жасқа дейінгі балаларға VR ұсынылмайды (Meta guideline) | Бастауыш сынып: тек AR (mobile). 5+ сыныптан VR |
| Дауыс этикасы: тарихи тұлғаны дұрыс емес жеткізу | Voice actor + мәдени сараптамашымен бекіту |
| Деректер құпиялығы (балалар сөйлесулері) | COPPA / ҚР Дербес деректер заңы — анонимизация, ата-ана келісімі |

---

## 12. Бизнес-модель (қысқаша)

### Revenue streams
- **B2C Mobile App** — freemium (журналдар тегін, AI аватар сөйлесу — premium $2–5/ай)
- **B2B мектеп:** VR пакет (headset + license + support) — $300–500/headset/жыл
- **B2G тендер:** Білім министрлігі бағдарламалары
- **B2B музей/туристік:** Түркістан, Әзірет Сұлтан кесенесі — Яссауи AR/VR орталық

### Pilot мектеп бағасы (10 headset)
- Hardware: 10 × $500 = $5,000 (бір реттік)
- Software license: $3,000/жыл
- Content updates: $2,000/жыл
- Training: $1,500 (бір реттік)
- **Total Year 1:** ~$11,500 / мектеп

---

## 13. Қауіп-қатерлер (Risks)

| Risk | Влияние | Шешімі |
|---|---|---|
| Қазақ TTS сапасы әлі нашар | High | Pilot ретінде 2–3 provider тексеру (ElevenLabs, Yandex, Sber); custom voice clone fallback |
| LLM hallucination (тарихи қате) | High | RAG + citation + safety filter + ғалым review |
| Headset цена / availability ҚР-да | Medium | Meta for Education + жергілікті distributor серіктестік |
| Мектеп интернет әлсіз | Medium | On-device caching + offline mode (AI-сіз режим бар) |
| Регуляторлық белгісіздік (AI + білім беру) | Medium | Министрлікпен ерте диалог, sandbox жоба статусы |
| Контент production құны жоғары | Medium | Бір тұлғадан бастау (Яссауи), жетістіктен кейін масштабтау |
| Бәсекелестер (ENGAGE XR қазақ тіліне көшсе) | Low | Жергілікті контент + мемлекеттік байланыстар арқылы moat |

---

## 14. Болашақ кеңейту

- Quiz / Gamification модулі (балл, лидерборд)
- Multiplayer VR (бір сабақта бірнеше оқушы бір сахнада)
- Subscription моделі (premium tier)
- AI tutor — пәндік сұрақтарға жауап беретін generic assistant
- Ата-ана dashboard — баланың прогресі
- Контент маркетплейсі — мұғалімдер өз AR/VR контентін жасап жариялай алады
- Trans-language: орыс, ағылшын, түрік нұсқалары

---

## 15. MVP-ге кірмейді (NON-MVP)

- Quiz жүйесі (Фаза 4+)
- Subscription / payment (Фаза 2 соңында)
- Social features (chat, friends)
- Multiplayer VR (Фаза 4+)
- User-generated content
- AI tutor (generic)

---

## 16. KPI / Жетістік өлшеу

### Фаза 1 (MVP)
- 1,000+ тіркелген user
- DAU/MAU ratio > 20%
- AR trigger usage rate > 60%
- App Store rating > 4.3

### Фаза 2 (AI Avatar)
- AI conversation completion rate > 70%
- Average session duration > 5 минут
- Content satisfaction (NPS) > 50
- Citation accuracy (manual audit) > 95%

### Фаза 3 (VR Classroom)
- 5+ pilot мектеп
- Teacher satisfaction > 80%
- Student engagement (87% benchmark — Meta data)
- Test score improvement (+10%+ vs control class)

---

## 17. Дереккөздер мен бенчмарктар

### Жақын аналогтар
- **ENGAGE XR — School of AI** (тарихи тұлғалар + AI)
- **ALiVE** — K-12 history education chatbot (academic project)
- **HistoryMaker VR** (Schell Games) — тарихи embodiment
- **Brainspace Magazine** — журнал + AR (Канада)
- **OYLA** — print + digital гибрид (қазақстандық)

### Технологиялық бенчмарктар
- **Convai** — Unity + Unreal AI character SDK
- **Meta for Education** — мектеп deployment моделі
- **VictoryXR** — all-in-one school package моделі

### Қазақстандық прецеденттер
- Lyceum №85 (Астана) — физика AR pilot — нәтиже: retention/understanding жақсарды
- ҚР Ғылым министрлігі — Inclusive AR project (105 мұғалім, 80 ата-ана)

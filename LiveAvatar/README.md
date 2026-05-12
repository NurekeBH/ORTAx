# LiveAvatar × HeyGen интеграциясы (ORTAx)

Бұл папка — ORTAx жобасына **LiveAvatar** (https://www.liveavatar.com) және
**HeyGen Interactive Avatar** (https://docs.heygen.com) интерактивті
аватарларын қосуға арналған дайын пакет.

---

## 1. LiveAvatar деген не?

**LiveAvatar** — бұл HeyGen командасының бөлек жобасы. Әдеттегі HeyGen видео
генерациясынан ерекшелігі — мұнда аватармен **real-time** (төмен кідірісті,
WebRTC арқылы) сөйлесуге болады:

- Аватар сіздің LLM-ыңыздан (ChatGPT, Claude, өзіңіздің модель) жауап алады
- Lip-sync, ым-ишара, эмоциялар нақты уақытта көрсетіледі
- **Streaming сессия** ашылады, видео WebRTC peer connection арқылы келеді
- API-first архитектура — REST + WebSocket + WebRTC

> LiveAvatar — HeyGen-нің "Streaming Avatar API" эволюциясы. Доменнің өзі
> бөлек (`liveavatar.com`), кредиттер бөлек, бірақ HeyGen аккаунтымен
> кіреді. Тариф: Starter $19 / 150 кредит (1 кредит ≈ 30 с Full режим).

---

## 2. HeyGen аватары мен LiveAvatar қалай байланысады?

```
┌────────────────────┐         ┌─────────────────────┐
│  HeyGen Studio     │  train  │  LiveAvatar cloud   │
│  (avatar жасайсыз) │ ──────► │  (real-time stream) │
└────────────────────┘         └─────────────────────┘
                                          ▲
                                          │ WebRTC
                                          │
                               ┌──────────┴──────────┐
                               │  ORTAx клиент       │
                               │  (Flutter / Web)    │
                               └─────────────────────┘
```

Жұмыс ағыны:

1. **HeyGen Studio** ішінде аватар жасайсыз (2 минуттық видео не фото) →
   `avatar_id` аласыз.
2. **HeyGen API key**-ді LiveAvatar дашбордында белсендіресіз.
3. Клиент сервермен сөйлесіп **session token** алады
   (`POST /v1/streaming.create_token`).
4. Token-мен **session** ашылады (`POST /v1/streaming.new`) — серверден
   `session_id`, SDP offer, ICE servers қайтады.
5. Клиент WebRTC peer connection жасайды, видеоны `<video>` тегіне қосады.
6. Қолданушы микрофонға не текстке сұрақ қояды → LLM жауап жазады →
   `POST /v1/streaming.task` (text=`...`) шақырамыз → аватар сөйлеп
   тұр.
7. Сессия аяқталғанда `POST /v1/streaming.stop`.

---

## 3. Папка құрылымы

```
LiveAvatar/
├── README.md                       ← бұл файл
├── backend/
│   └── live-avatar.controller.ts   ← NestJS контроллері (token mint)
├── web/
│   └── index.html                  ← HeyGen Streaming SDK хост-беті
└── mobile/
    └── live_avatar_screen.dart     ← Flutter экраны (WebView wrapper)
```

### Неліктен WebView?

Flutter үшін ресми LiveAvatar SDK жоқ. Ең тұрақты тәсіл:

- WebView ішінде `web/index.html`-ды ашамыз
- Ол жерде ресми `@heygen/liveavatar-web-sdk` (немесе HeyGen Streaming
  SDK) WebRTC байланысын жүргізеді
- Flutter ↔ WebView `postMessage` арқылы алмасады (қолданушы сұрағы,
  аватар жауабы)

Альтернатива — `flutter_webrtc` + LiveKit Dart клиенті, бірақ ол
SDP/ICE handshake-ті өзіміздің қолмен жасауды талап етеді.

---

## 4. Орнату қадамдары

### 4.1 Backend (NestJS)

```bash
# .env
LIVEAVATAR_API_KEY=sk-xxxxxxxxxxxxxxxx
LIVEAVATAR_API_BASE=https://api.heygen.com   # немесе https://api.liveavatar.com
LIVEAVATAR_AVATAR_ID=Anna_public_3_20240108
LIVEAVATAR_VOICE_ID=                          # бос болса default
```

`backend/src/app.module.ts`-ке `LiveAvatarModule`-ды қосыңыз
(`live-avatar.controller.ts` ішіндегі мысалды қараңыз).

### 4.2 Mobile (Flutter)

```yaml
# mobile/pubspec.yaml
dependencies:
  webview_flutter: ^4.7.0
  permission_handler: ^11.3.0
```

`live_avatar_screen.dart`-ты `mobile/lib/features/avatar/`-қа көшіріңіз
не сол жерден import етіңіз.

### 4.3 Web host

`web/index.html`-ды кез келген статикалық хостингке (Vercel, S3, тіпті
backend-тың `public/` папкасына) орналастырыңыз. Қолжетімді URL
Flutter-ге `?token=...` параметрімен беріледі.

---

## 5. Қауіпсіздік

**ЕШҚАШАН** `LIVEAVATAR_API_KEY`-ді клиентке (мобильді не браузер) шығармаңыз.
Әрбір сессия үшін бекенд қысқа мерзімді `session_token` (`access_token`)
шығарып береді — клиент тек соны алады.

---

## 6. ORTAx avatar модулімен байланыс

`backend/src/avatar/avatar.service.ts` LLM жауаптарын жасайды.
LiveAvatar ағыны кезінде:

1. Қолданушы микрофон/мәтін → Flutter → WebView → backend `/avatar/chat`
2. Backend Claude/OpenAI-дан мәтін жауап қайтарады
3. Flutter сол мәтінді WebView-ге `postMessage` арқылы береді
4. WebView SDK `avatar.speak({ text })` шақырады → аватар айтып тұр

Сонымен, бар `avatar.service.ts` өзгеріссіз қалады — LiveAvatar тек
"аузы мен бет-әлпеті" ретінде үстіне қосылады.

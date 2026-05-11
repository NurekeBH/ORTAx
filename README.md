# ORTAx

Қазақстандық мектеп оқушыларына арналған иммерсивті білім беру платформасы. AR (мобильді) → AI conversational аватар → VR (мектеп класс) — үш фазалы roadmap.

Толық техникалық тапсырма: [`ORTAx_MVP_TZ.md`](./ORTAx_MVP_TZ.md)

## Структура

```
ORTAx/
├── mobile/        Flutter app (iOS + Android) — Фаза 1, 2
├── backend/       NestJS API — auth, journals, AI avatar
├── journal/       контент (журнал беттері, PNG)
├── fonts/         қаріптер
└── ORTAx_MVP_TZ.md
```

## Талаптар

- **Mobile**: Flutter 3.41+ (Dart 3.11+), Xcode 15+ (iOS), Android Studio (Android SDK 34+)
- **Backend**: Node.js 20+, npm 10+, PostgreSQL 15+

## Жылдам бастау

### Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run                  # ағымдағы құрылғы / симулятор
flutter run -d ios           # iOS simulator
flutter run -d android       # Android emulator
```

### Backend (NestJS)

```bash
cd backend
npm install
npm run start:dev            # http://localhost:3000
```

## Фазалар

| Фаза | Статус | Сипаттамасы |
|---|---|---|
| Фаза 1 — Mobile AR MVP | 🚧 In progress | Flutter + journal viewer + marker AR |
| Фаза 2 — AI Avatar | ⏳ Planned | Conversational аватар (Яссауи pilot) |
| Фаза 3 — VR Classroom | ⏳ Planned | Unity + Meta Quest / Pico, мектеп deployment |

# ORTAx Admin Panel

Next.js 15 (App Router) + Tailwind CSS admin panel for the ORTAx backend.

## Setup

```bash
cd admin
npm install
cp .env.local.example .env.local   # optional, defaults to http://localhost:3000/api
npm run dev                          # http://localhost:3001
```

Backend (`../backend`) `npm run start:dev` арқылы 3000 портта тұруы керек және
`DB_ENABLED` өшіп тұрмауы керек (admin модулі тек DB қосулы болғанда қосылады).

### Алғашқы admin-ды құру

Backend-те:

```bash
cd backend
npm run seed:admin -- --phone +77001234567 --password supersecret --name "Admin"
```

Содан кейін `/login` бетінде сол телефон/құпиясөзбен кіруге болады.

## Auth

Admin SPA `/auth/admin/login` arqılı JWT алады (`accessToken`), оны
`localStorage`-те сақтайды және әр сұрауға `Authorization: Bearer ...` header
жалғайды. 401/403 келсе автоматты түрде `/login`-ге қайтарады.

## Pages

- `/` — Dashboard: users (DAU/WAU/MAU), content (journals/pages/AR), avatar
  messages, telegram totals.
- `/users` — пайдаланушылар тізімі, рөл өзгерту, ban/unban, delete.
- `/journals` — журнал CRUD; `/journals/[id]` — беттер мен AR ассеттер.
- `/avatar` — характерлар (system prompt қарау) + чат логы (мобайл/телеграм/веб).
- `/telegram` — TG пайдаланушылар, ban/unban, broadcast.

## API

Барлық сұраулар `${NEXT_PUBLIC_API_BASE}/admin/*` арқылы өтеді. Қазіргі MVP-да
auth жоқ (dev режим). Production-ға шыққанда `/admin/*` маршруттарын JWT +
admin role-мен қорғау керек.

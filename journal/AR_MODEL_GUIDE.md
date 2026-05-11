# Хорезми → 3D GLB моделі (AI-генерация)

Бұл нұсқаулық `journal/png/1.png` (отырған Хорезми) суретінен ORTAx AR
жүйесіне жарамды GLB файлын алу қадамдарын сипаттайды.

## 0. Дайындық

Кіріс сурет: [journal/png/1.png](png/1.png)

Тек кейіпкерді қалдырып, фонды мөлдір (transparent) күйде сақтаған дұрыс.
`1.png` бойынша фон бүгінгі күйінде ақ — қажет болса
<https://www.remove.bg> арқылы 30 секундта тазалаймыз.

## 1. Meshy.ai (ұсынылған, тегін аккаунт жетеді)

1. <https://www.meshy.ai> — Google/email-мен кіру.
2. Бас бетте **"Image to 3D"** таңдау.
3. `1.png`-ны жүктеу.
4. Параметрлер:
   - **Art style**: `Realistic` (немесе `Stylized` — иллюстрация үшін бұл жақсырақ)
   - **Topology**: `Quad` (анимациялауға қолайлы)
   - **Symmetry**: `Auto`
   - **Polygon count**: `30k` (мобайл үшін жеткілікті)
   - **Texture**: `On`, `2K`
5. **Generate** → ~3–5 минут.
6. Нәтиже әдетте 4 нұсқа береді — ең сәттісін таңдау.
7. **Refine** (тегін лимит ішінде 1 рет) — текстура мен топологияны жақсартады.
8. **Download → GLB** (Binary glTF).

Бір модельге 10 кредит, тегін есепшотта айына 200 кредит — 20 итерацияға жетеді.

## 2. Балама — Tripo3D

<https://www.tripo3d.ai> — суретті жүктеу → GLB. Жылдамырақ, кейде Meshy-ден
сапасы ұқсас. Тегін лимиті жомарт.

## 3. Балама — Hyper3D / Rodin

<https://hyper3d.ai> — кейіпкерлерге арналған, бет-әлпет ұқсастығы күшті,
бірақ ақылы.

## 4. Жергілікті тегін нұсқа — TripoSR

Stability AI ашық моделі, GPU қажет:

```bash
pip install git+https://github.com/VAST-AI-Research/TripoSR.git
python run.py --image journal/png/1.png --output-dir out/
```

Сапасы коммерциялық сервистерден төмен, бірақ тегін әрі жеке.

## 5. Сапа тексеру

GLB-ны мынада тексереміз:

- <https://gltf-viewer.donmccurdy.com> — браузерде сүйреп тастап, айналдыру
- <https://modelviewer.dev/editor> — мобайлдағы көрініспен бірдей

Тексеру тізімі:
- [ ] Файл 5 МБ-тан аз ба? (AR үшін)
- [ ] Бет-әлпет таныс па?
- [ ] Артынан/бүйірінен қарағанда жыртылған геометрия жоқ па?
- [ ] Текстура жоғалмаған ба?
- [ ] Тұрған қалпы (pose) орнықты ма?

## 6. Оптимизация (қажет болса)

- **gltf-transform** — компрессия, DRACO, MeshOpt:
  ```bash
  npx gltf-transform optimize input.glb output.glb --texture-compress webp
  ```
- Мақсат: < 3 МБ, < 50k үшбұрыш.

## 7. Жоба ішіне қосу

1. Файлды `mobile/assets/journal/models/khwarizmi.glb` ретінде сақтау.
2. `pubspec.yaml` ішінде `assets/journal/models/` қосу.
3. Backend `ar_assets` кестесіне жазу:
   ```sql
   INSERT INTO ar_assets (page_id, trigger_marker, model_url)
   VALUES (<page-1-uuid>, 'khwarizmi-marker-1',
           'https://cdn.ortax.kz/models/khwarizmi.glb');
   ```
4. Мобайлда `model_viewer_plus` плагині арқылы көрсету
   (camera AR overlay-ге қосылады).

## 8. Анимация (Phase 2)

GLB риг етіп, [Mixamo](https://www.mixamo.com)-ға жүктеп, "Talking",
"Idle", "Waving" анимацияларын алуға болады. Mixamo тегін, бірақ ригі
гуманоид силуэтке жақын болуы керек — Meshy `Realistic + Quad` шығысы
әдетте жарайды.

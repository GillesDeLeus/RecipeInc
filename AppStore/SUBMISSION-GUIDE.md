# recipeInc 1.0 — Submission guide

Everything needed to go from this repo to "Waiting for Review". Listing copy lives in `LISTING.md`.

---

## 1. App Review notes (paste into App Store Connect → App Review Information → Notes)

> recipeInc is a fully offline recipe manager. No account or sign-in exists; all data is stored on-device.
>
> IMPORTANT — Apple Intelligence: the AI-powered import features (From URL on social posts, From Photo, Paste Text, Generate) require Apple Intelligence to be enabled (Settings → Apple Intelligence & Siri) on a supported device. On devices without it, these features show a clear explanatory message. All core functionality — recipe management, meal calendar, shopping lists, pantry tracking, nutrition — works fully without Apple Intelligence.
>
> To test the share extension: open TikTok or YouTube (or Safari on any recipe website), tap Share, choose "recipeInc". Reopen the app — the recipe import screen appears pre-filled. Sharing a screenshot from Photos also works (the app OCRs it).
>
> To test barcode scanning: Storage tab → + → Scan Barcode. Product data is fetched from the public Open Food Facts database; only the barcode number is transmitted.
>
> The camera is used for two purposes: photographing recipes (Import → From Photo → Take Photo) and scanning product barcodes (Storage).

## 2. Pre-submission QA checklist (run on real hardware)

**Devices needed:** one iPhone with Apple Intelligence enabled; ideally one without (or AI toggled off).

### Share extension (the critical path)
- [ ] TikTok → Share → recipeInc → open app → recipe parsed from caption
- [ ] YouTube → Share → recipeInc → open app → recipe parsed from description
- [ ] Instagram → Share → recipeInc → open app → falls back gracefully (paste-text guidance)
- [ ] Safari, normal recipe site → Share → recipeInc → JSON-LD parse (no AI needed)
- [ ] Photos → share a screenshot of a recipe → OCR + parse
- [ ] Share something with no recipe (e.g. a plain URL with no caption) → no false "Recipe saved!"

### Camera (simulator can't test these)
- [ ] Import → From Photo → Take Photo → analyze
- [ ] Storage → Scan Barcode on a real product (EU product for best Open Food Facts coverage)
- [ ] First-use camera permission prompt shows the right text (recipes + barcodes)

### Apple Intelligence states
- [ ] AI enabled: URL/photo/text/generate imports all work
- [ ] AI disabled or unsupported device: clear error messages on AI tabs; rest of app unaffected
- [ ] Notifications: set a storage item expiring in 2 days → permission asked at save (not at launch) → notification arrives

### Localization (spot-check 3+ languages)
- [ ] iOS Settings → recipeInc → Language lists all 7 languages
- [ ] Dutch upgrade path: install previous build, pick Dutch in-app, update to this build → app still Dutch
- [ ] German or Polish: walk all 6 tabs, check for truncated/overflowing labels (German strings are long)
- [ ] Plurals: import a JSON export → summary shows correct singular/plural counts

### Data integrity
- [ ] Export JSON → fresh install → import → recipes, photos, plans, storage all intact
- [ ] Delete recipe with future meal plans → blocked with explanation
- [ ] App backgrounded mid-import → no crash, no data loss

## 3. App Store Connect setup (one-time)

1. **Create the app record:** My Apps → + → New App → iOS, name **recipeInc**, primary language **English**, bundle ID `beullens.homesuite.recipeinc`, SKU e.g. `recipeinc-001`.
2. **Privacy policy URL:** `https://github.com/GillesDeLeus/RecipeInc/blob/main/PRIVACY.md` (repo must be public; alternatively enable GitHub Pages in repo Settings → Pages for a cleaner URL).
3. **App privacy questionnaire:** "Do you collect data?" → **No** → label shows "Data Not Collected".
4. **Age rating:** all questions "No/None" → 4+.
5. **Pricing:** Free, all territories (or your selection).
6. **Localizations:** add nl, de, fr, it, es, pl listing localizations; paste from `LISTING.md`.
7. **Screenshots:** 6.9" iPhone set only (iPad no longer required — device family is iPhone-only). Required: at least 1, recommended 5–6:
   1. Recipe list with a few recipes (hero shot)
   2. Share-sheet → import flow (the differentiator)
   3. Recipe detail with photo + nutrition
   4. Meal calendar week view
   5. Shopping list grouped by aisle
   6. Cook mode
   Tip: seed data first by importing one of your `RecipeApp-Export*.json` files; capture via device or simulator (`xcrun simctl io booted screenshot shot.png`).

## 4. Archive & upload

1. Xcode → scheme **RecipeApp** → destination **Any iOS Device (arm64)**.
2. Product → Archive (signing is automatic, team 859H669NGL).
3. Organizer → Distribute App → App Store Connect → Upload. Expect no validation issues: privacy manifests, icon (no alpha), version sync 1.0/1, deployment targets, and encryption declaration are all in place.
4. Wait for processing, then **TestFlight**: add internal testers; ideally one Dutch and one German speaker for a translation sanity pass.
5. When ready: add the build to the 1.0 version, paste review notes (above), submit.

## 5. Known watch items for review

- **App name "recipeInc"** — tiny chance a reviewer questions the "Inc" suffix (implying a company). If asked: it's a brand name, not a legal-entity claim. Fallback name: "recipeInc – Recipe Box".
- **AI features on reviewer's device** — covered by the review notes; the in-app error messages are localized and actionable.
- **Open Food Facts / NEVO attribution** — already shown in Settings (ODbL requirement satisfied).

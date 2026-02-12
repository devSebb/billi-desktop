# Billi — UI Consistency Audit & Design System Plan

## A) Top 10 UI Inconsistencies

| # | Issue | File(s) | Change |
|---|--------|---------|--------|
| 1 | **Indigo/gray palette mismatch** | `_budget_breakdown.html.erb` | Total Trip Cost card uses `bg-indigo-600`, indigo-100/200/50; AI Budget Analysis uses `from-indigo-50 to-purple-50`. Replace with brand charcoal + teal accent. |
| 2 | **Inconsistent input padding** | `trips/new.html.erb`, `trips/edit.html.erb`, `_budget_tab.html.erb`, Devise, topbar search | Some inputs use `px-4 py-3`, others no explicit padding, others `py-2`. Standardize to `.input` (e.g. 12–14px vertical, 14px horizontal). |
| 3 | **Inconsistent button padding/size** | Various | `btn-primary` uses `px-6 py-2`; some CTAs use `px-8 py-4`; danger zone uses ad‑hoc classes. Add `.btn`, `.btn-sm`, `.btn-lg`, `.btn-danger`, `.btn-ghost`, `.btn-icon`. |
| 4 | **Missing icons in “Adjust Preferences”** | `_budget_tab.html.erb` | Section title "Adjust Preferences" has no icon; Budget Preferences summary uses emoji (🏨🍽). Add small SVG or icon class next to "Adjust Preferences". |
| 5 | **Card padding and spacing** | Trips index, show, ledger, friends, edit | Cards use mix of `p-6`, `p-8`; section gaps vary (mb-6, mb-8, space-y-6, space-y-8). Standardize: card padding 16–24px (e.g. `.card` = p-6), section gap 24–32px. |
| 6 | **Typography: heading levels** | All views | Page titles vary: `text-2xl`, `text-3xl`, `text-4xl`; section titles `text-lg`, `text-xl` inconsistently. Define `.page-title`, `.section-title`, `.card-title`, `.label`, `.caption`. |
| 7 | **Focus/hover/disabled states** | Inputs, buttons, links | Some inputs have `focus:ring-brand-yellow`, others `focus:ring-0`; buttons lack consistent `focus-visible:ring-2`. Standardize focus ring (2px offset), hover, disabled (opacity + cursor). |
| 8 | **No Dark/Light theme** | Layout, body | Entire app is light-only. Add theme toggle in topbar, Tailwind `dark:` + CSS variables, persist in localStorage, default to system. |
| 9 | **Badges/pills inconsistent** | Trip show status, snapshot “Estimated”, ledger category | Status uses `rounded-full bg-gray-100`; Estimated uses `text-amber-200`/`text-amber-600`; category pills different. Introduce `.badge`, `.badge--muted`, `.badge--accent`. |
| 10 | **Large container margins** | Main content, trip show, ledger | Some sections feel squeezed (e.g. trip show header and tabs close together). Standardize main padding and gap between major blocks (e.g. 24–32px). |

---

## B) Design Tokens (CSS Variables)

- **Background**: `--bg-page`, `--bg-surface`, `--bg-muted`
- **Border**: `--border-default`, `--border-muted`
- **Text**: `--text-primary`, `--text-muted`, `--text-inverse`
- **Brand**: `--color-brand-yellow`, `--color-brand-charcoal`, `--color-brand-teal`
- **Semantic**: `--color-success`, `--color-warn`, `--color-error`
- **Spacing**: card padding 24px (6), input padding 12px/14px (3/3.5), section gap 24–32px (6–8)

---

## C) Component Classes

- **Buttons**: `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-ghost`, `.btn-danger`, `.btn-icon`
- **Inputs**: `.input`, `.input--error`; labels `.label`, help `.help-text`
- **Cards**: `.card`, `.card--bordered`; sections `.section`, `.section-title`
- **Badges**: `.badge`, `.badge--muted`, `.badge--accent`, `.badge--success`, `.badge--error`
- **Tabs**: `.tabs`, `.tabs__item`, `.tabs__item--active`

---

## D) Theme Toggle Plan

- **Where**: Signed-in layout topbar, next to search (icon-only button: sun/moon).
- **How**: Stimulus controller toggles `document.documentElement.classList.toggle('dark')`; reads/writes `localStorage.getItem('theme')` (`'light'|'dark'|null`). On load, if null, use `window.matchMedia('(prefers-color-scheme: dark)')`.
- **Tailwind**: Use `dark:` variants and CSS variables for `--bg-page`, `--text-primary`, etc., so one place controls dark palette.

---

## E) Refactor Checklist by Page

- [ ] **Landing** (`pages/home.html.erb`): Buttons to `.btn`, `.btn-primary`; ensure spacing between sections.
- [ ] **Trips index**: Cards use `.card`; empty state CTA `.btn-primary`; spacing between featured cities and grid.
- [ ] **Trip show**: Header card, tabs (`.tabs`), overview/budget/collaborators content; badges to `.badge`.
- [ ] **Trip new/edit**: Form to `.input`, `.label`, `.help-text`; step indicator spacing; primary/secondary buttons.
- [ ] **Wizard step 2**: Same form components; section titles + icons.
- [ ] **Ledger**: Filter select `.input`; “Add Expense” button; table container card; empty state.
- [ ] **Devise** (sign in, sign up, edit): Inputs/labels to design system; edit profile danger zone `.btn-danger`.
- [ ] **Layout**: Body/root use token classes; sidebar/topbar dark mode; theme toggle in topbar.

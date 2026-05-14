# Portfolio Website — Build & Layout Plan

**Document purpose:** Internal brief for **developers** and **AI assistants** implementing the site.  
**Primary focus:** How to build the site (stack, structure, constraints) plus **wireframe-level layout** guidance.  
**Out of scope:** SEO, search-engine optimization, and related meta-strategy (explicitly not required).

---

## 1. Product overview

| Field | Detail |
|--------|--------|
| **Owner** | Final-year BA student positioning toward **Business Analysis** and **Project Management (PM)** |
| **Site users** | Recruiters and internship hiring teams |
| **Hosting** | **GitHub Pages** (public static site, `username.github.io` or project Pages URL) |
| **Site language** | English (UI copy and content) |
| **Contact** | Email and/or LinkedIn URL only — **no contact form**, **no backend** |
| **Site structure** | **Multi-page** static site; **project detail pages** (one HTML per project) with multiple file downloads and external links |

---

## 2. Goals

1. Present a **clear, credible professional identity** (analytical, structured, friendly).
2. Let visitors follow a clear **multi-page** path: **About** → **Projects** (index) → **project detail** (as needed) → **CV** → **Contact**, without cramming everything into one scroll.
3. Ship a **distinctive** visual design (not generic “AI slop” template) using the approved **green / sage** palette and accent colors.
4. Remain **maintainable** by a non-coder: mostly text and asset swaps in predictable files.

---

## 3. Brand & tone

- **Keywords:** analytical · structured · friendly  
- **Voice:** Professional, concise, confident; avoid buzzword stuffing; prefer concrete outcomes in project blurbs.

---

## 4. Design tokens — color

Use CSS custom properties (variables). Primary surfaces lean **sage**; depth and hierarchy use **forest** greens; accents used sparingly for CTAs and highlights.

### Greens (dark → light)

| Token suggestion | Hex |
|------------------|-----|
| `forest-dark` | `#1E3D1A` |
| `forest` | `#2D5A27` |
| `forest-medium` | `#3D6B35` |
| `olive` | `#4A7C3F` |
| `green-medium` | `#5C9E4A` |
| `green-light` | `#6AAF58` |

### Sage

| Token suggestion | Hex |
|------------------|-----|
| `sage-pale` | `#E8F0E0` |
| `sage-light` | `#D4E6C3` |
| `sage-medium` | `#C5DBA8` |
| `sage-dark` | `#A3C880` |

### Supporting

| Token suggestion | Hex | Usage |
|------------------|-----|--------|
| `accent-yellow` | `#F5C842` | Highlights, subtle badges |
| `accent-coral` | `#E85B3A` | Sparingly — links hover or single accent, not dominant |
| `warm-white` | `#F5F5F0` | Page background or card background |
| `text-dark` | `#2C2C2C` | Body text |
| `brown-gold` | `#8B6914` | Optional secondary text / dividers |

**Layout guidance:** Default page background `warm-white` or `sage-pale`; cards on `warm-white` with soft border or shadow using forest at low opacity; primary buttons `forest` or `forest-medium` with `warm-white` text; secondary buttons outline in `forest`.

---

## 5. Typography (direction)

- **Headings:** Modern geometric or humanist sans (e.g. system stack or one webfont — keep **one** display/heading family max).  
- **Body:** Highly readable sans, comfortable line length (~65–75ch max), generous line-height.  
- **Hierarchy:** Clear H1 → H2 → H3; avoid more than 3 levels on a single view; project detail pages may use more sections but keep heading order logical.

---

## 6. Information architecture — **multi-page**

The site is **not** a single long page. Each primary area is its own HTML file. **Project cards** on the listing page link to a **dedicated project detail page** per project.

### 6.1 Primary pages (site map)

| File | Purpose |
|------|---------|
| `index.html` | **Home** — hero, one-line role, short hook, primary CTAs (e.g. About, Projects). Optional: same global nav as all pages. |
| `about.html` | **About** — bio + **Skills / Tools** block (as agreed). |
| `projects.html` | **Projects index** — 2–4 cards; each card’s main CTA is **“View project”** → detail page (not inline expansion). |
| `cv.html` | **CV** — one line + **Download CV (PDF)** button only. |
| `contact.html` | **Contact** — email + LinkedIn only. |

**Global navigation (all pages):** Home · About · Projects · CV · Contact — order reflects preferred journey **About → Projects → CV → Contact**; Home is entry but nav makes the sequence obvious.

### 6.2 Project detail pages

- **One HTML file per project**, e.g. `projects/capstone-budgeting.html`, `projects/campus-events-pm.html`.  
- Use a **URL-safe slug** (lowercase, hyphens) matching the filename without spaces.  
- Each detail page includes:
  - **Breadcrumb** or text link: `← Back to Projects` → `projects.html`.
  - **Header block:** project title, one-line tagline, metadata (your role, timeframe, team size / course context if relevant).
  - **Narrative sections** (use only what applies): Context / Problem · Scope · Approach · Outcomes · Reflection (flexible headings).
  - **Deliverables & files** — a dedicated region listing **every** artifact hosted in the repo **and/or** external links:
    - **Internal files:** PDFs, images, diagrams under `assets/projects/<slug>/` with `<a href="...">` download or open in new tab as appropriate.
    - **External links:** Notion, Google Drive, GitHub, Figma, Loom, etc. — each as its own labeled row or button group.
  - **Optional:** image gallery, quote, or “Key metrics” callout — still static HTML.

**Confidential projects:** anonymize copy; omit or redact files; keep external links only if approved for sharing.

### 6.3 Linking rules

- Use **relative paths** between pages (e.g. `href="projects/my-slug.html"`, `href="../css/styles.css"`) so the site works on both **user site** (`username.github.io/repo/`) and **project site** configurations — dev should verify after first deploy.  
- Do **not** rely on anchor-only navigation for primary content; each page is a real navigation target.

---

## 7. Wireframes & layout (desktop ≥1024px)

### 7.1 Global chrome (every page)

```
┌─────────────────────────────────────────────────────────────┐
│ [Logo/name]    Home  About  Projects  CV  Contact   [CV btn] │
└─────────────────────────────────────────────────────────────┘
```

- Optional sticky header; compact height; background must stay readable over sage/white content.

### 7.2 Home (`index.html`)

```
┌──────────────────────────┬──────────────────────────────────┐
│  H1 + one-line role      │   Photo (optional) OR graphic      │
│  2–3 line intro          │   using palette                    │
│  [About] [Projects]      │                                    │
└──────────────────────────┴──────────────────────────────────┘
```

- **Distinctive move:** same as before — structured grid, forest + sage, optional typographic BA/PM motif.

### 7.3 About (`about.html`)

```
┌─────────────────────────────────────────────────────────────┐
│  H1 About                                                   │
│  Paragraph(s)                                               │
│  H2 Skills & tools                                          │
│  [Pill] [Pill] ...  OR  grouped columns                     │
└─────────────────────────────────────────────────────────────┘
```

### 7.4 Projects listing (`projects.html`)

```
┌─────────────────────────────────────────────────────────────┐
│  H1 Projects                                                │
│  ┌─────────────┐ ┌─────────────┐                            │
│  │ thumb       │ │ thumb       │                            │
│  │ Title       │ │ Title       │                            │
│  │ 2–3 lines   │ │ 2–3 lines   │                            │
│  │ Role · Year │ │ Role · Year │                            │
│  │ [View project →]  links to projects/<slug>.html           │
│  └─────────────┘ └─────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

- Card **does not** host full detail; it teases and routes to the detail page.

### 7.5 Project detail (`projects/<slug>.html`)

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back to Projects                                          │
│  H1 Project title                                            │
│  Tagline · Role · Date                                       │
├─────────────────────────────────────────────────────────────┤
│  H2 Overview    │  (optional sidebar: quick links to        │
│  paragraphs...  │   anchors on same page: Deliverables)      │
├──────────────────┴──────────────────────────────────────────┤
│  H2 Approach / Methods                                       │
│  ...                                                         │
├─────────────────────────────────────────────────────────────┤
│  H2 Outcomes                                                 │
│  ...                                                         │
├─────────────────────────────────────────────────────────────┤
│  H2 Deliverables & resources                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ [PDF] Final report — assets/projects/slug/report.pdf   │   │
│  │ [PDF] Stakeholder deck                                 │   │
│  │ [External] Notion / Drive / GitHub — labeled buttons   │   │
│  └─────────────────────────────────────────────────────┘   │
│  H2 Gallery (optional) — image grid                          │
└─────────────────────────────────────────────────────────────┘
```

- **Deliverables** section is the contract for “many files and links”: repeatable list pattern (icon + label + `href`).  
- Long pages: optional **in-page subnav** (“Jump to: Deliverables”) using anchor IDs on the same detail page only.

### 7.6 CV (`cv.html`)

```
┌─────────────────────────────────────────────────────────────┐
│  H1 CV                                                      │
│  Short note (e.g. Last updated …)                           │
│  [ Download CV (PDF) ]                                      │
└─────────────────────────────────────────────────────────────┘
```

- PDF: `assets/cv.pdf` (or documented path).

### 7.7 Contact (`contact.html`)

```
┌─────────────────────────────────────────────────────────────┐
│  H1 Contact                                                 │
│  Email (mailto) · LinkedIn (target=_blank, rel noopener)    │
└─────────────────────────────────────────────────────────────┘
```

### 7.8 Footer

- Same minimal footer on all pages (copyright, optional one-line credit).

---

## 8. Wireframes — mobile (≤768px)

- **Each page** stacks vertically; project detail: deliverables as a **single-column** list of full-width tap targets.  
- **Nav:** hamburger or icon that opens full-screen / drawer menu listing Home, About, Projects, CV, Contact. Touch targets ≥44px.  
- **Breadcrumb** on detail pages remains visible (first item in main content).

---

## 9. Technical build specification

| Topic | Decision |
|--------|----------|
| **Stack** | Static **HTML + CSS**; vanilla JS only if needed (mobile nav). No React/Next requirement. |
| **Repo structure (suggested)** | `index.html`, `about.html`, `projects.html`, `cv.html`, `contact.html`, `projects/*.html` (one per project), `css/styles.css`, `js/main.js` (optional), `assets/cv.pdf`, `assets/images/`, `assets/projects/<slug>/...`, `README.md`. |
| **GitHub Pages** | Publish from `main` branch `/ (root)` or `/docs` — document in README; confirm **relative** links after first deploy. |
| **Forms / backend** | None |
| **SEO** | No dedicated SEO work, no SEO section in this plan. |
| **Accessibility (baseline)** | Semantic landmarks (`header`, `main`, `nav`, `footer`), visible focus states, sufficient contrast; external links identified in copy or `aria-label` where icon-only. |
| **Performance** | Optimize images; lazy-load heavy gallery images on detail pages if needed. |

---

## 10. Content checklist (owner supplies)

**Global**

- [ ] Final English copy: home hero, about paragraph(s), skills/tools list  
- [ ] CV PDF file + filename convention (`assets/cv.pdf` recommended)  
- [ ] Public email + LinkedIn URL  
- [ ] Optional portrait (cropped, web-friendly size)  

**Projects index (`projects.html`)**

- [ ] 2–4 projects: card title, 2–3 line teaser, role, timeframe, thumbnail (optional)  
- [ ] Each card links to the correct `projects/<slug>.html`  

**Per project detail (`projects/<slug>.html` + `assets/projects/<slug>/`)**

- [ ] Long-form narrative (sections as applicable: overview, approach, outcomes, …)  
- [ ] List of **all** deliverables: label + file path **or** external URL for each item  
- [ ] Files placed under `assets/projects/<slug>/` (PDFs, images, exports) with clear filenames  
- [ ] Confirm confidentiality: anonymized copy and/or omitted files where needed  

---

## 11. README for non-technical owner (dev should add)

Short bullets only:

1. Edit copy in `index.html`, `about.html`, `projects.html`, `cv.html`, `contact.html`, and each file under `projects/`.  
2. Add or replace files under `assets/` and `assets/projects/<slug>/`; keep **slug** folder name aligned with the HTML filename (without `.html`).  
3. When adding a **new project**: duplicate a detail page template → rename to `projects/<new-slug>.html` → add matching folder `assets/projects/<new-slug>/` → add a card on `projects.html` with `href="projects/<new-slug>.html"`.  
4. Push to GitHub → Settings → Pages → enable → wait for URL; open every nav link and each **View project** link on the live site.  
5. (Optional) Custom domain later — not in initial scope.

---

## 12. Acceptance criteria (done = shippable)

1. **Multi-page** English site: separate routes for **Home**, **About** (incl. Skills/Tools), **Projects index**, **CV**, **Contact** — global nav reaches each page.  
2. **Projects index** lists 2–4 projects; each card links to a **project detail page** that loads its own URL (not an in-page-only accordion).  
3. Each **project detail** page includes narrative section(s) plus a **Deliverables & resources** area with **multiple** entries (repo files and/or external links), each with a clear label and working `href`.  
4. Visual design uses the **approved palette**; look is **structured** yet **distinctive**.  
5. **Download CV** on `cv.html` works (valid PDF path).  
6. **Contact** shows only email + LinkedIn as agreed.  
7. **GitHub Pages** deploy: no broken **relative** links between root pages, `projects/*.html`, `css/`, and `assets/`; usable on mobile and desktop.  
8. No forms, no backend, **no SEO deliverables**.

---

## 13. Open items (fill during implementation)

- Exact headline + about copy (final strings).  
- Final list of skills/tools and grouping.  
- Project titles, **URL slugs** (`projects/foo-bar.html`), and whether any need anonymization.  
- Per project: final list of file names + external URLs for the deliverables block.  
- Optional hero photo vs abstract graphic decision on Home.

---

*End of plan.*

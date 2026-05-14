# Portfolio (static site)

English multi-page portfolio for GitHub Pages: **Home**, **About**, **Projects** (+ detail pages), **CV**, **Contact**. Design follows `plan.md` (forest / sage palette, no SEO section).

**Tiếng Việt (ngắn):** Thêm file `assets/cv.pdf`, sửa nội dung trong các file `.html`, rồi đẩy repo lên GitHub và bật Pages (mục *Deploy* bên dưới).

---

## What to customize first

1. **Branding:** Display name is **Minh Duc** (`Minh` + `Duc` in the logo). To change it later, search HTML for `Minh Duc` and `Minh<span>Duc</span>`.
2. **Contact:** Edit `contact.html` — email and LinkedIn URL.
3. **CV:** Export your résumé as **`assets/cv.pdf`**. Until this file exists, the download button will 404.
4. **About:** Edit `about.html` — your story, skills, tools, pills.
5. **Projects listing:** Edit `projects.html` — card titles, blurbs, and links if you rename slugs.
6. **Project detail pages:** Under `projects/`, edit each `*.html` narrative. Replace every `https://example.com` external link with your real Notion / Drive / GitHub / Miro links.
7. **Project files:** Put PDFs, images, and exports under `assets/projects/<slug>/` and update the `href` paths in the matching HTML file in `projects/`.

Sample internal files (`.txt`) are only placeholders so links work out of the box — swap them for your real deliverables.

---

## Folder layout

```
index.html
about.html
projects.html
cv.html
contact.html
plan.md
css/styles.css
js/main.js
assets/
  cv.pdf                 ← you add this
  projects/
    capstone-business-case/
    campus-events-pm/
    process-mapping-sprint/
projects/
  capstone-business-case.html
  campus-events-pm.html
  process-mapping-sprint.html
```

---

## Add a new project

1. Copy `projects/process-mapping-sprint.html` to `projects/<new-slug>.html`.
2. Create `assets/projects/<new-slug>/` and add files.
3. Fix all `../` links in the new HTML (they should stay the same if the file stays inside `projects/`).
4. Add a new card to `projects.html` pointing to `projects/<new-slug>.html`.

---

## Deploy on GitHub Pages

1. Create a new **public** repository on GitHub and push this folder (GitHub Desktop or `git` CLI).
2. Repo → **Settings** → **Pages** → Build and deployment: **Deploy from a branch**, branch **`main`**, folder **`/ (root)`** (or `/docs` if you moved files there — then adjust accordingly).
3. After the workflow finishes, open the site URL GitHub shows (often `https://<username>.github.io/<repo>/`).
4. Click through **every** nav item and each **View project** link on the live site to confirm relative paths work.

---

## Local preview

Double-click `index.html` **or** run a static server from this directory, for example:

```bash
npx --yes serve .
```

Then open the URL printed in the terminal (navigation and relative paths behave like production).

---

## License

Personal portfolio — replace this section with your own notice if needed.

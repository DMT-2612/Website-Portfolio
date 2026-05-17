# Yarn Petals — Power BI Dashboard Plan

**Purpose:** As-built reference for the one-page executive dashboard in Power BI Desktop.  
**Client:** Ivy  
**Prepared By:** Minh Duc  
**Project:** Yarn Petals Data Transformation & Dashboard (Phase 5)  
**Artifact:** `Yarn Petals..pbip`  
**Data:** `Universal.xlsx` → sheet **`Orders`** (import as-is; no further transformation in Power BI)  
**Companion doc:** `POWER_BI_MEASURES_GUIDE.md` — DAX, parameters, and step-by-step build  
**Build approach:** Model-first, centralised `Metrics`, field parameter on `Parameter` (no PY / YoY / Time Grain)

---

## 1. Overview

| Item | Detail |
|------|--------|
| Goal | Interactive sales dashboard for owner/partner decisions |
| Data source | `Universal.xlsx` (single source of truth) |
| Tool | Power BI Desktop only |
| Report | 1 page — **Sales Dashboard**, English UI, AUD currency |
| Rows (current) | **1,132** orders (one row per `Order Number`) |
| Date range in data | **2023-06-01** → **2026-01-27** (5 calendar years in `DimDate`) |
| Validation baseline (unfiltered) | See **Section 3** |

---

## 2. Scope

### In scope

- Load `Universal.xlsx` / `Orders` into semantic model
- **Simplified model:** `Orders` + `DimDate` + `Metrics` + field parameter table **`Parameter`**
- **Three KPI measures only:** Net Sales, Orders Count, Total Customers
- **Field parameter:** `Parameter` — Net Sales vs Orders Count (drives charts via `Selected Metric Value`)
- One report page with layout defined in **Section 7** (16 visuals)
- Slicers: Product, Animals, Colour, Date, Occasions, State + **Parameter** (top-right)
- Yarn Petals pink theme (`YarnPetalsTheme.json` / registered custom theme)
- `Email` stays in the model; **never** placed on report visuals

### Out of scope

- **PY, YoY %, Growth KPI** — not used (no prior-year comparison on cards or charts)
- Separate dimension tables (DimProduct, DimAnimal, …)
- Dedicated `% by Colour / Product / Animal / Occasion` DAX measures (use visual **Percent of grand total**)
- **Time Grain** (Month vs Year toggle) — not implemented
- **Line chart** trend — not implemented (column chart only)
- MoM, PM, QTD, MTD, PREVIOUSYEAR, DATEADD time intelligence
- Python ETL / automated refresh workflow
- Power BI Service / Fabric publish
- Row-level security (RLS)
- Shopify / API integration

---

## 3. Assumptions & validation (from `Universal.xlsx`)

| Check | Expected value (unfiltered) |
|-------|-----------------------------|
| Row count | **1,132** |
| `SUM(Total)` → Net Sales | **$77,601.98** |
| Distinct `Order Number` → Orders Count | **1,132** |
| Distinct `Name` → Total Customers | **744** |
| Column name for product | **`Product`** |
| `Email` | Present in source; do not modify column; hide from report only |
| Business rules | Already applied in Excel; Power BI does not remap values |
| Sale Channels in file | Direct, Facebook, Instagram, NG, Offline, Website (and any values in merged file) |

---

## 4. Data dictionary

| Column | Type | Model table | On report |
|--------|------|-------------|-----------|
| Date | Date | Orders + DimDate | Slicer (Between) |
| Order Number | Text | Orders | Hidden (tooltips optional) |
| Name | Text | Orders | Hidden; used for Total Customers only |
| Sale Channels | Text | Orders | Donut + filters |
| Product | Text | Orders | Slicer + donut |
| Animals | Text | Orders | Slicer + donut |
| Colour | Text | Orders | Slicer + donut |
| Occasions | Text | Orders | Slicer + donut |
| Shipping Method | Text | Orders | Not on page |
| Shipping Fee | Decimal | Orders | Not on page |
| Product Price | Decimal | Orders | Not on page |
| Total | Decimal | Orders | Net Sales |
| State | Text | Orders | Slicer + bar chart |
| Email | Text | Orders | **Never on report** |

---

## 5. KPI & measure catalogue

### 5.1 Core performance measures (`Metrics` table)

| Measure | DAX logic (summary) | Format |
|---------|---------------------|--------|
| **Net Sales** | `SUM(Orders[Total])` | Currency AUD |
| **Orders Count** | `DISTINCTCOUNT(Orders[Order Number])` | Whole number |
| **Total Customers** | `DISTINCTCOUNT(Orders[Name])` | Whole number |

> **UI label:** Multi-card shows **Sold Bundles** as the category label for `Orders Count` (display name only; one measure). **No reference labels** (no PY / YoY text).

### 5.2 Field parameter — `Parameter`

| Slicer value | `Parameter Order` | Routes to |
|--------------|-------------------|-----------|
| Net Sales | 0 | `[Net Sales]` |
| Orders Count | 1 | `[Orders Count]` |

| Measure | Role |
|---------|------|
| **Selected Metric Value** | `SWITCH` on `Parameter[Parameter Order]`; drives charts |
| **Selected Metric Label** | Text label for dynamic chart titles |

**Fixed KPI multi-card (not switched by Parameter):**

| Card slot | Measure |
|-----------|---------|
| Net Sales | `[Net Sales]` |
| Sold Bundles (label) | `[Orders Count]` |
| Total Customers | `[Total Customers]` |

**Uses Selected Metric Value:** trend column, channel donut, state bar, four distribution donuts.

### 5.3 Distribution donuts — no dedicated % measures

| Visual | Legend | Values | % display |
|--------|--------|--------|-----------|
| F1–F4 | `Orders[Colour]` / `Product` / `Animals` / `Occasions` | `[Selected Metric Value]` | Data label: **Percent of grand total** |

When Parameter = Orders Count → % of orders; when Net Sales → % of revenue.

### 5.4 Dynamic chart titles (`Metrics` — display folder `Title`)

| Measure | Used on |
|---------|---------|
| `Chart Title Trend` | Trend column chart |
| `Chart Title Channel` | Sales channel donut |
| `Chart Title State` | State bar chart |
| `Chart Title Colour` | Colour donut |
| `Chart Title Product` | Product donut |
| `Chart Title Animal` | Animals donut |
| `Chart Title Occasion` | Occasions donut |

Pattern: `[Selected Metric Label] & " …"` (e.g. `Net Sales Trend`, `Orders Count by State`).

---

## 6. Data model

```
DimDate[Date] ──1──*── Orders[Date]

Orders          ← all business columns from Universal.xlsx
DimDate         ← calendar + Year, Month, Year-Month (marked date table)
Metrics         ← DAX measures (display folders)
Parameter       ← field parameter (Net Sales | Orders Count)
```

**Rules:**

- Mark **`DimDate`** as the date table; contiguous calendar from min–max `Orders[Date]`.
- **`DimDate` columns:** `Date`, `Year`, `Month`, `Month Number`, `Year-Month`, `Year-Month Sort` (hidden; sorts `Year-Month`).
- **Do not** create DimProduct / DimAnimal / DimColour / DimOccasion / DimChannel / DimState.
- **Do not** modify or remove `Orders[Email]`.
- Relationship: `DimDate[Date]` → `Orders[Date]`, single direction, one-to-many.

**Measure display folders (in `Metrics`):**

```
Performance Metrics\
Dynamic\
Title\
```

**Measure count:** **12** (see `POWER_BI_MEASURES_GUIDE.md` Section 4).

---

## 7. Report layout (as-built)

**Page:** `Sales Dashboard` · **Canvas:** 1280 × 720 px · **Fit to page** · Background `#FDE8EF`

**Visual count:** **16**

### 7.1 Zone map (pixel positions from PBIP)

| Zone | Y (px) | Height (px) | Visuals |
|------|--------|-------------|---------|
| A — Header | 0 | ~48 | Title text box + Parameter slicer (right) |
| B — Slicers | ~48 | ~62 | Six filter slicers (single row) |
| C — KPI | ~110 | ~123 | One **multi-card** (3 KPIs, values only) |
| D/E — Middle | ~233 | ~243 | Channel donut (left) + trend column (centre) |
| E — State | ~110 | ~366 | State bar (right column, full height) |
| F — Distribution | ~475 | ~245 | Four donuts |

### 7.2 Zone A — Header

| Visual | Type | Position (x, y, w, h) | Content |
|--------|------|------------------------|---------|
| Title | Text box | 0, 0, 1280, 48 | `Yarn Petals — Sales Dashboard` |
| Parameter | Slicer (tile) | 1039, 0, 241, 45 | `Parameter[Parameter]` — Net Sales \| Orders Count |

| Property | Value |
|----------|--------|
| Title font | Segoe UI Semibold, **20pt**, `#9B6B7A` |
| Title background | `#FFFFFF` with border |
| Subtitle | **Not on page** (title only) |

### 7.3 Zone B — Slicer row (single row)

| # | Slicer | Field | Position (x, w) |
|---|--------|-------|-----------------|
| 1 | Product | `Orders[Product]` | 0, 212 |
| 2 | Animal | `Orders[Animals]` | 212, 212 |
| 3 | Colour | `Orders[Colour]` | 424, 212 |
| 4 | Date | `DimDate[Date]` — **Between** | 636, 220 |
| 5 | Occasion | `Orders[Occasions]` | 856, 212 |
| 6 | State | `Orders[State]` — multi-select | 1068, 212 |

All at **y ≈ 48**, height **≈ 62**. Header text size **9pt** where configured.

### 7.4 Zone C — KPI multi-card

| Property | Value |
|----------|--------|
| Type | **cardVisual** (single visual, three data points) |
| Position | 0, 110, 852, 123 |
| Values | `Net Sales`, `Orders Count`, `Total Customers` |
| Labels | Net Sales, Sold Bundles, Total Customers |
| Reference labels | **None** (no PY / YoY / Growth KPI) |

### 7.5 Zone D — Trend (centre)

#### D1 — Trend column (only trend visual)

| Property | Value |
|----------|--------|
| Type | Clustered column chart |
| Position | 426, 233, 427, 243 |
| X-axis | `DimDate[Year-Month]` (fixed) |
| Y-axis | Field parameter on Y (`Parameter[Parameter]`) |
| Title | `Metrics[Chart Title Trend]` (dynamic) |
| Line chart / PY series | **Not used** |

### 7.6 Zone E — Channel & State

#### E1 — Sales channel donut (left)

| Property | Value |
|----------|--------|
| Position | 0, 233, 426, 243 |
| Legend | `Orders[Sale Channels]` |
| Values | `[Selected Metric Value]` |
| Title | `Metrics[Chart Title Channel]` |
| Data labels | % of grand total + value (as configured) |

#### E2 — State bar (right)

| Property | Value |
|----------|--------|
| Type | Clustered bar (horizontal) |
| Position | 852, 110, 428, 366 |
| Y-axis | `Orders[State]` |
| X-axis | `[Selected Metric Value]` |
| Title | `Metrics[Chart Title State]` |
| Sort | By value descending |

### 7.7 Zone F — Distribution row (four donuts)

| Chart | Legend | Position (x, w) | Title measure |
|-------|--------|-----------------|---------------|
| F1 Colour | `Orders[Colour]` | 0, 320 | `Chart Title Colour` |
| F2 Product | `Orders[Product]` | 320, 320 | `Chart Title Product` |
| F3 Animal | `Orders[Animals]` | 640, 320 | `Chart Title Animal` |
| F4 Occasion | `Orders[Occasions]` | 960, 320 | `Chart Title Occasion` |

All at **y ≈ 475**, height **≈ 245**. Values: `[Selected Metric Value]`. Data labels: **Percent of grand total** + category.

### 7.8 Wireframe (ASCII)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Yarn Petals — Sales Dashboard                    [Net Sales | Orders Count]│
├──────────────────────────────────────────────────────────────────────────────┤
│ [Product][Animal][Colour][Date↔][Occasion][State]                            │
├──────────────────────────────────────────────┬───────────────────────────────┤
│  NET SALES  │  SOLD BUNDLES  │  TOTAL CUSTOMERS │  By State (bar)            │
├──────────────────┬───────────────────────────┤                               │
│  By Channel      │  Trend (column)           │                               │
│  (donut)         │  Year-Month + Parameter   │                               │
├──────────┬───────┼───────────┬───────────────┴───────────────────────────────┤
│ % Colour │% Prod │ % Animal  │ % Occasion                                    │
└──────────┴───────┴───────────┴───────────────────────────────────────────────┘
```

### 7.9 Visual interaction matrix

| Visual | Filtered by slicers | Notes |
|--------|---------------------|-------|
| KPI multi-card | Yes | Fixed measures; values only |
| Trend column | Yes | Parameter switches Y measure; X is fixed Year-Month |
| Channel / State / Donuts | Yes | Values follow Parameter |
| Parameter slicer | — | Re-routes `Selected Metric Value` on charts |

### 7.10 Formatting standards

| Element | Rule |
|---------|------|
| Currency | AUD, 0 decimals on cards |
| Page background | `#FDE8EF` |
| Visual backgrounds | `#FFFFFF` (header) / card styling per theme |
| Email | Never in any field well |

### 7.11 Theme color mapping

| Theme slot | Hex |
|------------|-----|
| background | `#FDE8EF` |
| foreground | `#9B6B7A` |
| foregroundNeutralSecondary | `#D4607F` |
| tableAccent | `#E8799E` |
| backgroundNeutral (cards) | `#F9C8D9` |
| dataColors[0–5] | `#FF69B4`, `#FF9BAA`, `#DA70D6`, `#FFDAB9`, `#E0B0C0`, `#FA8072` |
| good | `#FFB6C1` |

Theme file: `Yarn Petals..Report/StaticResources/RegisteredResources/YarnPetalsTheme.json`

---

## 8. Build checklist

- [x] Import `Universal.xlsx` / `Orders` as **Orders**
- [x] Create **DimDate** (mark as date table); relate to `Orders[Date]`
- [x] Create **Metrics** table — **12 measures** (Section 5; no PY/YoY)
- [x] Create field parameter **`Parameter`**
- [x] Validate: Net Sales = **77601.98**; Orders Count = **1132**; Total Customers = **744**
- [x] Build page per Section 7 (16 visuals)
- [x] KPI multi-card — values only, no reference labels
- [x] Confirm `Email` not in any visual field well
- [x] Test Parameter on donuts, channel, state, trend column
- [x] Save `Yarn Petals..pbip`

---

## 9. UAT / Definition of Done

| # | Check | Pass |
|---|-------|------|
| 1 | Net Sales = Excel `SUM(Total)` unfiltered (**77601.98**) | ☐ |
| 2 | Orders Count = **1132** distinct orders | ☐ |
| 3 | Total Customers = **744** distinct `Name` | ☐ |
| 4 | Six filters + Parameter filter visuals | ☐ |
| 5 | Parameter switches donuts / channel / state / trend column | ☐ |
| 6 | Trend uses **Year-Month** only | ☐ |
| 7 | KPI multi-card shows **no** PY/YoY reference labels | ☐ |
| 8 | Four donuts ≈ 100% per chart (percent of grand total) | ☐ |
| 9 | Email not visible on report | ☐ |
| 10 | Pink theme applied | ☐ |

---

## 10. Requirement traceability (FR8–FR16)

| FR | How this dashboard addresses it |
|----|----------------------------------|
| FR8 Net Sales | KPI multi-card + Parameter |
| FR9 Sold Bundles | KPI slot (`Orders Count`) |
| FR10 Multi-filter | Zone B slicer row |
| FR11 Monthly sales trend | Trend column on `DimDate[Year-Month]` |
| FR12 % Colour | F1 donut + Percent of grand total |
| FR13 % Animal | F3 donut |
| FR14 % Occasion | F4 donut |
| FR15 Orders by channel | E1 donut (`Selected Metric Value`) |
| FR16 Branding | Section 7.10–7.11 |
| % Product | F2 donut |
| Total Customer | KPI multi-card |
| State | Slicer + E2 bar |

---

## 11. Decisions log

| Topic | Decision |
|-------|----------|
| Data file | **`Universal.xlsx`** sheet `Orders` |
| Model | `Orders` + `DimDate` + `Metrics` + `Parameter` |
| Customers | `DISTINCTCOUNT(Name)` = **744** (current merge) |
| Bundles measure | Single measure: **Orders Count**; UI label Sold Bundles |
| % measures | None; visual percent of total |
| PY / YoY / Growth KPI | **Not used** |
| Parameter | Net Sales vs Orders Count on charts |
| Time Grain | **Not implemented** |
| Line chart | **Not implemented** |
| KPI layout | **One multi-card** visual (values only) |
| Email | Leave column unchanged; hide on report |

---

*Last updated: no PY/YoY; 12 measures; merged data; 16 visuals. See `POWER_BI_MEASURES_GUIDE.md`.*

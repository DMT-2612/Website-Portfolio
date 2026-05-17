# Yarn Petals — Data Pipeline & Power BI Dashboard

End-to-end analytics for Yarn Petals: clean and merge multiple order sources in Python, then report in a single-page Power BI executive dashboard.

**Status:** Delivered  
**Client:** Ivy (Yarn Petals)  
**Prepared by:** Minh Duc

---

## Pipeline overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│  RAW DATA (raw data/)                                                   │
│  • Shopify.csv              — Shopify export                            │
│  • Shopify_cleaned.xlsx     — cleaned Shopify (ETL intermediate)        │
│  • Order - 2025.xlsx        — manual / staff-entered 2025 orders        │
│  • Order_cleaned.xlsx       — cleaned manual & social orders            │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PYTHON ETL (Google Colab)                                              │
│  Clean · map · standardise · generate missing order numbers             │
│  → https://colab.research.google.com/drive/1eZErs4CXMtYiduAaJM33mViKct667ykK │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  UNIVERSAL DATASET                                                      │
│  Universal.xlsx  (sheet: Orders) — single source of truth               │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  POWER BI                                                               │
│  pbip/Yarn Petals..pbip  →  Sales Dashboard (16 visuals)              │
└─────────────────────────────────────────────────────────────────────────┘
```

Power BI loads `Universal.xlsx` / **`Orders`** as-is. Business rules and merging are applied upstream in Colab, not in the semantic model.

---

## Quick start

### 1. Refresh data (Colab)

1. Place updated raw files under `raw data/` (see table below).
2. Open the [Python ETL notebook](https://colab.research.google.com/drive/1eZErs4CXMtYiduAaJM33mViKct667ykK#scrollTo=uxMgEK__XIOY) in Google Colab.
3. Run all cells and export **`Universal.xlsx`** to the project root (same folder as this README).

### 2. Open the dashboard

1. Open **`pbip/Yarn Petals..pbip`** in Power BI Desktop.
2. If the data path changed, update the `Orders` query to point at `Universal.xlsx` (sheet **`Orders`**).
3. **Home → Refresh** and confirm unfiltered totals:

| Measure | Expected |
|---------|----------|
| Net Sales | **77,601.98** AUD |
| Orders Count | **1,132** |
| Total Customers | **744** |

---

## Repository structure

```
├── README.md
├── PROJECT REQUIREMENT Doc.md      # Functional & business requirements
├── POWER_BI_DASHBOARD_PLAN.md      # As-built layout, visuals, validation
├── POWER_BI_MEASURES_GUIDE.md      # DAX, model steps, troubleshooting
├── Universal.xlsx                  # Merged dataset (not committed if sensitive)
├── raw data/
│   ├── Shopify.csv
│   ├── Shopify_cleaned.xlsx
│   ├── Order - 2025.xlsx
│   └── Order_cleaned.xlsx
├── pbip/
│   └── Yarn Petals..pbip           # Power BI project (report + semantic model)
├── scripts/                        # PBIP validation helpers
└── build-report-visuals.ps1        # Regenerate report visual JSON (advanced)
```

---

## Raw data inputs

| File | Description |
|------|-------------|
| `raw data/Shopify.csv` | Raw Shopify order export |
| `raw data/Shopify_cleaned.xlsx` | Shopify after cleaning and column mapping |
| `raw data/Order - 2025.xlsx` | Manual order file (staff input) |
| `raw data/Order_cleaned.xlsx` | Manual and social-media orders after standardisation |

The Colab notebook merges these streams into one universal schema (Date, Order Number, Name, Sale Channels, Product, Animals, Colour, Occasions, Shipping Method, Shipping Fee, Product Price, Total, State, Email).

---

## Power BI deliverable

| Item | Detail |
|------|--------|
| Report | One page — **Sales Dashboard** (1280×720, Yarn Petals pink theme) |
| Model | `Orders` + `DimDate` + `Metrics` + field parameter `Parameter` |
| KPIs | Net Sales, Sold Bundles (Orders Count), Total Customers |
| Filters | Product, Animal, Colour, Date (Between), Occasion, State + Parameter |
| Charts | Channel donut, monthly trend column, state bar, four % distribution donuts |

**Privacy:** `Email` remains in the model but must not appear on any report visual.

Detailed build specs:

- [POWER_BI_DASHBOARD_PLAN.md](POWER_BI_DASHBOARD_PLAN.md) — layout zones, visual inventory, validation baseline
- [POWER_BI_MEASURES_GUIDE.md](POWER_BI_MEASURES_GUIDE.md) — all 12 DAX measures and step-by-step model setup

---

## Design decisions

| Topic | Decision |
|-------|----------|
| Data file | **`Universal.xlsx`**, sheet **`Orders`** at project root |
| Model shape | Star-lite: `Orders` + `DimDate` only (no separate product/animal dims) |
| Comparisons | No prior year, YoY %, growth KPI, or time-grain toggle |
| Chart metric switch | Field parameter **`Parameter`**: Net Sales vs Orders Count on charts only |
| KPI card | Fixed three measures; **not** driven by Parameter |
| Trend | Clustered column on `DimDate[Year-Month]` only (no line chart) |
| % breakdowns | Visual **Percent of grand total** — no dedicated % DAX measures |
| Sold Bundles | Display label for `Orders Count` (one row per order) |
| Customers | `DISTINCTCOUNT(Orders[Name])` |
| Email | Keep in model; exclude from all visuals |

---

## Helper scripts

Run from the repository root in PowerShell:

| Script | Purpose |
|--------|---------|
| `scripts/validate-pbip-theme.ps1` | Compare report theme colours to the Yarn Petals palette |
| `scripts/validate-pbip-parameters.ps1` | Check field-parameter table metadata in the semantic model |
| `scripts/validate-pbip-relationship.ps1` | Validate `DimDate` → `Orders` relationship cardinality |
| `scripts/validate-yoy-dates.ps1` | Summarise date/year totals from `Universal.xlsx` |
| `build-report-visuals.ps1` | Regenerate PBIP visual JSON for the Sales Dashboard page |

---

## Updating data after go-live

1. Add or replace files in `raw data/` (new Shopify export, manual orders, etc.).
2. Re-run the [Colab ETL notebook](https://colab.research.google.com/drive/1eZErs4CXMtYiduAaJM33mViKct667ykK#scrollTo=uxMgEK__XIOY).
3. Overwrite **`Universal.xlsx`** at the project root.
4. Open `pbip/Yarn Petals..pbip` → **Refresh** → re-check KPI totals against Excel.

---

## Related documentation

| Document | Contents |
|----------|----------|
| [PROJECT REQUIREMENT Doc.md](PROJECT%20REQUIREMENT%20Doc.md) | Business problem, FR1–FR16, schema, business rules |
| [POWER_BI_DASHBOARD_PLAN.md](POWER_BI_DASHBOARD_PLAN.md) | As-built dashboard specification |
| [POWER_BI_MEASURES_GUIDE.md](POWER_BI_MEASURES_GUIDE.md) | DAX catalogue and build steps |

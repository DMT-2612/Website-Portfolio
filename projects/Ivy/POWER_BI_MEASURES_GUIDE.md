# Power BI Measures & Build Guide — Yarn Petals

**Client:** Ivy  
**Prepared By:** Minh Duc  
**Project:** Yarn Petals Data Transformation & Dashboard (Phase 5)  
**Artifact:** `Yarn Petals..pbip`  
**Data:** `Universal.xlsx` → sheet **`Orders`**  
**Layout reference:** `POWER_BI_DASHBOARD_PLAN.md`  
**Language:** English (report UI)

---

## 1. What you are building

| Item | Detail |
|------|--------|
| Model | `Orders` + `DimDate` + `Metrics` + field parameter **`Parameter`** |
| Measures | **12** — 3 core KPIs + dynamic + chart titles |
| Comparisons | **None** — no PY, YoY %, Growth KPI, MoM, PM |
| Parameter | **Net Sales** vs **Orders Count** on charts (`Selected Metric Value`) |
| Trend | **Clustered column** on `DimDate[Year-Month]` — no line chart, no Time Grain |
| % donuts | **No** `% by Colour` DAX — use **Percent of grand total** on visuals |
| KPI UI | **One multi-card** — three values, **no reference labels** |

### Validation targets (unfiltered)

| Measure | Expected |
|---------|----------|
| Net Sales | **77,601.98** AUD |
| Orders Count | **1,132** |
| Total Customers | **744** (distinct `Name`) |
| Row count | **1,132** |

---

## 2. Model structure

```
DimDate[Date] ──1──*── Orders[Date]

Orders           all columns from Universal.xlsx (sheet Orders)
DimDate          calendar + Year, Month, Year-Month
Metrics          DAX measures
Parameter        field parameter (Net Sales | Orders Count)
```

**Tables (4):** `Orders`, `DimDate`, `Metrics`, `Parameter`

---

## 3. Step-by-step — semantic model

### Step 1 — Import data

1. Open **Power BI Desktop** → open `Yarn Petals..pbip`.
2. **Home → Get data → Excel** → select `Universal.xlsx`.
3. Select sheet **`Orders`** → **Transform Data** (optional checks only):
   - `Date` → **Date**
   - `Total`, `Product Price`, `Shipping Fee` → numeric types
   - Do **not** remove or edit `Email`
4. **Close & Apply**.
5. Rename query/table to **`Orders`**.

> Current M partition path in repo: `Universal.xlsx` (update path if file moves).

---

### Step 2 — Create `DimDate`

**Modeling → New table**:

```dax
DimDate =
ADDCOLUMNS (
    CALENDAR ( MIN ( Orders[Date] ), MAX ( Orders[Date] ) ),
    "Year", YEAR ( [Date] ),
    "Month Number", MONTH ( [Date] ),
    "Month", FORMAT ( [Date], "MMM" ),
    "Year-Month", FORMAT ( [Date], "YYYY-MM" ),
    "Year-Month Sort", YEAR ( [Date] ) * 100 + MONTH ( [Date] )
)
```

**Sort columns**

1. `DimDate[Month]` → **Sort by column** → `Month Number`
2. `DimDate[Year-Month]` → **Sort by column** → `Year-Month Sort`

**Mark as date table**

1. Select **`DimDate`**
2. **Table tools → Mark as date table**
3. Date column: **`Date`**

`DimDate` is used for the Date slicer and trend axis (`Year-Month`) only — not for PY/YoY measures.

---

### Step 3 — Relationship

1. **Model view** → drag **`DimDate[Date]`** onto **`Orders[Date]`**
2. Cardinality: **One to many** (`DimDate` → `Orders`)
3. Cross-filter: **Single**
4. Active: **Yes**

Remove any auto-created `LocalDateTable_*` on `Orders[Date]`.

---

### Step 4 — Create empty `Metrics` table

```dax
Metrics = { 1 }
```

Hide column **`Value`** in report view. Create all measures on **`Metrics`**.

---

### Step 5 — Core measures

**Display folder:** `Performance Metrics`

```dax
Net Sales = SUM ( Orders[Total] )
```
- Format: **Currency** `AUD`, 0 decimals

```dax
Orders Count = DISTINCTCOUNT ( Orders[Order Number] )
```
- Format: **Whole number**

```dax
Total Customers = DISTINCTCOUNT ( Orders[Name] )
```
- Format: **Whole number**

**Do not create:** `* PY`, `* YoY %`, `* Growth KPI`, `Selected Metric Value PY`.

---

### Step 6 — Field parameter: `Parameter`

**Modeling → New parameter → Fields**

| Setting | Value |
|---------|--------|
| Name | `Parameter` |
| Add measures | `Net Sales`, `Orders Count` |
| Slicer | **Tile** (top-right of report) |

Partition source (as-built):

```dax
{
    ("Net Sales", NAMEOF('Metrics'[Net Sales]), 0),
    ("Orders Count", NAMEOF('Metrics'[Orders Count]), 1)
}
```

**Dynamic measures** — **Display folder:** `Dynamic`

```dax
Selected Metric Value =
SWITCH (
    SELECTEDVALUE ( Parameter[Parameter Order] ),
    0, [Net Sales],
    1, [Orders Count],
    [Orders Count]
)
```

> Use **`Parameter[Parameter Order]`** (0 = Net Sales, 1 = Orders Count).

**Display folder:** `Title`

```dax
Selected Metric Label =
SWITCH (
    SELECTEDVALUE ( Parameter[Parameter Order] ),
    0, "Net Sales",
    1, "Orders Count",
    "Net Sales"
)
```

---

### Step 7 — Chart title measures

Bind to visual **Title → fx → Field value**:

```dax
Chart Title Trend = [Selected Metric Label] & " Trend"

Chart Title Channel = [Selected Metric Label] & " by Sales Channel"

Chart Title State = [Selected Metric Label] & " by State"

Chart Title Colour = [Selected Metric Label] & " by Colour"

Chart Title Product = [Selected Metric Label] & " by Product"

Chart Title Animal = [Selected Metric Label] & " by Animal"

Chart Title Occasion = [Selected Metric Label] & " by Occasion"
```

**Display folder:** `Title` for all seven.

---

## 4. Measure inventory (12)

| # | Measure | Folder | Format |
|---|---------|--------|--------|
| 1 | Net Sales | Performance Metrics | Currency AUD |
| 2 | Orders Count | Performance Metrics | Whole number |
| 3 | Total Customers | Performance Metrics | Whole number |
| 4 | Selected Metric Value | Dynamic | Inherit |
| 5 | Selected Metric Label | Title | Text |
| 6 | Chart Title Trend | Title | Text |
| 7 | Chart Title Channel | Title | Text |
| 8 | Chart Title State | Title | Text |
| 9 | Chart Title Colour | Title | Text |
| 10 | Chart Title Product | Title | Text |
| 11 | Chart Title Animal | Title | Text |
| 12 | Chart Title Occasion | Title | Text |

**Removed / not used:** all `* PY`, `* YoY %`, `* Growth KPI`, `Selected Metric Value PY`, MoM, PM, Time Grain.

---

## 5. Validate measures

Temporary table visual:

| Measure |
|---------|
| Net Sales |
| Orders Count |
| Total Customers |

**Clear all slicers.** Expected:

| Measure | Value |
|---------|-------|
| Net Sales | 77,601.98 |
| Orders Count | 1,132 |
| Total Customers | 744 |

---

## 6. Step-by-step — report page (as-built)

**Page name:** `Sales Dashboard`  
**Canvas:** 1280 × 720, **Fit to page**, background `#FDE8EF`

### 6.1 Header

| Visual | Details |
|--------|---------|
| Text box | `Yarn Petals — Sales Dashboard` — 20pt Semibold `#9B6B7A` |
| Parameter slicer | `Parameter[Parameter]` — tile, top-right |

### 6.2 Slicers — single row (y ≈ 48)

| Slicer | Field |
|--------|-------|
| Product | `Orders[Product]` |
| Animal | `Orders[Animals]` |
| Colour | `Orders[Colour]` |
| Date | `DimDate[Date]` — **Between** |
| Occasion | `Orders[Occasions]` |
| State | `Orders[State]` — multi-select |

### 6.3 KPI multi-card

| Property | Value |
|----------|--------|
| Type | **cardVisual** (one visual) |
| Data | `Net Sales`, `Orders Count`, `Total Customers` |
| Category labels | Net Sales, **Sold Bundles**, Total Customers |
| Reference labels | **Off** — do not add Growth KPI or PY |

**Do not** bind Parameter to this visual.

### 6.4 Trend column

| Role | Field |
|------|-------|
| X-axis | `DimDate[Year-Month]` |
| Y-axis | Measures + **field parameter** `Parameter[Parameter]` |
| Title | `Metrics[Chart Title Trend]` |

No second series (no PY line).

### 6.5–6.7 Charts

Same as plan Section 7: channel donut, state bar, four distribution donuts — all use `Selected Metric Value` and dynamic `Chart Title *` measures.

### 6.8 Privacy

- **`Email`** not on any visual.
- Do not delete `Orders[Email]` from the model.

---

## 7. How Parameter behaves

| Parameter selection | Charts show |
|---------------------|-------------|
| Net Sales | Sum of `Total` (AUD) |
| Orders Count | Distinct order count |

**KPI multi-card ignores Parameter.**

**Percent donuts:** **% of grand total** from `[Selected Metric Value]`.

---

## 8. DAX patterns reference

### Field parameter switch

```dax
Selected Metric Value =
SWITCH (
    SELECTEDVALUE ( Parameter[Parameter Order] ),
    0, [Net Sales],
    1, [Orders Count],
    [Orders Count]
)
```

### Core KPIs

```dax
Net Sales = SUM ( Orders[Total] )
Orders Count = DISTINCTCOUNT ( Orders[Order Number] )
Total Customers = DISTINCTCOUNT ( Orders[Name] )
```

---

## 9. Troubleshooting

| Issue | Likely cause | Fix |
|-------|----------------|-----|
| Time intelligence error | `DimDate` not marked | Mark date table on `DimDate[Date]` |
| `Selected Metric Value` blank | Wrong SWITCH column | Use `Parameter[Parameter Order]` |
| Year-Month sorts wrong | Sort not set | Sort `Year-Month` by `Year-Month Sort` |
| Customers ≠ 744 | Stale Excel | Re-import `Universal.xlsx` |
| Double counting | Extra date relationships | Delete `LocalDateTable_*` |
| % donuts ≠ 100% | Rounding / blanks | Hide blank legend entries |
| Old PY measures in Desktop | Stale model | Delete measures in Desktop or refresh from TMDL |

---

## 10. Build completion checklist

- [x] `Orders` loaded from `Universal.xlsx` (1,132 rows)
- [x] `DimDate` created, sorted, marked as date table
- [x] Relationship `DimDate[Date]` → `Orders[Date]`
- [x] **12 measures** on `Metrics` (no PY/YoY)
- [x] `Parameter` field parameter created
- [x] Validation: 77601.98 / 1132 / 744
- [x] Report page — 16 visuals, KPI without reference labels
- [x] Parameter drives charts only
- [x] `Email` not on any visual
- [x] Save `Yarn Petals..pbip`

---

*Guide version: no PY/YoY; 12 measures; merged data; Parameter-only charts.*

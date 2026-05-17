---
name: powerbi-dashboard-builder
description: >-
  Build Power BI dashboards from PBIP semantic models. Reads semantic models via MCP,
  designs KPIs, generates DAX, produces detailed build specifications. Use when building
  Power BI dashboards, defining measures, designing report pages, or generating a
  Power BI Dashboard Specification from any semantic model or dataset.
---

# Power BI Semantic Model to Dashboard Skill

## 1. Purpose

This skill enables Cursor to:
- Read and inspect Power BI PBIP semantic models via MCP (`connection_operations`, `table_operations`, `relationship_operations`, `measure_operations`)
- Design dashboards from the model up — never from visuals down
- Generate DAX measures grounded in actual fields
- Produce Level-3 Power BI Dashboard Build Specifications ready for direct implementation

**Out of scope:** insight generation, storytelling, business recommendations, domain-specific interpretation.

---

## 2. Core Workflow

```
Semantic Model → KPI Design → DAX Definition → Visual Mapping → Page Structure → Validation
```

**Never start from visuals. Always start from the model.**

Step sequence:
1. Connect to the model folder via MCP `ConnectFolder`
2. List all tables → classify fact/dimension
3. List all relationships → validate directions and cardinality
4. List all measures → identify existing KPI patterns
5. Inspect key fact table columns → determine grain
6. Design KPI catalogue from available fields only
7. Define DAX for each KPI
8. Map each KPI to a visual type
9. Assign KPIs and visuals to pages
10. Output the build specification

---

## 3. Semantic Model Inspection Protocol

Run these MCP calls in order for any PBIP project:

```
1. connection_operations { operation: "ConnectFolder", folderPath: "<path>/<model>.SemanticModel" }
2. table_operations       { operation: "List" }
3. relationship_operations { operation: "List" }
4. measure_operations     { operation: "List" }
5. table_operations       { operation: "Get", references: [{ name: "<FactTable>" }] }
```

**Checklist after inspection:**

- [ ] Identify fact tables (high row count, numeric columns, foreign keys)
- [ ] Identify dimension tables (low cardinality, descriptive columns, surrogate keys)
- [ ] Identify grain of each fact table (one row = one `[entity]`)
- [ ] Confirm a date/calendar table exists and is connected to the main fact date column
- [ ] Check for LocalDateTable instances (auto-created for extra date columns — expected but adds noise)
- [ ] Validate all relationships: cardinality, direction, active/inactive status
- [ ] Flag BothDirections relationships — high ambiguity risk
- [ ] Flag fact-to-fact relationships — many-to-many risk
- [ ] Confirm all measures are centralised (in one `All Measures` or named measure table)
- [ ] Identify display folder structure — use as KPI category map
- [ ] Note any field parameter tables (e.g., `Select Measure`, `KPI_Mode`, `xTD Parameter`)

**Modelling issues to detect:**

| Issue | Signal |
|---|---|
| Missing date table | No table with `dataCategory: "Time"` or no `Dim_Date` |
| Many-to-many | Both sides of relationship have `Many` cardinality |
| Inactive relationship | `isActive: false` — requires `USERELATIONSHIP()` in DAX |
| BothDirections filter | `crossFilteringBehavior: "BothDirections"` — check if intentional |
| Fact-to-fact join | `fromTable` and `toTable` both appear in fact list |
| Measures scattered across tables | Measures found in multiple tables without a central hub |
| Calculated columns in fact table | Increases model size; prefer DAX measures |

---

## 4. KPI Design System

For every KPI define:

| Field | Required |
|---|---|
| **Name** | Clear, unambiguous label |
| **Business meaning** | What does this number represent (no insight) |
| **Required fields** | Exact table[column] from the model |
| **DAX logic** | Pattern name + expression |
| **Category** | `performance` / `growth` / `ratio` / `segmentation` / `time` / `ranking` |
| **Format** | `$#,0.00` / `0` / `0.00%` / `#,0` |

**Standard KPI set for any transactional model:**

| KPI | Fields | Category |
|---|---|---|
| Total [Value] | SUM of primary numeric column | performance |
| Total [Entities] | DISTINCTCOUNT of entity key | performance |
| Avg [Value] per [Entity] | DIVIDE([Total Value], [Total Entities]) | ratio |
| [Value] PY | CALCULATE with DATEADD -1 YEAR | time |
| [Value] YoY Growth % | DIVIDE(current - PY, PY) | growth |
| [Value] Growth KPI | FORMAT with ▲▼ text label | growth |
| Max/Min [Value] | MAXX/MINX for reference lines | performance |

Add domain-specific KPIs only from fields confirmed in the model.

---

## 5. DAX Pattern Library

All patterns use generic placeholders. Replace with actual `Table[Column]` from the inspected model.

### Base measures
```dax
Total [Value] = SUM('FactTable'[NumericColumn])
Total [Entities] = DISTINCTCOUNT('FactTable'[EntityKey])
Avg [Value] = DIVIDE([Total Value], [Total Entities], 0)
[Value] % = DIVIDE([Total Value], CALCULATE([Total Value], ALL('DimTable')), 0)
```

### Growth rate
```dax
[Measure] PY =
    CALCULATE([Base Measure], DATEADD('Dim_Date'[Date], -1, YEAR))

[Measure] YoY Growth % =
    DIVIDE([Base Measure] - [Measure PY], [Measure PY], BLANK())

[Measure] Growth KPI =
    VAR _Growth = [Measure YoY Growth %]
    VAR _Year   = SELECTEDVALUE('Dim_Date'[Year])
    VAR _PY     = IF(HASONEVALUE('Dim_Date'[Year]), _Year - 1, "PY")
    RETURN
        IF(ISBLANK(_Growth), BLANK(),
           FORMAT(_Growth, "0.00%") & IF(_Growth > 0, " ▲", " ▼") & " vs " & _PY)
```

### Time intelligence
```dax
-- Year-to-date
[Measure] YTD  = CALCULATE([Base Measure], DATESYTD('Dim_Date'[Date]))
[Measure] PYTD = CALCULATE([Base Measure], DATESYTD(DATEADD('Dim_Date'[Date], -1, YEAR)))

-- Quarter-to-date
[Measure] QTD   = CALCULATE([Base Measure], DATESQTD('Dim_Date'[Date]))
[Measure] PYQTD = CALCULATE([Base Measure], DATESQTD(DATEADD('Dim_Date'[Date], -1, YEAR)))

-- Month-to-date
[Measure] MTD   = CALCULATE([Base Measure], DATESMTD('Dim_Date'[Date]))
[Measure] PYMTD = CALCULATE([Base Measure], DATESMTD(DATEADD('Dim_Date'[Date], -1, YEAR)))

-- Quarter-over-quarter
QoQ Growth % =
    VAR _Current  = [SelectedMeasureValue]
    VAR _Previous = CALCULATE([SelectedMeasureValue], DATEADD('Dim_Date'[Date], -1, QUARTER))
    RETURN DIVIDE(_Current - _Previous, _Previous)
```

### Ranking
```dax
[Entity] Rank =
    RANKX(ALL('DimTable'[EntityColumn]), [Base Measure], , DESC, Dense)

Top N Flag =
    IF([Entity Rank] <= N, 1, 0)
```

### Cumulative (Pareto)
```dax
Cumulative [Value] =
    CALCULATE([Base Measure],
        FILTER(ALL('DimTable'[EntityColumn]),
               [Entity Rank] <= MAX([Entity Rank])))

Cumulative % =
    DIVIDE([Cumulative Value], CALCULATE([Base Measure], ALL('DimTable')))
```

### RFM segmentation
```dax
-- Assumes RFM table with R, F, M columns and a lookup RankRFM/Dim_RankRFM table
Avg Recency   = AVERAGE('RFM'[R])
Avg Frequency = DIVIDE(SUM('RFM'[F]), DISTINCTCOUNT('RFM'[CustomerKey]))
Avg Monetary  = AVERAGE('RFM'[M])
```

### Cohort retention
```dax
Cohort Size =
    CALCULATE([Total Entities], 'FactTable'[MonthOffset] = 0)

Retention Rate =
    DIVIDE([Total Entities], [Cohort Size], 0)
```

### CLV
```dax
Purchase Frequency   = DIVIDE([Total Orders], [Total Customers], 0)
AOV                  = DIVIDE([Total Value], [Total Orders], 0)
Customer Lifetime (months) = DATEDIFF(MIN('FactTable'[FirstDate]), TODAY(), MONTH)
CLV                  = [AOV] * [Purchase Frequency] * [Customer Lifetime (months)]
Revenue per Customer = DIVIDE([Total Value], [Total Customers], 0)
```

### Dynamic field parameter (requires field parameter table)
```dax
SelectedMeasureValue =
    SWITCH(
        MAX('Select Measure'[Select Measure]),
        "Measure A", [Measure A],
        "Measure B", [Measure B],
        BLANK()
    )

Dynamic Title =
    VAR _Measure = MAX('Select Measure'[Select Measure])
    VAR _Year    = MAX('Dim_Date'[Year])
    RETURN
        IF(ISBLANK(_Measure), "Select a Measure", _Measure & " - " & _Year)
```

### Conditional colour
```dax
Trend Color =
    VAR _Growth = [Measure YoY Growth %]
    RETURN
        IF(ISBLANK(_Growth), "#808080",
           IF(_Growth >= 0, "#00B050", "#FF0000"))
```

---

## 6. Semantic Model Quality Rules

**Required:**
- Star schema: fact tables connected to dimension tables only
- One active relationship per table pair
- Date table with contiguous date range, marked as date table
- All measures in a dedicated measure table with display folders
- Grain defined and documented per fact table
- Consistent naming: `Fact_`, `Dim_` prefixes (or equivalent)
- Surrogate keys for dimension joins (not natural keys)

**Display folder structure (enforce):**
```
Performance Metrics\
Time Intelligence\[Metric]\
Highlight\[Metric]\
Charts\[Visual]\
Title\
Tooltip\
[AnalysisGroup]\  (RFM, CLV, Cohort, QoQ)
```

**Anti-patterns:**

| Anti-pattern | Problem | Fix |
|---|---|---|
| Measures scattered across tables | Breaks discoverability | Centralise in `All Measures` |
| Calculated columns for ratios | Computed at refresh, not query time | Use measures instead |
| BothDirections on fact-to-fact | Ambiguous filter propagation | Set OneDirection or redesign |
| No date table | Time intelligence breaks | Add `Dim_Date` with CALENDAR() |
| Duplicate logic across measures | Maintenance risk | Create base measure, reference it |
| Dynamic titles as text columns | Cannot be context-aware | Use DAX measures with VAR |
| Naming mismatch (e.g., ATV = revenue ÷ customers, not ÷ transactions) | Misleading KPIs | Audit DIVIDE denominators |

---

## 7. Dashboard Page Blueprint

### Page 1 — Overview / KPI Summary
- **Purpose:** Single-screen status of all primary KPIs with period comparison
- **Required KPI types:** Total Value, Total Entities, Avg per Entity, YoY Growth KPI text
- **Visuals:** KPI cards (4–6), line chart (trend over time), donut (composition), bar chart (top dimension), slicer (year/period)
- **Layout:** KPI cards top row → line chart centre-left → donut centre-right → bar bottom

### Page 2 — Performance Analysis
- **Purpose:** Deep-dive on primary metric with dimensional breakdown
- **Required KPI types:** Base metric, PY, YoY Growth %, decomposition by dimensions
- **Visuals:** Line/area chart, clustered bar, decomposition tree, matrix
- **Layout:** Trend chart top → decomposition tree middle → matrix bottom

### Page 3 — Segment Analysis
- **Purpose:** Compare performance across categories, segments, or groups
- **Required KPI types:** Metric by segment, % share, growth per segment
- **Visuals:** Stacked bar, donut/pie, treemap, ribbon chart
- **Layout:** Donut top-left → stacked bar top-right → treemap bottom

### Page 4 — Time Analysis (xTD / QoQ)
- **Purpose:** Period-over-period analysis (MTD, QTD, YTD, QoQ)
- **Required KPI types:** xTD metric, PYXD comparison, xTD Growth %, QoQ Growth %
- **Visuals:** KPI cards (xTD values), line chart (QoQ), slicer (xTD mode: MTD/QTD/YTD)
- **Layout:** Mode slicer top → KPI cards row → comparison line chart → QoQ sparkline

### Page 5 — Segment / RFM Analysis
- **Purpose:** Customer or entity segmentation using RFM or custom scoring
- **Required KPI types:** Avg R, Avg F, Avg M, Customer count by segment
- **Visuals:** Treemap (segment size), scatter (R vs F), matrix (RFM scores), bar (segment distribution)
- **Layout:** Treemap left → scatter right → matrix bottom

### Page 6 — Retention / Cohort Analysis
- **Purpose:** Track entity retention over time from first activity
- **Required KPI types:** Cohort Size, Retention Rate by MonthOffset
- **Visuals:** Matrix (month × cohort with conditional formatting), line chart (retention curve)
- **Layout:** Matrix full-width → retention line chart bottom

### Page 7 — CLV Analysis
- **Purpose:** Customer lifetime value decomposition
- **Required KPI types:** CLV, AOV, Purchase Frequency, Customer Lifetime, Revenue per Customer MoM
- **Visuals:** KPI cards, line chart (Revenue per Customer over time), bar (CLV by segment), donut
- **Layout:** KPI cards top → line chart centre → bar/donut bottom

### Hidden Pages
- **Tooltip page:** Small (320×240), `type: "Tooltip"`, `visibility: "HiddenInViewMode"` — contains Selected Measure PY, YoY Growth %

---

## 8. Visual Mapping Rules

| Purpose | Visual Type | Key Fields |
|---|---|---|
| Single metric with comparison | Card / KPI visual | [Measure], [Measure] Growth KPI |
| Trend over time | Line chart | Axis: Date[Month/Year], Values: [Measure], secondary: [Measure PY] |
| Composition (2–5 categories) | Donut chart | Legend: Dim[Category], Values: [Measure] |
| Composition (many categories) | Treemap | Group: Dim[Segment], Values: [Measure] |
| Ranking / comparison | Clustered bar | Axis: Dim[Entity], Values: [Measure], conditional colour from [Trend Color] |
| Dimensional decomposition | Decomposition tree | Analyse: [Measure], Explain by: multiple Dim columns |
| Multi-metric performance | Matrix | Rows: Dim, Columns: Metrics, conditional formatting on values |
| Geographic distribution | Map / Azure Map | Location: Dim[City/Region], Size/Color: [Measure] |
| Pareto | Line + bar combo | Bar: [Measure] by entity, Line: [Cumulative %] |
| Cohort retention | Matrix | Rows: CohortMonth, Columns: MonthOffset, Values: [Retention Rate] |
| Retention curve | Line chart | Axis: MonthOffset, Values: [Retention Rate] |
| Scatter segmentation | Scatter chart | X: [Avg Recency], Y: [Avg Frequency], Size: [Avg Monetary] |

**Slicer rules:**
- Date slicers: always use Dim_Date columns, not fact date columns
- Single-value selection: use dropdown or tile slicer
- Year selector: tile slicer (discrete, 1 per row)
- Period mode (MTD/QTD/YTD): field parameter slicer bound to `xTD Parameter`

**Interaction rules:**
- KPI cards: set `visualInteractions → NoFilter` from slicers that should not affect them
- Tooltip page visuals: link via `visualTooltip → section` property
- Cross-filtering: enable `drillFilterOtherVisuals: true` on charts; disable on matrix row headers

---

## 9. Layout and UX Rules

**Visual hierarchy:**
1. KPI summary cards — top row, full width, 4–6 cards
2. Primary chart — centre-left, largest visual on page (35–40% of canvas)
3. Supporting charts — centre-right, secondary analysis
4. Dimensional breakdowns — bottom row

**Spacing:**
- Canvas size: 1600×900 or 1800×900 (FitToPage)
- Padding between visuals: minimum 8–10px
- Card height: 80–100px; do not stretch cards vertically
- Align visual edges to a grid; use equal widths for same-row visuals

**Slicer placement:**
- Year/date slicers: top-right or top-left, fixed position
- Category slicers: left panel or top strip
- Field parameter slicers (Select Measure, xTD Mode): top-right, tile style

**Clutter rules:**
- Maximum 8 data visuals per page (excluding slicers and text cards)
- No more than 2 chart types doing the same job on one page
- Remove visual borders unless using card containers
- Hide gridlines in matrix where conditional formatting provides context

**Dynamic titles:**
- All chart titles must use DAX measures with context-awareness (SELECTEDVALUE + FORMAT)
- Pattern: `[Measure Name] by [Dimension] - [Year]`
- If no selection: return "Select a Measure" or equivalent default text

---

## 9A. Colour Template and Theme Rules

### Extracted Colour System (Dark Purple Theme — Source)

All 3 dashboards use the identical theme: **Power BI Theme Generator - BIBB.PRO v2.04**.

| Role | Hex | Where Used |
|---|---|---|
| Page / canvas background | `#0D0D1A` | Page BG, slicer items, filter pane, card title background |
| Visual / card background | `#1E1E2F` | All visual backgrounds, visual borders, table row fills, input boxes |
| Primary accent | `#BF40BF` | Card accent bar, slicer selection, buttons, table outlines, gridlines, reference labels |
| Data colour 1 | `#8A2BE2` | Primary data series (blue-violet) |
| Data colour 2 | `#4B0082` | Secondary series (indigo) |
| Data colour 3 | `#7B68EE` | Tertiary series (medium slate blue) |
| Data colour 4 | `#DDA0DD` | Quaternary series (plum) |
| All text | `#FFFFFF` | All labels, titles, callouts, headers |
| Positive / good | `#38B64B` | KPI growth up, conditional formatting green |
| Negative / bad | `#EE1C25` | KPI growth down, conditional formatting red |
| Neutral | `#949599` | Neutral state, grey |
| Gradient high | `#00243A` | Conditional scale maximum |
| Gradient centre | `#007BC4` | Conditional scale mid |
| Gradient low | `#B2D7ED` | Conditional scale minimum |
| Divider | `#CCCCCC` | Card visual divider line |
| Gridlines | `#BF40BF66` | Chart value-axis gridlines (accent at 40% opacity) |
| Drop shadow | `#0B1215` | Visual shadows (disabled by default) |

**Core insight from extraction:** The source theme is a monochromatic dark-purple scheme. One dominant accent (`#BF40BF`) is applied to every interactive and decorative element. The data palette uses the same purple-violet hue family.

---

### Light Blue SaaS Palette (Transformed)

Transformation rules applied:
- Page/visual backgrounds: dark navy → light grey-blue and white
- Primary accent: purple `#BF40BF` → Microsoft blue `#0078D4` (hue shift only, same saturation level)
- Data colours: purple spectrum → blue spectrum (same positional brightness values)
- Text: white-on-dark → dark-on-light
- Semantic status colours: preserved exactly (green/red/grey unchanged)
- Gradient scale: recentred on blue axis

| Purpose | Colour Name | Hex |
|---|---|---|
| Page / canvas background | Canvas Blue-Grey | `#F0F4F8` |
| Visual / card background | Card White | `#FFFFFF` |
| Secondary background (inputs, filter pane) | Surface Light | `#F8FAFC` |
| Primary accent | Brand Blue | `#0078D4` |
| Accent hover | Brand Blue Dark | `#106EBE` |
| Accent selected / active | Brand Blue Deep | `#004578` |
| Accent subtle (bg tint) | Brand Blue Tint | `#EFF6FF` |
| Data colour 1 | Vivid Blue | `#0078D4` |
| Data colour 2 | Deep Blue | `#005A9E` |
| Data colour 3 | Sky Blue | `#40A0FF` |
| Data colour 4 | Light Blue | `#A8D4F5` |
| Data colour 5 | Navy | `#004578` |
| Data colour 6 | Cyan Blue | `#00B4D8` |
| Data colour 7 | Indigo Blue | `#4361EE` |
| Data colour 8 | Periwinkle | `#738DE7` |
| Primary text | Text Dark | `#1F2937` |
| Secondary text | Text Muted | `#6B7280` |
| On-accent text | Text On Blue | `#FFFFFF` |
| Visual border | Border Light | `#E2E8F0` |
| Gridlines | Grid Tint | `#0078D420` |
| Divider | Divider Grey | `#E5E7EB` |
| Drop shadow | Shadow Dark | `#1F293720` |
| Positive / good | Status Green | `#16A34A` |
| Negative / bad | Status Red | `#EE1C25` |
| Warning | Status Amber | `#F59E0B` |
| Neutral | Status Grey | `#949599` |
| Gradient high | Scale High | `#001D3D` |
| Gradient centre | Scale Mid | `#0078D4` |
| Gradient low | Scale Low | `#DBEAFE` |

---

### Colour Usage Rules

**KPI cards:**
- Card background: `#FFFFFF`
- Accent bar (top, 4px): `#0078D4`
- Card border: `#E2E8F0`
- Title text: `#6B7280` (secondary, above value)
- Value text: `#1F2937` (bold, 13px+)
- Reference label background: `#EFF6FF` (Brand Blue Tint)

**Charts (line, bar, donut, treemap):**
- Visual background: `#FFFFFF`
- Visual border: `#E2E8F0`
- Chart series: data colours 1–8 in order
- Gridlines: `#0078D420` (dotted)
- Axis labels: `#6B7280`
- Chart title: `#1F2937` (bold, 12px)
- Area fill under line: series colour at 50% transparency

**Slicers:**
- Slicer background: transparent (no fill)
- Slicer item background: `#F0F4F8`
- Selected item fill: `#0078D4` (solid)
- Selected item text: `#FFFFFF`
- Unselected item text: `#1F2937`
- Shape: rectangleRounded (curve 7)

**Page background:**
- Canvas: `#F0F4F8`
- Filter pane available: `#F0F4F8`
- Filter pane applied: `#FFFFFF`

**Text hierarchy:**
- Visual title: `#1F2937`, 12px, bold
- Axis labels / data labels: `#6B7280`, 7–8px
- Card value: `#1F2937`, 13px, bold
- Card label: `#6B7280`, 10px, above value
- Button text (on filled): `#FFFFFF`
- Button text (on light): `#1F2937`

**Borders and dividers:**
- Visual border: `#E2E8F0`, 0.5px, radius 5
- Card divider: `#E5E7EB`
- Table grid outline: `#0078D4`, 0.5px
- Table column headers: `#0078D41A` (Brand Blue at ~10% opacity)
- Table row fill (primary/secondary): `#FFFFFF` / `#F8FAFC`

**Buttons and navigation:**
- Default fill: transparent
- Hover fill: `#0078D4` at 97% transparency
- Selected fill: `#0078D4` at 85% transparency
- Active fill: `#0078D4` at 90% transparency
- Fully filled button: `#0078D4`, text `#FFFFFF`

---

### Semantic Status Colours

| State | Meaning | Hex |
|---|---|---|
| Positive / growth up | ▲ good performance | `#16A34A` |
| Negative / growth down | ▼ poor performance | `#EE1C25` |
| Warning | Threshold breach, anomaly | `#F59E0B` |
| Neutral / N/A | No comparison available | `#949599` |

**DAX — KPI status colour:**
```dax
KPI Status Color =
    VAR _Value = [KPI Measure]
    VAR _Target = [Target Measure]
    RETURN
        IF(ISBLANK(_Value), "#949599",
           IF(_Value >= _Target, "#16A34A", "#EE1C25"))
```

**DAX — Growth trend colour (used in Charts\\ display folder):**
```dax
Growth Trend Color =
    VAR _Growth = [Measure YoY Growth %]
    RETURN
        IF(ISBLANK(_Growth), "#949599",
           IF(_Growth >= 0, "#16A34A", "#EE1C25"))
```

---

### Accessibility Rules

- **Minimum contrast:** Body text on `#FFFFFF` background: `#1F2937` = 16.1:1 ratio (WCAG AAA)
- **Minimum contrast:** Secondary text `#6B7280` on `#FFFFFF` = 5.74:1 (WCAG AA)
- **Minimum contrast:** `#FFFFFF` on `#0078D4` = 4.6:1 (WCAG AA)
- **Never use colour alone:** Status colours (green/red) must always be paired with ▲▼ symbols or text labels
- **Avoid:** Red/green combinations without shape differentiation — add icon or label for colour-blind users
- **Font minimum:** 7px for data labels; 9px for card labels; 12px for chart titles
- **Slicer selected state:** Must differ in both colour AND shape/weight, not colour alone

---

### Power BI Theme JSON (Light Blue SaaS)

Copy this JSON as the theme file for any new dashboard. Filename convention: `light-blue-saas-theme.json`.

```json
{
  "name": "Light Blue SaaS",
  "$schema": "https://raw.githubusercontent.com/microsoft/powerbi-desktop-samples/main/Report%20Theme%20JSON%20Schema/reportThemeSchema-2.143.json",
  "dataColors": [
    "#0078D4",
    "#005A9E",
    "#40A0FF",
    "#A8D4F5",
    "#004578",
    "#00B4D8",
    "#4361EE",
    "#738DE7",
    "#0050A0",
    "#BFD9F0",
    "#2BA0C8",
    "#5F6B7C",
    "#EE1C25",
    "#F59E0B",
    "#949599",
    "#DBEAFE"
  ],
  "textClasses": {
    "callout": { "color": "#1F2937", "fontFace": "Segoe UI" },
    "header":  { "color": "#1F2937", "fontFace": "Segoe UI" },
    "label":   { "color": "#6B7280", "fontFace": "Segoe UI" },
    "largeTitle": { "color": "#1F2937", "fontFace": "Segoe UI" },
    "title":   { "color": "#1F2937", "fontFace": "Segoe UI" }
  },
  "bad":      "#EE1C25",
  "neutral":  "#949599",
  "good":     "#16A34A",
  "maximum":  "#001D3D",
  "minimum":  "#DBEAFE",
  "center":   "#0078D4",
  "tableAccent": "#0078D4",
  "firstLevelElements":  "#1F2937",
  "secondLevelElements": "#1F2937",
  "thirdLevelElements":  "#6B7280",
  "fourthLevelElements": "#6B7280",
  "background": "#F0F4F8",
  "secondaryBackground": "#FFFFFF",
  "visualStyles": {
    "*": {
      "*": {
        "background": [{ "color": { "solid": { "color": "#FFFFFF" } }, "transparency": 0 }],
        "border": [{ "color": { "solid": { "color": "#E2E8F0" } }, "radius": 5, "show": true, "width": 0.5 }],
        "divider": [{ "show": false, "width": 1 }],
        "categoryAxis": [{ "showAxisTitle": false }],
        "dropShadow": [{ "show": false }],
        "legend": [{ "position": "TopCenter", "showTitle": false, "fontSize": 7 }],
        "padding": [{ "top": 15 }, { "bottom": 15 }, { "left": 15 }, { "right": 15 }],
        "spacing": [{ "customizeSpacing": true, "spaceBelowTitle": 10 }],
        "subTitle": [{ "show": false, "fontSize": 11 }],
        "title": [{ "fontSize": 12, "bold": true }],
        "totals": [{ "show": true, "bold": true, "fontSize": 7 }],
        "valueAxis": [{
          "gridlineShow": true,
          "gridlineColor": { "solid": { "color": "#0078D420" } },
          "gridlineStyle": "dotted",
          "gridlineThickness": 1,
          "showAxisTitle": false
        }]
      }
    },
    "cardVisual": {
      "*": {
        "accentBar": [{ "$id": "default", "show": true, "width": 4, "position": "Top", "color": { "solid": { "color": "#0078D4" } } }],
        "background": [{ "show": true }],
        "border": [{ "show": true }],
        "divider": [{ "$id": "default", "show": true, "dividerColor": { "solid": { "color": "#E5E7EB" } } }],
        "label": [{ "$id": "default", "position": "aboveValue", "fontSize": 10 }],
        "layout": [{ "calloutSize": 60 }],
        "shapeCustomRectangle": [{ "$id": "default", "tileShape": "rectangleRounded", "rectangleRoundedCurve": 7 }],
        "title": [{ "fontSize": 9, "background": { "solid": { "color": "#F0F4F8" } } }],
        "value": [{ "$id": "default", "fontSize": 13, "horizontalAlignment": "left", "bold": true }]
      }
    },
    "slicer": {
      "*": {
        "background": [{ "show": false }],
        "header": [{ "show": false }],
        "items": [{ "background": { "solid": { "color": "#F0F4F8" } } }]
      }
    },
    "advancedSlicerVisual": {
      "*": {
        "fillCustom": [
          { "$id": "default", "fillColor": { "solid": { "color": "#0078D4" } }, "transparency": 90 },
          { "$id": "selected", "fillColor": { "solid": { "color": "#0078D4" } }, "transparency": 0 }
        ],
        "layout": [{ "style": "Cards" }],
        "shapeCustomRectangle": [{ "$id": "default", "tileShape": "rectangleRounded", "rectangleRoundedCurve": 7 }]
      }
    },
    "tableEx": {
      "*": {
        "columnHeaders": [{ "backColor": { "solid": { "color": "#0078D41A" } } }],
        "grid": [{ "gridHorizontal": true, "rowPadding": 3.5, "outlineColor": { "solid": { "color": "#0078D4" } }, "outlineWeight": 0.5 }],
        "values": [{ "backColorPrimary": { "solid": { "color": "#FFFFFF" } }, "backColorSecondary": { "solid": { "color": "#F8FAFC" } } }]
      }
    },
    "pivotTable": {
      "*": {
        "columnHeaders": [{ "backColor": { "solid": { "color": "#0078D41A" } } }],
        "grid": [{ "rowPadding": 5 }]
      }
    },
    "page": {
      "*": {
        "background": [{ "color": { "solid": { "color": "#F0F4F8" } }, "transparency": 0 }],
        "outspacePane": [{ "backgroundColor": { "solid": { "color": "#F0F4F8" } } }],
        "filterCard": [
          { "$id": "Available", "backgroundColor": { "solid": { "color": "#F0F4F8" } }, "foregroundColor": { "solid": { "color": "#1F2937" } }, "inputBoxColor": { "solid": { "color": "#FFFFFF" } }, "transparency": 0 },
          { "$id": "Applied",   "backgroundColor": { "solid": { "color": "#FFFFFF" } }, "foregroundColor": { "solid": { "color": "#1F2937" } }, "inputBoxColor": { "solid": { "color": "#FFFFFF" } }, "transparency": 0 }
        ]
      }
    },
    "actionButton": {
      "*": {
        "fill": [
          { "show": true },
          { "$id": "default", "transparency": 100 },
          { "$id": "hover",    "transparency": 97, "fillColor": { "solid": { "color": "#0078D4" } } },
          { "$id": "selected", "transparency": 85, "fillColor": { "solid": { "color": "#0078D4" } } }
        ],
        "text": [{ "$id": "default", "fontSize": 11, "horizontalAlignment": "center", "fontColor": { "solid": { "color": "#1F2937" } } }]
      }
    },
    "filledMap": { "*": { "mapStyles": [{ "mapTheme": "light" }] } },
    "donutChart": { "*": { "legend": [{ "show": false }], "labels": [{ "labelStyle": "Both" }] } },
    "pieChart":   { "*": { "legend": [{ "show": false }], "labels": [{ "labelStyle": "Both" }] } },
    "barChart":   { "*": { "legend": [{ "show": false }] } },
    "columnChart": { "*": { "legend": [{ "show": false }] } },
    "waterfallChart": { "*": { "legend": [{ "show": false }] } }
  }
}
```

---

## 10. Power BI Build Specification Format

When generating a dashboard specification, output this exact structure:

```markdown
# Power BI Dashboard Specification — [Project Name]

## Business Context
[One paragraph: domain, data source, intended audience — no insights]

## Data Summary
| Table | Type | Grain | Key Columns |
|---|---|---|---|

## Relationships
| From Table | From Column | To Table | To Column | Cardinality | Active | Direction |
|---|---|---|---|---|---|---|

## Model Issues and Fixes
| Issue | Table/Relationship | Risk | Fix |
|---|---|---|---|

## KPI Catalogue
| KPI Name | Business Meaning | Required Fields | DAX Pattern | Category | Format |
|---|---|---|---|---|---|

## DAX Measures
[Full DAX for every KPI, grouped by display folder]

## Pages

### Page N — [Page Name]
**Purpose:** [One sentence, no insight]
**KPIs displayed:** [List]
**Visuals:**
| Visual # | Type | Fields | Purpose |
|---|---|---|---|

**Layout:** [Describe grid arrangement]
**Slicers:** [List with binding field]
**Interactions:** [List any NoFilter or custom interactions]

## Theme

### Palette
| Purpose | Colour Name | Hex |
|---|---|---|
| Page background | Canvas Blue-Grey | `#F0F4F8` |
| Card background | Card White | `#FFFFFF` |
| Primary accent | Brand Blue | `#0078D4` |
| Text primary | Text Dark | `#1F2937` |
| Text secondary | Text Muted | `#6B7280` |
| Border | Border Light | `#E2E8F0` |
| Positive | Status Green | `#16A34A` |
| Negative | Status Red | `#EE1C25` |
| Warning | Status Amber | `#F59E0B` |
| Neutral | Status Grey | `#949599` |

### Theme File
Apply `light-blue-saas-theme.json` (defined in §9A) via: View → Themes → Browse for themes.

### Usage Rules
- Card accent bar: `#0078D4`, top position, 4px width
- Table column headers: `#0078D41A` (Brand Blue 10%)
- Gridlines: `#0078D420` dotted
- Slicer selected: `#0078D4` solid fill, white text
- Status colours: always pair with ▲▼ symbols

## Filters and Interactions
[Page-level and report-level filters]

## Validation Checklist
[From Section 11]
```

---

## 11. Validation Checklist

**Model:**
- [ ] Every fact table has an active relationship to Dim_Date
- [ ] No inactive relationships left unaddressed
- [ ] No BothDirections relationships on fact-to-fact joins
- [ ] All measures in centralised table with display folders
- [ ] Date table has contiguous range covering all fact dates

**DAX:**
- [ ] All DIVIDE calls have explicit alternate result (0 or BLANK())
- [ ] Time intelligence uses Dim_Date columns, not fact date columns
- [ ] No FILTER(ALL(...)) overuse — prefer REMOVEFILTERS or ALLEXCEPT
- [ ] KPI Growth text measures handle ISBLANK(PY) case
- [ ] Dynamic title measures return fallback text when no context

**KPI:**
- [ ] Every KPI traceable to an exact field in the inspected model
- [ ] No KPIs invented from assumed fields
- [ ] Base measure defined before derivative measures (PY, Growth)
- [ ] Highlight measures (Max/Min) defined for reference lines

**Visuals:**
- [ ] Every visual has a defined axis, legend, and value mapping
- [ ] Trend colour measures bound to correct conditional formatting field
- [ ] Tooltip page linked where applicable
- [ ] No duplicate visual type serving the same analytical purpose on one page

**Layout:**
- [ ] Canvas size matches intended display (1600×900 or 1800×900)
- [ ] No more than 8 data visuals per page
- [ ] Dynamic titles used on all charts
- [ ] Slicers positioned consistently across pages

**Performance:**
- [ ] No large calculated columns in fact tables
- [ ] SUMX used only when row-level multiplication required (e.g., Sales × Discount)
- [ ] Heavy RFM/Cohort tables are pre-computed, not calculated on-the-fly

---

## 12. Common Problems and Fixes

| Problem | Signal | Fix |
|---|---|---|
| KPI duplication | Two measures with same formula, different names | Consolidate; rename with clear suffix (PY, YTD, etc.) |
| Misleading average | ATV = Revenue ÷ Customers instead of ÷ Transactions | Audit every DIVIDE denominator against stated meaning |
| Missing base measure | PY measure references raw column, not base measure | Always build PY from `[Base Measure]` |
| Unclear DAX naming | `Measure1`, `Calc`, `Test` | Rename to full KPI name before publishing |
| Cluttered overview page | > 8 visuals, 3+ visual types doing the same job | Split into Overview + Performance Analysis pages |
| Broken time intelligence | DATEADD returns BLANK | Verify Dim_Date is marked as date table and has contiguous range |
| Ambiguous filter | BothDirections causes double-counting | Switch to OneDirection; use CROSSFILTER in specific measures only |
| RFM table not filtering fact | Fact → RFM relationship direction wrong | Ensure RFM filters fact (Many from fact, One on RFM) |
| Dynamic titles blank | SELECT parameter table not populated | Verify Select Measure / KPI_Mode table has data rows |
| Cohort retention always 100% | MonthOffset column not populated correctly | Validate MonthOffset = 0 rows exist in cohort base month |

---

## 13. Lessons from 3 Dashboards

### Verified Reusable Patterns

**Model architecture (all 3 use this):**
- Central fact table (`Fact_Transaction` / `Fact_Order` / `FactSales`) → surrogate keys → dimension tables
- `Dim_Date` as the primary date dimension; multiple `LocalDateTable_*` for secondary date columns
- Separate `All Measures` table as measure hub (92–175 measures per model)
- `Select Measure` / `Select Measures` field parameter table for dynamic KPI selection
- `RFM` calculated table + `Dim_RankRFM` / `RankRFM` lookup table for segment scoring

**Measure folder taxonomy (consistent across all 3):**
```
Performance Metrics\          → base KPIs
Time Intelligence\[Metric]\   → PY, YoY Growth %, Growth KPI
Highlight\[Metric]\           → Max, Min (for reference lines)
Charts\[VisualName]\          → dynamic labels, colours, titles
Title\                        → dynamic visual titles
Tooltip\                      → cross-visual tooltip measures
[AnalysisGroup]\              → RFM, CLV, Cohort, QoQ
```

**KPI Growth KPI text pattern (identical in all 3):**
```dax
VAR _Growth = [Measure YoY Growth %]
VAR _Year   = SELECTEDVALUE('Dim_Date'[Year])
VAR _PY     = IF(HASONEVALUE('Dim_Date'[Year]), _Year - 1, "PY")
RETURN IF(ISBLANK(_Growth), BLANK(),
          FORMAT(_Growth, "0.00%") & IF(_Growth > 0, " ▲", " ▼") & " vs " & _PY)
```

**Page set (all 3 share):**
Overview / KPI Summary → QoQ Analysis → CLV Analysis → RFM Analysis → Cohort Analysis → Retention Rate → Hidden Tooltip

**Unique to ecommerce-orders:** xTD Parameter table enabling dynamic MTD/QTD/YTD mode switching via slicer — one of the most reusable patterns for performance dashboards.

**Unique to super-store:** Sparkline measures (`Sales Sparkline`, `Profit Sparkline`) as mini-trend within matrix; Churn Rate and Gross Profit Margin expand CLV analysis.

**Unique to bank_transaction:** Fact_Anomaly linked 1:1 to Fact_Transaction with BothDirections — used for anomaly overlay analysis; requires care to avoid double-counting.

### Anti-patterns Found

| Anti-pattern | Where Found | Impact |
|---|---|---|
| LocalDateTable explosion | All 3 | 4–7 extra auto-tables per model; visual clutter in relationship view |
| BothDirections on 1:1 fact join | bank_transaction (Fact_Anomaly) | Potential ambiguity; isolate with CROSSFILTER in measures |
| ATV = Revenue ÷ Customers (not ÷ Transactions) | bank_transaction | Name implies per-transaction but divides by customers |
| 93–176 measures with ~30 being chart labels/titles | All 3 | Measure table bloat; display folders mitigate but not eliminate |
| Cohort MonthOffset stored in fact table as column | bank_transaction, ecommerce | Adds row-level data to fact; consider moving to RFM/computed table |

---

## 14. Cursor Behaviour Rules

When this skill is active, Cursor **must**:

1. **Always inspect the model first** — run `ConnectFolder` + `List` calls before any design work
2. **Never invent fields** — every `Table[Column]` in DAX must appear in the inspected model output
3. **Clearly mark missing data** — if a required field is absent, state `[MISSING: field description]` in the spec
4. **Follow the workflow** — Model → KPI Design → DAX → Visual → Page → Validation. Do not skip steps.
5. **Use actual measure names** — if measures already exist in the model, reference them; do not redefine
6. **Prefer reusable base measures** — define one base measure, derive PY/YTD/QoQ from it
7. **Output Level-3 specifications** — include exact visual types, field bindings, layout positions, and interaction rules
8. **Flag modelling issues** — always include the Model Issues section in the spec, even if empty
9. **Respect scope** — no insights, no business recommendations, no domain assumptions beyond what the model confirms
10. **Use display folder structure** as the KPI category map — do not redesign what the model already organises

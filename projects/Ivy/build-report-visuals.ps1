$ErrorActionPreference = 'Stop'
$pagePath = Join-Path $PSScriptRoot 'Yarn Petals..Report\definition\pages\cb48b30cc8da4aad2bd0\visuals'
New-Item -ItemType Directory -Force -Path $pagePath | Out-Null

function New-Id { [guid]::NewGuid().ToString('N').Substring(0, 16) }
function Save-Visual($id, [string]$content) {
    $dir = Join-Path $pagePath $id
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Join-Path $dir 'visual.json'), $content, $utf8NoBom)
}

$schema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.7.0/schema.json'

# Header
$hid = New-Id
Save-Visual $hid @"
{
  "`$schema": "$schema",
  "name": "$hid",
  "position": { "x": 16, "y": 8, "z": 1000, "width": 900, "height": 48, "tabOrder": 0 },
  "visual": {
    "visualType": "textbox",
    "objects": {
      "general": [{
        "properties": {
          "paragraphs": [
            { "textRuns": [{ "value": "Yarn Petals — Sales Dashboard", "textStyle": { "fontWeight": "bold", "fontSize": "22pt", "color": "#9B6B7A" } }] },
            { "textRuns": [{ "value": "Executive overview · AUD · Source: Universal.xlsx", "textStyle": { "fontSize": "10pt", "color": "#D4607F" } }] }
          ]
        }
      }]
    }
  }
}
"@

function SlicerJson($id, $entity, $prop, $x, $w, $title) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": $x, "y": 72, "z": 0, "width": $w, "height": 80, "tabOrder": 0 },
  "visual": {
    "visualType": "slicer",
    "query": {
      "queryState": {
        "Values": {
          "projections": [{
            "field": { "Column": { "Expression": { "SourceRef": { "Entity": "$entity" } }, "Property": "$prop" } },
            "queryRef": "$entity.$prop",
            "nativeQueryRef": "$prop",
            "active": true
          }]
        }
      }
    },
    "objects": { "header": [{ "properties": { "title": { "expr": { "Literal": { "Value": "'$title'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

foreach ($s in @(
    @{ e='Orders'; p='Product'; x=8; w=200; t='Product' },
    @{ e='Orders'; p='Animals'; x=216; w=200; t='Animal' },
    @{ e='Orders'; p='Colour'; x=424; w=200; t='Colour' },
    @{ e='DimDate'; p='Date'; x=632; w=200; t='Date' },
    @{ e='Orders'; p='Occasions'; x=840; w=200; t='Occasion' },
    @{ e='Orders'; p='State'; x=1048; w=220; t='State' }
)) {
    $id = New-Id
    Save-Visual $id (SlicerJson $id $s.e $s.p $s.x $s.w $s.t)
}

function ParamSlicer($id, $entity, $prop, $x, $title) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": $x, "y": 160, "z": 0, "width": 620, "height": 48, "tabOrder": 0 },
  "visual": {
    "visualType": "slicer",
    "query": {
      "queryState": {
        "Values": {
          "projections": [{
            "field": { "Column": { "Expression": { "SourceRef": { "Entity": "$entity" } }, "Property": "$prop" } },
            "queryRef": "$entity.$prop",
            "nativeQueryRef": "$prop",
            "active": true
          }]
        }
      }
    },
    "objects": { "header": [{ "properties": { "title": { "expr": { "Literal": { "Value": "'$title'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (ParamSlicer $id 'Parameter' 'Parameter' 8 'Metric Mode')
$id = New-Id; Save-Visual $id (ParamSlicer $id 'Time Grain' 'Parameter' 640 'Time Grain')

# KPI multi-card is maintained manually in PBIP (182f0a566fb945f6) — no Growth KPI / PY reference labels

function LineJson($id) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": 8, "y": 296, "z": 0, "width": 560, "height": 96, "tabOrder": 0 },
  "visual": {
    "visualType": "lineChart",
    "query": {
      "queryState": {
        "Category": { "projections": [{ "field": { "Column": { "Expression": { "SourceRef": { "Entity": "Time Grain" } }, "Property": "Parameter" } }, "queryRef": "Time Grain.Parameter", "nativeQueryRef": "Parameter", "active": true }] },
        "Y": { "projections": [
          { "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "Metrics" } }, "Property": "Selected Metric Value" } }, "queryRef": "Metrics.Selected Metric Value", "nativeQueryRef": "Selected Metric Value" }
        ] }
      }
    },
    "objects": { "title": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'Trend'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (LineJson $id)

function ColJson($id) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": 8, "y": 400, "z": 0, "width": 560, "height": 96, "tabOrder": 0 },
  "visual": {
    "visualType": "clusteredColumnChart",
    "query": {
      "queryState": {
        "Category": { "projections": [{ "field": { "Column": { "Expression": { "SourceRef": { "Entity": "Time Grain" } }, "Property": "Parameter" } }, "queryRef": "Time Grain.Parameter", "nativeQueryRef": "Parameter", "active": true }] },
        "Y": { "projections": [{ "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "Metrics" } }, "Property": "Selected Metric Value" } }, "queryRef": "Metrics.Selected Metric Value", "nativeQueryRef": "Selected Metric Value" }] }
      }
    },
    "objects": { "title": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'Orders / Sales Trend'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (ColJson $id)

function DonutJson($id, $prop, $x, $title) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": $x, "y": 296, "z": 0, "width": 340, "height": 200, "tabOrder": 0 },
  "visual": {
    "visualType": "donutChart",
    "query": {
      "queryState": {
        "Category": { "projections": [{ "field": { "Column": { "Expression": { "SourceRef": { "Entity": "Orders" } }, "Property": "$prop" } }, "queryRef": "Orders.$prop", "nativeQueryRef": "$prop", "active": true }] },
        "Y": { "projections": [{ "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "Metrics" } }, "Property": "Selected Metric Value" } }, "queryRef": "Metrics.Selected Metric Value", "nativeQueryRef": "Selected Metric Value" }] }
      }
    },
    "objects": { "title": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'$title'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (DonutJson $id 'Sale Channels' 584 'By Sales Channel')

function BarJson($id) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": 936, "y": 296, "z": 0, "width": 336, "height": 200, "tabOrder": 0 },
  "visual": {
    "visualType": "clusteredBarChart",
    "query": {
      "queryState": {
        "Category": { "projections": [{ "field": { "Column": { "Expression": { "SourceRef": { "Entity": "Orders" } }, "Property": "State" } }, "queryRef": "Orders.State", "nativeQueryRef": "State", "active": true }] },
        "Y": { "projections": [{ "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "Metrics" } }, "Property": "Selected Metric Value" } }, "queryRef": "Metrics.Selected Metric Value", "nativeQueryRef": "Selected Metric Value" }] }
      }
    },
    "objects": { "title": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'By State'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (BarJson $id)

function DistDonut($id, $prop, $x, $title) {
@"
{
  "`$schema": "$schema",
  "name": "$id",
  "position": { "x": $x, "y": 508, "z": 0, "width": 300, "height": 198, "tabOrder": 0 },
  "visual": {
    "visualType": "donutChart",
    "query": {
      "queryState": {
        "Category": { "projections": [{ "field": { "Column": { "Expression": { "SourceRef": { "Entity": "Orders" } }, "Property": "$prop" } }, "queryRef": "Orders.$prop", "nativeQueryRef": "$prop", "active": true }] },
        "Y": { "projections": [{ "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "Metrics" } }, "Property": "Selected Metric Value" } }, "queryRef": "Metrics.Selected Metric Value", "nativeQueryRef": "Selected Metric Value" }] }
      }
    },
    "objects": { "title": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'$title'" } } } } }] },
    "drillFilterOtherVisuals": true
  }
}
"@
}

$id = New-Id; Save-Visual $id (DistDonut $id 'Colour' 8 '% by Colour')
$id = New-Id; Save-Visual $id (DistDonut $id 'Product' 328 '% by Product')
$id = New-Id; Save-Visual $id (DistDonut $id 'Animals' 648 '% by Animal')
$id = New-Id; Save-Visual $id (DistDonut $id 'Occasions' 968 '% by Occasion')

Write-Host "Done. Visuals:" (Get-ChildItem $pagePath -Directory).Count

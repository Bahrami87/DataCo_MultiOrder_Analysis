# KPI Summary — DataCo Supply Chain Analysis

> Quick reference for interviews, portfolio presentations, and README updates.

---

## Dataset Scale

| Metric | Value |
|--------|-------|
| Distinct orders | 65,752 |
| Order-item rows | 180,519 |
| Markets | 5 (Africa, Europe, LATAM, Pacific Asia, USCA) |
| Date range | Refer to dataset |

---

## Financial KPIs

| KPI | Value |
|-----|-------|
| Net profit (all orders) | **−£1,750,142** |
| % of loss-making orders | **37.5%** |
| Avg profit — loss orders | **−£135.82** |
| Avg profit — profitable orders | **+£38.87** |

---

## Delivery KPIs

| KPI | Value |
|-----|-------|
| On-time delivery rate | **45.2%** |
| Late delivery rate | **54.8%** |
| Avg shipping delay | **+0.57 days** |

---

## Discount Analysis

| Metric | Value |
|--------|-------|
| Average discount rate | **10.2%** |
| Max discount rate | **25.0%** |
| Avg discount — loss orders | 10.22% |
| Avg discount — profit orders | 10.15% |
| Discount as driver of losses? | **No** |

---

## Multi-Item vs Single-Item Orders

| Segment | Orders | % Orders | Revenue | % Revenue | Profit |
|---------|--------|----------|---------|-----------|--------|
| Single-Item | 19,850 | 30% | £4.7M | 13% | **+£545K** |
| Multi-Item | 45,902 | 70% | £32.0M | 87% | **−£2.30M** |

---

## Profit by Item Count

| Items per Order | Avg Profit | Orders |
|-----------------|-----------|--------|
| 1 | **+£27.46** | 19,850 |
| 2 | −£17.97 | 11,447 |
| 3 | −£42.71 | 11,398 |
| 4 | −£60.11 | 11,704 |
| 5 | −£79.21 | 11,353 |

**Slope**: approximately −£20 to −£22 per additional item.

---

## Top Loss-Making Categories (Allocated Profit)

| Category | Allocated Profit |
|----------|-----------------|
| Fishing | −£418,054 |
| Cleats | −£251,499 |
| Camping & Hiking | −£240,263 |
| Cardio Equipment | −£228,230 |
| Women's Apparel | −£184,478 |
| Water Sports | −£180,390 |
| Indoor/Outdoor Games | −£167,385 |
| Men's Footwear | −£165,424 |

---

## Hypothesis Testing Summary

| Hypothesis | Result |
|------------|--------|
| Discounts cause losses | ❌ Rejected |
| Late delivery causes losses | ❌ Rejected |
| Specific categories cause losses | ✅ Partially confirmed |
| Multi-item order structure causes losses | ✅ Confirmed (root cause) |
| Problem is regional | ❌ Rejected — universal pattern |

---

## Core Insight (Interview-Ready Phrasing)

> *"Profitability deteriorates almost linearly as the number of items per order increases, indicating a flawed cost or pricing structure in bundled purchases. This pattern holds across all five global markets, confirming it is a structural flaw in order economics rather than a regional or operational issue."*

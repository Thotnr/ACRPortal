# Role Flow — Reviewing Authority (RvA)

**Prepared for:** ACRPortal (DHBVN Online ACR system)
**Scope:** Standalone flow reference for the Reviewing Authority step, split out of `Docs/ACR_Role_Based_Workflow_Guide.md` so a dedicated flow diagram can be drawn for this role.
**Context:** Under the new self-raise requirement (see `Docs/CCA_Role_Change_ACR_Self_Raise_Flow.md`), the Officer now raises the ACR instead of CCA. The Reviewing Authority's own actions are **unchanged** — RvA only ever looks at `acr_id` + the `reviewing_user_id` field on `acr_cycles`, never at who created the ACR.

---

## 1. Purpose

The Reviewing Authority is the single reviewer sitting between the Reporting Authority stage and the final Accepting Authority decision. It reads the officer's self-appraisal and both RA1/RA2 assessments, then records its own agreement/disagreement, comments, an overall grade, and optional score overrides.

---

## 2. Entry / Exit Conditions

| | Condition |
|---|---|
| **Entry status** | `PENDING_REVIEWING` |
| **Exit status** | `PENDING_ACCEPTING` |
| **Actor** | An `EMPLOYEE`-role user assigned as `reviewing_user_id` on the ACR |
| **Cardinality** | Exactly one Reviewing Authority per ACR (no RvA1/RvA2 split) |

---

## 3. Flow Diagram

```
                    ACR status = PENDING_REVIEWING
                                |
                                v
            RvA opens "My Reviewing Queue"
            (GET /api/acr/reviewing/my)
                                |
                                v
            RvA opens the ACR
            (GET /api/acr/{acrId}/reviewing)
            -- sees self-appraisal + RA1 assessment
               + RA2 assessment (if A1b) + Section I data --
                                |
                                v
            RvA fills review:
              - AgreeWithRa (bool)
              - DisagreeDetails
              - Comments
              - OverallGrade
                                |
                                v
            <<< Does RvA want to override any RA score? >>>
                 |                                  |
                NO                                 YES
                 |                                  |
                 v                                  v
        leave rva_* override            set one or more of the 15
        fields null                     rva_* override score fields
                 |                                  |
                 +---------------+------------------+
                                 |
                                 v
            Save draft (repeatable)
            (PATCH /api/acr/{acrId}/reviewing/draft)
                                 |
                                 v
            RvA uploads supporting docs, if any
            (POST /api/acr/{acrId}/docs, section=RVA)
                                 |
                                 v
            RvA submits review
            (POST /api/acr/{acrId}/reviewing/submit)
                                 |
                                 v
                    status -> PENDING_ACCEPTING
```

---

## 4. Step-by-Step Actions

1. Login as the `EMPLOYEE` user assigned as Reviewing Authority.
2. Open the reviewing queue — lists every ACR currently `PENDING_REVIEWING` and assigned to the caller.
3. Open a specific ACR — view shows: officer self-appraisal, RA1 assessment (always), RA2 assessment (`Exists=false` for A1a/A2), Section I data, and the caller's own draft if one exists.
4. Fill/edit the review:
   - `AgreeWithRa` (bool) — agreement with the Reporting Authority's assessment.
   - `DisagreeDetails` — required narrative when disagreeing.
   - `Comments` — free-text review comments.
   - `OverallGrade` — decimal, 1–10.
   - Optional score overrides (`rva_*` columns) — 15 fields covering work/attribute/competency scores; send `null` to leave the RA's original score untouched, or a value to override it.
5. Save as draft — repeatable, writes to `reviewing_assessments` and, if any overrides are set, to the `rva_*` columns on `reporting_assessments`.
6. Optionally upload supporting documents to the `RVA` section.
7. Submit — finalizes the review and transitions the ACR to `PENDING_ACCEPTING`.

---

## 5. Business Rules & Restrictions

- Can act **only** while the ACR is `PENDING_REVIEWING`.
- Cannot submit twice (`ALREADY_SUBMITTED`).
- Cannot act on an ACR not assigned to them (`FORBIDDEN`).
- Cannot submit without a draft saved first (`BAD_REQUEST`).
- Cannot change officer, CCA, or RA-submitted data directly — only add overrides via the dedicated `rva_*` fields, which are visually/semantically separate from the RA's original scores (both are preserved).
- Empty/`null` override fields mean **no override applied** — the original RA score stands.

---

## 6. API Reference

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reviewing/my` | List reviewing queue for caller |
| GET | `/api/acr/{acrId}/reviewing` | Get full ACR detail (self-appraisal + RA1 + RA2 + own draft + overrides + documents) |
| PATCH | `/api/acr/{acrId}/reviewing/draft` | Save reviewing draft (repeatable) |
| POST | `/api/acr/{acrId}/reviewing/submit` | Submit review (triggers `PENDING_REVIEWING` → `PENDING_ACCEPTING`) |
| POST | `/api/acr/{acrId}/docs` | Upload a document (section=RVA) |
| GET | `/api/acr/{acrId}/docs` | List RvA's documents |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |

Full contract: `Docs/API Contract/Reviewing_API_Contract.md`

---

## 7. What This Role Never Does

- Never creates or edits Section I / posting details.
- Never fills in for RA1/RA2 or the Accepting Authority.
- Never sees who originally raised the ACR (CCA vs. Officer self-raise) — irrelevant to this step.

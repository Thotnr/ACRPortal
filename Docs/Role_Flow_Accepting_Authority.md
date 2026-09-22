# Role Flow — Accepting Authority (AA)

**Prepared for:** ACRPortal (DHBVN Online ACR system)
**Scope:** Standalone flow reference for the Accepting Authority step, split out of `Docs/ACR_Role_Based_Workflow_Guide.md` so a dedicated flow diagram can be drawn for this role.
**Context:** Under the new self-raise requirement (see `Docs/CCA_Role_Change_ACR_Self_Raise_Flow.md`), the Officer now raises the ACR instead of CCA. The Accepting Authority's own actions are **unchanged** — AA only ever looks at `acr_id` + the `accepting_user_id` field on `acr_cycles`, never at who created the ACR.

---

## 1. Purpose

The Accepting Authority gives the **final** decision on the ACR — approve or reject — after reviewing the complete history: officer self-appraisal, RA1/RA2 assessment(s), and the Reviewing Authority's review. This is the last stage in the workflow.

---

## 2. Entry / Exit Conditions

| | Condition |
|---|---|
| **Entry status** | `PENDING_ACCEPTING` |
| **Exit status** | `APPROVED` (if `IsApproved = true`) or `REJECTED` (if `IsApproved = false`) |
| **Actor** | An `EMPLOYEE`-role user assigned as `accepting_user_id` on the ACR |
| **Draft step** | **None** — this is the only role with no separate save-draft/submit split; one call both records the decision and closes the ACR |

---

## 3. Flow Diagram

```
                    ACR status = PENDING_ACCEPTING
                                |
                                v
            AA opens "My Accepting Queue"
            (GET /api/acr/accepting/my)
                                |
                                v
            AA opens the ACR
            (GET /api/acr/{acrId}/accepting)
            -- sees full history: self-appraisal, RA1, RA2 (if any),
               RvA review + overrides, Section I data --
                                |
                                v
            AA optionally uploads supporting docs
            (POST /api/acr/{acrId}/docs, section=AA)
            -- can happen before or interleaved with the decision --
                                |
                                v
            AA fills final decision:
              - AgreeWithPrevious (bool)
              - DisagreeDetails (required if disagreeing)
              - ConflictResolved (bool)
              - FinalGrade
              - FinalRemarks
              - IsApproved (bool)  <-- the actual decision
                                |
                                v
            <<< IsApproved == true? >>>
                 |                        |
                YES                      NO
                 |                        |
                 v                        v
        POST /api/acr/{acrId}/       POST /api/acr/{acrId}/
        accepting/submit             accepting/submit
                 |                        |
                 v                        v
        status -> APPROVED          status -> REJECTED
                 |                        |
                 +-----------+------------+
                             |
                             v
              ACR is now in a FINAL state.
              No further edits/uploads by any role.
              CCA's "Final Outcomes" list picks it up
              (read-only) under the new self-raise flow.
```

---

## 4. Step-by-Step Actions

1. Login as the `EMPLOYEE` user assigned as Accepting Authority.
2. Open the accepting queue — lists every ACR currently `PENDING_ACCEPTING` and assigned to the caller.
3. Open a specific ACR — view shows the entire prior lifecycle (self-appraisal, RA1, RA2 if applicable, RvA review + overrides, Section I data) plus the AA's own decision if one already exists (it won't, since decision is one-shot).
4. Optionally upload documents to the `AA` section — allowed any time while still `PENDING_ACCEPTING`, whether before or after the decision call (though in practice, upload before submitting since submit closes the ACR).
5. Fill the final decision fields and call submit **once**:
   - `AgreeWithPrevious`, `DisagreeDetails`, `ConflictResolved`, `FinalGrade`, `FinalRemarks`, `IsApproved`.
6. Submit — this single call both records the decision and transitions the ACR to its final state (`APPROVED` or `REJECTED`). There is no way to revise after this.

---

## 5. Business Rules & Restrictions

- Can act **only** while the ACR is `PENDING_ACCEPTING`.
- **No draft mode** — unlike every other role, there is nothing to "save" separately; the submit call is the decision.
- Cannot call submit twice (`ALREADY_DECIDED`).
- Cannot act on an ACR not assigned to them (`FORBIDDEN`).
- `DisagreeDetails` should be populated whenever `AgreeWithPrevious = false`.
- Once decided, the ACR is final — no role (including AA) can edit further through normal workflow.

---

## 6. API Reference

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/accepting/my` | List accepting queue for caller |
| GET | `/api/acr/{acrId}/accepting` | Get full ACR detail + documents |
| POST | `/api/acr/{acrId}/accepting/submit` | Submit final decision — one-shot, closes the ACR |
| POST | `/api/acr/{acrId}/docs` | Upload a document (section=AA) |
| GET | `/api/acr/{acrId}/docs` | List AA's documents |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |

Full contract: `Docs/API Contract/Accepting_API_Contract.md`

---

## 7. What This Role Never Does

- Never creates or edits Section I / posting details.
- Never fills in for the Officer, RA1/RA2, or Reviewing Authority.
- Never re-opens a decided ACR — `APPROVED`/`REJECTED` is a true terminal state for this role.
- Never sees who originally raised the ACR (CCA vs. Officer self-raise) — irrelevant to this step.

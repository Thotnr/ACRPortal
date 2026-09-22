# Role Flow — CCA (As Per New Self-Raise Requirement)

**Prepared for:** ACRPortal (DHBVN Online ACR system)
**Scope:** Standalone flow reference for the CCA role, split out for its own flow diagram.
**Context:** This reflects the **new requirement** described in `Docs/CCA_Role_Change_ACR_Self_Raise_Flow.md` — the Officer/Employee now raises their own ACR. CCA no longer creates ACRs; CCA's role flips from *initiator* to *final-outcome, read-only viewer*.

If you need the role flow as it works **today, before this change**, see §7 (Old Flow, kept for reference/comparison).

---

## 1. Purpose (New Requirement)

CCA no longer starts the ACR cycle. CCA's only remaining responsibility is to view the **final, completed** ACR (Approved or Rejected) in full detail, once every other role has finished acting on it.

---

## 2. Entry / Exit Conditions (New Requirement)

| | Condition |
|---|---|
| **Entry point for CCA** | ACR status reaches `APPROVED` or `REJECTED` |
| **CCA action available** | View only — no create, edit, submit, or upload |
| **Exit** | N/A — this is the terminal viewing step; CCA does nothing that changes ACR state |
| **Visibility rule** | CCA sees only ACRs auto-mapped to their geography (or, as a fallback default, every completed ACR — see decision #1 in the change doc) |

---

## 3. Flow Diagram (New Requirement)

```
        Employee raises own ACR (see Role_Flow_Officer / self-raise doc)
                                |
                                v
                PENDING_OFFICER -> PENDING_REPORTING
                -> PENDING_REVIEWING -> PENDING_ACCEPTING
                (CCA has NO visibility or action during any of this)
                                |
                                v
                    <<< Accepting Authority decides >>>
                         |                    |
                      APPROVED             REJECTED
                         |                    |
                         +---------+----------+
                                   |
                                   v
                CCA dashboard "Final Outcomes" list
                now shows this ACR
                (auto-mapped by officer geography, decision #1)
                                   |
                                   v
                CCA opens the ACR
                (read-only detail view — same layout Admin uses)
                                   |
                                   v
                CCA views full lifecycle:
                  - Section I / posting / service details
                  - Self-appraisal
                  - RA1 / RA2 assessment
                  - Reviewing Authority review + overrides
                  - Final decision (approve/reject, grade, remarks)
                  - All uploaded documents across sections
                                   |
                                   v
                            (end — no further action)
```

---

## 4. Step-by-Step Actions (New Requirement)

1. CCA logs in.
2. Opens CCA dashboard/queue — now filtered to **completed** ACRs only (`APPROVED`/`REJECTED`), auto-mapped to CCA by officer geography.
3. Opens a specific ACR from the list.
4. Views the full read-only lifecycle report — identical in shape to what Admin already sees, covering every section from Section I through the final decision.
5. No save, submit, upload, or edit actions are available anywhere in this screen.

---

## 5. Business Rules & Restrictions (New Requirement)

- CCA **cannot create** an ACR at all — the "Create ACR" action is removed entirely.
- CCA **cannot edit** Section I, authority assignments, or any workflow step.
- CCA **cannot upload** documents (medical report/photo upload moves to the Employee, under `section='OFFICER'`).
- CCA sees an ACR **only after** it reaches `APPROVED` or `REJECTED` — no visibility into `DRAFT` / `PENDING_*` states under the new flow.
- In-flight ACRs that CCA raised **before** the cutover keep running under the old flow (grandfathered) — see decision #2 in the change doc.

---

## 6. API Reference (New Requirement — Read-Only Subset)

Under the new flow, CCA keeps only the list/detail (read) endpoints; create/update/submit/photo-upload endpoints are removed from CCA's surface:

| Method | Route | Description |
|---|---|---|
| GET | `/api/cca/acr` | List ACRs (now filtered to completed outcomes only) |
| GET | `/api/cca/acr/{acrId}` | Get full read-only detail of a completed ACR |

Full contract for the pre-change API surface (for reference): `Docs/API Contract/CCA_API_Contract (2).md`

---

## 7. Old Flow (Before This Change — Kept for Comparison Only)

This is CCA's role **today**, prior to the self-raise change, so the two flows can be diagrammed side by side.

```
                CCA logs in
                        |
                        v
                Selects Officer + Designation
                        |
                        v
                Fills Section I (posting, DOB, qualifications, career summary)
                        |
                        v
                Picks RA1, RA2 (if A1b), Reviewing Authority, Accepting Authority
                        |
                        v
                Uploads medical report / officer photo
                        |
                        v
                <<< Save as draft, or Submit now? >>>
                     |                        |
                  DRAFT                    SUBMIT
                     |                        |
                     v                        v
            status = DRAFT          status -> PENDING_OFFICER
            (CCA can edit later)    (Officer takes over from here)
```

CCA-owned APIs in the old flow (all being removed under the new requirement): `POST /api/cca/acr` (create), `PATCH /api/cca/acr/{acrId}` (update draft), `POST /api/cca/acr/{acrId}/submit`, `POST /api/cca/acr/{acrId}/photo`, `POST /api/cca/acr/{acrId}/docs`, `DELETE /api/cca/acr/{acrId}/docs/{documentId}`.

---

## 8. What This Role Never Does (Either Flow)

- Never performs officer self-appraisal.
- Never submits RA, Reviewing, or Accepting decisions.
- Never edits a final `APPROVED`/`REJECTED` ACR.

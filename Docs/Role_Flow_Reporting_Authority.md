# Role Flow — Reporting Authority (RA1 / RA2)

**Prepared for:** ACRPortal (DHBVN Online ACR system)
**Scope:** Standalone flow reference for the Reporting Authority step, split out of `Docs/ACR_Role_Based_Workflow_Guide.md` so a dedicated flow diagram can be drawn for this role.
**Context:** Under the new self-raise requirement (see `Docs/CCA_Role_Change_ACR_Self_Raise_Flow.md`), the Officer now raises the ACR instead of CCA. The Reporting Authority's own actions are **unchanged** — RA1/RA2 still only ever see `acr_id` + their own assigned role field, regardless of who created the ACR.

---

## 1. Purpose

The Reporting Authority reviews the officer's self-appraisal and records a performance assessment with scored ratings. There are up to two Reporting Authorities per ACR:

- **RA1** — always required.
- **RA2** — required only when `form_type = A1b`; not applicable for `A1a` / `A2`.

---

## 2. Entry / Exit Conditions

| | Condition |
|---|---|
| **Entry status** | `PENDING_REPORTING` |
| **Exit status (A1a / A2 — RA1 only)** | `PENDING_REVIEWING` |
| **Exit status (A1b — first of RA1/RA2 to submit)** | stays `PENDING_REPORTING` |
| **Exit status (A1b — second of RA1/RA2 to submit)** | `PENDING_REVIEWING` |
| **Actor** | An `EMPLOYEE`-role user assigned as `reporting_user_id` (RA1) or `ra2_user_id` (RA2) on the ACR |

---

## 3. Flow Diagram

```
                        ACR status = PENDING_REPORTING
                                    |
                                    v
                    RA1 opens "My Reporting Queue"
                    (GET /api/acr/reporting/my)
                                    |
                                    v
                    RA1 opens the ACR
                    (GET /api/acr/{acrId}/reporting)
                    -- sees officer self-appraisal + CCA/Section I data --
                                    |
                                    v
                    RA1 fills assessment + 19 scored fields
                    Saves draft (repeatable)
                    (PATCH /api/acr/{acrId}/reporting/draft)
                                    |
                                    v
                    RA1 uploads supporting docs, if any
                    (POST /api/acr/{acrId}/docs, section=RA1)
                                    |
                                    v
                    RA1 submits assessment
                    (POST /api/acr/{acrId}/reporting/submit)
                                    |
                                    v
                    <<< Is form_type == A1b AND RA2 assigned? >>>
                         |                              |
                        NO                             YES
                         |                              |
                         v                              v
        status -> PENDING_REVIEWING        <<< Has RA2 already submitted? >>>
        (RA1 was the only/last RA)               |                     |
                                                 NO                    YES
                                                  |                     |
                                                  v                     v
                                    status stays              status -> PENDING_REVIEWING
                                    PENDING_REPORTING          (RA1 was the last to submit)
                                    (waiting on RA2 to
                                     do the same steps
                                     above, in parallel,
                                     independently of RA1)
```

RA1 and RA2 act **independently and in either order** — there is no forced sequence between them. Whichever of the two submits second is the one whose submit call flips the status to `PENDING_REVIEWING`.

---

## 4. Step-by-Step Actions

1. Login as the `EMPLOYEE` user assigned as RA1 (or RA2, if `A1b`).
2. Open the reporting queue — lists every ACR where the caller is currently the pending RA1 or RA2.
3. Open a specific ACR — view shows officer's self-appraisal (Section II), Section I data (posting/qualifications), and the caller's own draft assessment if one exists.
4. Fill/edit the assessment:
   - `AgreeWithSelf` (bool), `DisagreeDetails`, `IntegrityComments`, `Remarks`
   - Work scores: `WorkTargets`, `WorkQuality`, `WorkExceptional`, `WorkOverall`
   - Attribute scores: `AttrAttitude`, `AttrResponsibility`, `AttrStability`, `AttrCommunication`, `AttrMoralCourage`, `AttrLeadership`, `AttrTimeliness`, `AttrOverall`
   - Competency scores: `CompKnowledge`, `CompPlanning`, `CompDecision`, `CompInitiative`, `CompTeamwork`, `CompOverall`
   - `OverallGrade`
5. Save as draft — repeatable, does not change ACR status.
6. Optionally upload supporting documents to the RA1/RA2 section.
7. Submit — locks the assessment (`IsSubmitted = true`, `SubmittedAt` set) and triggers the status transition described in §3.

---

## 5. Business Rules & Restrictions

- RA1/RA2 can act **only** while the ACR is `PENDING_REPORTING`.
- Cannot submit twice (`ALREADY_SUBMITTED`).
- Cannot act on an ACR they are not assigned to (`FORBIDDEN`).
- Cannot submit without first saving a draft (`BAD_REQUEST` if draft never saved).
- Cannot change officer, CCA, or any other role's data.
- If RA2 is not assigned (A1a/A2), the RA2 branch of the diagram never exists — treat as **Not Applicable**, not "Pending."
- If RA2 is assigned but hasn't submitted, its state is **Pending** (distinct from Not Applicable).

---

## 6. API Reference

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reporting/my` | List reporting queue for caller (RA1 + RA2 ACRs) |
| GET | `/api/acr/{acrId}/reporting` | Get ACR detail + officer self-appraisal + RA draft + documents |
| PATCH | `/api/acr/{acrId}/reporting/draft` | Save reporting draft (repeatable) |
| POST | `/api/acr/{acrId}/reporting/submit` | Submit reporting assessment (triggers status transition) |
| POST | `/api/acr/{acrId}/docs` | Upload a document to caller's section (RA1 or RA2) |
| GET | `/api/acr/{acrId}/docs` | List documents in caller's section |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |

Full contract: `Docs/API Contract/Reporting_API_Contract.md`

---

## 7. What This Role Never Does

- Never creates or edits the ACR's Section I / posting details.
- Never sees or edits Reviewing or Accepting Authority data.
- Never knows or cares whether the ACR was raised by CCA (old flow) or by the Officer (new self-raise flow) — the trigger into `PENDING_REPORTING` looks identical either way.

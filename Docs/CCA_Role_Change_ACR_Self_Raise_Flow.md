# CCA Role Change — Employee Self-Raises the ACR

**Status:** Proposed — for review before implementation begins
**Prepared for:** ACRPortal (DHBVN Online ACR system)
**Scope:** Move ACR creation (Section I + authority assignment) from CCA to Officer/Employee. CCA becomes a post-completion, read-only viewer of the final outcome.

---

## 1. Objective

Today, the **CCA** raises every ACR — enters the officer's posting/service details and picks the Reporting Authority (RA1/RA2), Reviewing Authority, and Accepting Authority — before the Officer ever sees it.

The new requirement: **the Officer (Employee) raises their own ACR.** CCA is removed from the start of the workflow entirely and only re-enters at the very end, as a read-only viewer of the completed (Approved/Rejected) ACR with full detail.

---

## 2. Current Flow (As-Is)

```
CCA logs in
  → Selects Officer + Designation
  → Fills Section I (posting, DOB, qualifications, career summary)
  → Picks RA1, RA2 (if A1b), Reviewing Authority, Accepting Authority
  → Uploads medical report / officer photo
  → Submits  →  status DRAFT → PENDING_OFFICER
        ↓
Officer fills Self-Appraisal (Section II)  →  PENDING_REPORTING
        ↓
RA1 (and RA2 if A1b) assess  →  PENDING_REVIEWING
        ↓
Reviewing Authority reviews  →  PENDING_ACCEPTING
        ↓
Accepting Authority decides  →  APPROVED / REJECTED
        ↓
Admin can view/report on everything, anytime, across all ACRs.
CCA can view/report only on the ACRs it personally raised, at any stage.
```

Reference: [Docs/ACR_Role_Based_Workflow_Guide.md](ACR_Role_Based_Workflow_Guide.md), [Docs/API Contract/CCA_API_Contract (2).md](API%20Contract/CCA_API_Contract%20%282%29.md)

---

## 3. New Flow (To-Be)

```
Employee logs in
  → Clicks "Raise Appraisal" (new action, does not exist today)
  → Fills the SAME Section I form CCA used to fill:
      posting/department/location, designation, posting-from/to,
      DOB, qualifications, career summary
  → Picks own RA1, RA2 (if A1b), Reviewing Authority, Accepting Authority
  → Uploads medical report / own photo
  → Submits  →  PENDING_OFFICER
        ↓
Same screen (or immediately after) Employee fills Self-Appraisal (Section II)
  — this part is UNCHANGED, it's the same form that exists today
        ↓  →  PENDING_REPORTING
RA1 (and RA2 if A1b) assess  —  UNCHANGED  →  PENDING_REVIEWING
        ↓
Reviewing Authority reviews  —  UNCHANGED  →  PENDING_ACCEPTING
        ↓
Accepting Authority decides  —  UNCHANGED  →  APPROVED / REJECTED
        ↓
CCA dashboard shows the ACR under "Final Outcomes" the moment it hits
APPROVED or REJECTED. CCA opens it and sees the full detailed,
read-only report (same layout Admin already uses).
```

**What does NOT change:** RA1, RA2, Reviewing Authority, and Accepting Authority steps are byte-for-byte the same as today — they already only care about `acr_id` + their own role field on `acr_cycles`, never about who raised it. Admin's global oversight is also unaffected.

**What changes:** who fills Section I and who picks the four authority fields — it moves from CCA's screen to Employee's screen. CCA's role flips from *initiator* to *final-outcome viewer only*.

---

## 4. Role-by-Role Comparison

| Role | Today | After This Change |
|---|---|---|
| **CCA** | Creates ACR, fills Section I, assigns RA1/RA2/RvA/AA, uploads medical report + photo, submits to Officer | **Cannot create ACR at all.** Read-only: sees a list of ACRs once they reach APPROVED/REJECTED, opens full detail view |
| **Officer/Employee** | Only fills Self-Appraisal (Section II) on an ACR someone else already created | Fills Section I (posting/service/quals) **and** picks own RA1/RA2/RvA/AA **and** fills Self-Appraisal — effectively does what CCA + Officer used to do combined |
| RA1 / RA2 | Assess self-appraisal, grade | **Unchanged** |
| Reviewing Authority | Reviews RA assessment(s), can override | **Unchanged** |
| Accepting Authority | Final approve/reject | **Unchanged** |
| Admin | Full oversight, all ACRs, all stages | **Unchanged** |

---

## 5. Open Design Decisions (need a decision before/while building — each has a recommended default)

These are business-rule questions the code cannot answer on its own. I've picked a sensible default for each so the estimate below assumes these; flag any you want changed.

1. **How does the system decide *which* CCA sees a given ACR in the final list?**
   Today `cca_user_id` is set to whichever CCA manually clicked "Create." If nobody manually creates it anymore, this must be auto-resolved.
   **Recommended:** resolve it from the officer's existing geography fields (`users.zone_id` / `circle_id` / `division_id` / `sub_division_id` — these already exist, see `Docs/Schema/2.sql`) by matching to the CCA user assigned to that geography. **Fallback if no CCA maps cleanly to a geography today:** every active CCA sees every completed ACR (simplest, safe default, revisit later).

2. **What happens to ACRs CCA has already raised and are mid-flow right now (in PENDING_OFFICER / PENDING_REPORTING / etc.)?**
   **Recommended:** grandfather them — they keep running through their current status exactly as today; only *newly raised* ACRs use the new Employee-raises flow. No data migration required for old rows. (Alternative — force-migrate everything — adds real risk and isn't necessary for a mid-year cutover.)

3. **Who now owns "CCA-section" documents (medical report, officer photo)?**
   **Recommended:** these become Employee-section documents (`section='OFFICER'`) going forward, since Employee is the one uploading them at raise-time. Historical CCA-section documents on old ACRs stay as-is (read-only, unaffected).

4. **Does CCA keep any create/edit capability at all (e.g., an emergency override, or fixing a mistake before RA1 acts)?**
   **Recommended:** No — fully removed, per your instruction. If a correction is ever needed, Admin already has that power; no new CCA-side edit path will be built.

If any of these defaults are wrong, tell me and I'll adjust the plan and the estimate before coding starts.

---

## 6. Technical Impact — By Layer

The app is a 4-project hexagonal-architecture solution (`Domain → Application → Infrastructure → Controllers/Views`). Grounded in the actual files:

### Domain (`ACRPortal.Domain`)
- `dtos/WebToApp/Ccaacrdtos.cs` — add an Employee-facing equivalent of `CreateAcrRequest` (same fields, minus `OfficerUserId`/`CcaUserId` since those are now implicit/auto-resolved).
- No DB schema field removal needed — `acr_cycles` keeps all its columns; only **who writes them and when** changes. `cca_user_id` resolution logic changes (see decision #1) but the column stays.

### Application (`ACRPortal.Application`)
- `service/Ccaservice.cs` (441 lines) — **shrinks**: remove Create/UpdateDraft/SubmitDraft/photo-upload logic (~half the file); keep only list/detail (now filtered to completed ACRs, see decision #1).
- `service/OfficerService.cs` (130 lines) — **grows**: gains a "Raise ACR" method carrying the validation CCA used to do (posting-gap ≥ 90 days, RA2 required only for A1b, all four authority users must be active, duplicate-ACR check).
- `usecase/Iccausecase.cs` / `usecase/IOfficerUseCase.cs` — interface signatures updated to match.
- **Reuse opportunity:** rather than copy-pasting ~200 lines of validation from Ccaservice into OfficerService, extract it into one shared helper both call. This cuts duplication and halves the regression risk on that logic.

### Infrastructure (`ACRPortal.Infrastructure`)
- `Adapter/Ccaadapter.cs` (1092 lines, the biggest single file touched) — remove Create/Update/Submit/Suggestions SQL; keep read queries only.
- `Adapter/OfficerAdapter.cs` (952 lines) — gains the SQL that used to live in `Ccaadapter.cs` (insert into `acr_cycles`, resolve `form_type` from `tbDsg`, authority-suggestion lookup via `users.manager_id`).
- `Adapter/DashboardAdaper.cs` — CCA's dashboard aggregate query changes from "ACRs I created" to "ACRs auto-mapped to me that are now complete." An index already exists for `(cca_user_id, status)` (`Docs/Schema/11.sql`), so this is a query change, not a schema change.
- `Adapter/Documentadapter.cs` — `ResolveCallerSection` logic (matches caller against `acr_cycles.cca_user_id`) updated per decision #3.
- `Adapter/AcrMisAdapter.cs` — MIS/reporting queries that reference `cca_user_id` reviewed for the new resolution logic.

### Web (`ACRPortal` project)
- `Controllers/api/Ccaapicontroller.cs` (207 lines) — strip Create/Update/Submit/Photo endpoints; keep list/detail (now "final outcomes").
- `Controllers/api/OfficerApiController.cs` (126 lines) — gains new endpoints: raise ACR, save/submit Section I draft, authority-suggestion lookup (self-scoped version of CCA's existing `GET /api/cca/officers/{id}/authorities/suggestions`), employee dropdown for picking RA1/RA2/RvA/AA.
- `Filters/RouteAccessPolicy.cs` — minimal change; `EMPLOYEE` already has a wildcard allow on `/api/acr*`, so new officer-side raise-ACR routes need no new policy entry as long as they stay under that prefix. CCA policy entries for `/api/cca` stay (read-only endpoints still live there).
- `Views/Home/CCA.aspx` (**3,439 lines** — the largest view in the app) — strip the "Create ACR" wizard portion; keep the report/detail-view portion. **Important finding:** this file already renders the Admin's read-only lifecycle report for the `ADMIN` role (`currentUserRole === "ADMIN" ? "api/admin/acr" : "api/cca/acr"`, line ~1291) — so the read-only detailed view CCA needs at the end of the flow **already exists and is proven**, it just needs to become the only mode for CCA instead of one of two modes.
- `Views/Home/Officer.aspx` (**1,951 lines**) — gains a new "Raise Appraisal" wizard, largely ported from the Section I portion of `CCA.aspx` (form fields + authority dropdowns + suggestion autofill), wired to the new Officer endpoints, placed ahead of the existing Self-Appraisal form.
- `Views/Home/Dashboard.aspx` — CCA's dashboard tiles/summary re-pointed from "pending my action" to "awaiting completion" / "completed, ready to view."

### Docs to update after implementation
- `Docs/ACR_Role_Based_Workflow_Guide.md`, `Docs/API Contract/CCA_API_Contract (2).md`, `Docs/API Contract/Officer_API_Contract.md`, `Docs/CCA_User_Manual.md`.

---

## 7. What Is *Not* Touched (why the blast radius is smaller than it looks)

- `Reporting_API_Contract.md`, `Reviewing_API_Contract.md`, `Accepting_API_Contract.md` and their controllers/services/adapters — **zero changes**. They only ever look at `acr_id` and their own authority field.
- `AdminController.cs` / Admin's lifecycle report — **zero changes**. Admin still sees everything, unaffected by who raised it.
- Status enum (`DRAFT → PENDING_OFFICER → PENDING_REPORTING → PENDING_REVIEWING → PENDING_ACCEPTING → APPROVED/REJECTED`) — **unchanged**, just now entered by Employee instead of CCA.
- Existing in-flight ACRs (decision #2, recommended: grandfathered) — **no data migration**.

---

## 8. Risk Areas

1. **Validation parity** — the 90-day posting-gap rule, RA2-required-for-A1b rule, active-user checks, and duplicate-ACR check currently live in `Ccaservice.cs`/`Ccaadapter.cs`. If not carried over exactly, Employees could create invalid ACRs that used to be blocked by CCA-side checks. *(Mitigated by extracting shared validation, per §6.)*
2. **`cca_user_id` auto-resolution correctness** (decision #1) — if geography mapping is incomplete or inconsistent in the `users` table today, some completed ACRs may not surface for any CCA. Needs a data-quality check on `zone_id`/`circle_id`/`division_id` coverage before go-live.
3. **Large view files** — `CCA.aspx` (3,439 lines) and `Officer.aspx` (1,951 lines) are big, mostly-inline-JS Web Forms views with no separate JS files. Porting markup/JS between them by hand is mechanical but error-prone; needs careful manual QA rather than being a quick copy-paste.
4. **Regression on unaffected roles** — low risk technically (no code changes there), but full end-to-end regression testing is still needed since the *source* of the ACR data changes even though downstream code doesn't.
5. **User training/comms** — CCA office staff and all officers need to know the process changed on go-live day; this is an operational, not technical, task but affects rollout timing.

---

## 9. Effort & Timeline Estimate

Assumptions: **one developer**, working in this codebase (no ramp-up needed), the four open decisions in §5 are settled up front using the recommended defaults, and "flawless" means a full regression pass plus a short stabilization buffer — not zero possibility of any post-release bug.

| Phase | Work | Estimate |
|---|---|---|
| 1 | Finalize open decisions (§5), sign-off on this doc | 0.5 day |
| 2 | DB migration (index/logic adjustments only, no destructive schema change) | 0.5 day |
| 3 | Backend: extract shared "raise ACR" validation + wire into `OfficerService`/`OfficerAdapter` | 1.5–2 days |
| 4 | Backend: new Officer API endpoints (raise, draft, suggestions, employee dropdown) + `RouteAccessPolicy` check | 0.5 day |
| 5 | Backend: trim `Ccaservice`/`Ccaadapter`/`CcaApiController` to read-only + final-outcome filtering; update `DashboardAdaper`/`AcrMisAdapter` queries | 1–1.5 days |
| 6 | Frontend: build "Raise Appraisal" wizard in `Officer.aspx` (port + adapt Section I UI from `CCA.aspx`, wire to new endpoints, authority-suggestion autofill) | 2–2.5 days |
| 7 | Frontend: trim `CCA.aspx` to the existing read-only report mode only; adjust `Dashboard.aspx` CCA tiles | 1–1.5 days |
| 8 | End-to-end testing: all 3 form types (A1a/A1b/A2), full lifecycle dry runs, CCA final view, backward-compat check on in-flight ACRs, auth/route checks | 1.5–2 days |
| 9 | Bug-fixing / stabilization buffer | 1–1.5 days |
| 10 | Update API contracts, role guide, CCA user manual | 0.5 day |

**Total: ~10.5–13.5 developer-days (roughly 2.5–3 weeks calendar time for one developer), including testing and stabilization — not counting a client/UAT feedback round.**

If a UAT round with DHBVN stakeholders is required after dev-complete (recommended for a workflow-ownership change like this), add **2–5 more calendar days** for feedback + fixes — mostly waiting time, not heavy dev time. Realistic end-to-end: **~3–4 weeks** from decision sign-off to a stable, merged, production-ready release.

This can compress to roughly **1.5–2 weeks** if backend (§3–5) and frontend (§6–7) are split across two developers working in parallel, since they're largely independent once the API contract for the new endpoints is agreed.

---

## 10. Suggested Rollout Sequence

1. Lock decisions in §5.
2. Build and merge backend first (§3–5) behind the existing routes — no visible change to any user yet.
3. Build frontend (§6–7) in a feature branch, test against the new backend.
4. Full regression pass (§8) including a copy of production-like data for the "in-flight ACR" backward-compatibility check.
5. Short CCA + Officer user training / comms before flipping the switch.
6. Deploy; monitor the first batch of Employee-raised ACRs closely for the first few days.

---

*No code has been changed as part of this document. This is the plan for review before implementation starts.*

# ACR Portal Role-Based Workflow Guide

This document explains the complete ACR workflow, role responsibilities, allowed actions, and report visibility in the ACR Portal. It is intended for administrators, testers, support teams, and any user who needs to understand what each role can do in the system.

## 1. Purpose

The ACR Portal manages Annual Confidential Report creation, self-appraisal, reporting, reviewing, accepting, supporting documents, and final administrative reporting.

The system follows this lifecycle:

```text
CCA Raised -> Officer Self-Appraisal -> Reporting Authority -> Reviewing Authority -> Accepting Authority -> Final Decision
```

For form type `A1b`, two reporting authorities may be involved:

```text
CCA Raised -> Officer -> RA1 / RA2 -> Reviewing Authority -> Accepting Authority -> Approved / Rejected
```

For form types where RA2 is not assigned, the RA2 step is treated as not applicable.

## 2. System Roles

The portal stores users mainly under these system roles:

| System Role | Meaning | Main Responsibility |
|---|---|---|
| `ADMIN` | System administrator | Manage users, masters, view all ACR records, download complete lifecycle report |
| `CCA` | CCA office user | Create ACR, fill Section I/service details, assign authorities, upload CCA documents |
| `EMPLOYEE` | Employee/officer user | Can act as Officer, RA1, RA2, Reviewing Authority, or Accepting Authority depending on ACR assignment |

Important: Reporting Authority, Reviewing Authority, and Accepting Authority are not separate `system_role` values in the user table. They are employee users assigned to an ACR in authority fields.

## 3. Workflow Statuses

| Status | Meaning | Active Role/Stage |
|---|---|---|
| `DRAFT` | CCA created ACR but has not submitted it to officer | CCA |
| `PENDING_OFFICER` | ACR is waiting for officer self-appraisal | Officer |
| `PENDING_REPORTING` | ACR is waiting for reporting authority assessment | RA1 and, where applicable, RA2 |
| `PENDING_REVIEWING` | ACR is waiting for Reviewing Authority | Reviewing Authority |
| `PENDING_ACCEPTING` | ACR is waiting for Accepting Authority final decision | Accepting Authority |
| `APPROVED` | ACR is finally approved | Final state |
| `REJECTED` | ACR is finally rejected | Final state |

Final states `APPROVED` and `REJECTED` should not be edited through normal role workflows.

## 4. Role Summary

| Role/Actor | Can Create ACR | Can Edit Own Step | Can Submit Step | Can Upload Docs | Can View Full Lifecycle | Can Download Full PDF |
|---|---:|---:|---:|---:|---:|---:|
| Admin | No normal workflow creation | No | No | No | Yes, all ACRs | Yes |
| CCA | Yes | Yes, while draft/non-final where allowed | Yes, draft to officer | Yes, CCA section | Can view ACRs raised by CCA/admin list | No admin lifecycle PDF unless logged as Admin |
| Officer | No | Yes, self-appraisal | Yes | Yes, officer section | Own ACR detail for applicable data | No |
| RA1 | No | Yes, RA1 assessment | Yes | Yes, RA1 section | Assigned reporting detail | No |
| RA2 | No | Yes, RA2 assessment when assigned | Yes | Yes, RA2 section | Assigned reporting detail | No |
| Reviewing Authority | No | Yes, review and score overrides | Yes | Yes, RVA section | Assigned reviewing detail | No |
| Accepting Authority | No | One final decision only | Yes, final approve/reject | Yes, AA section | Assigned accepting detail | No |

## 5. Admin Role

### What Admin Can Do

Admin is responsible for system setup and oversight.

Admin can:

- Manage users.
- Activate or deactivate users.
- Assign designation and geography to users.
- Manage master data such as designation, zone, circle, division, and subdivision.
- View ACR list across the system.
- Open the complete ACR lifecycle report.
- Download the complete ACR report as PDF.
- See information submitted by CCA, Officer, RA1, RA2, Reviewing Authority, and Accepting Authority.

### What Admin Should Not Do

Admin does not perform appraisal workflow actions on behalf of authorities in the normal workflow. Admin should not change grades, approval decisions, or workflow calculations directly from the report.

### Admin Report

The Admin ACR report shows:

- Report header and ACR overview.
- Workflow progress.
- Officer profile.
- Posting and service details.
- Assigned authorities.
- Employee self-appraisal.
- Training and achievements.
- RA1 assessment.
- RA2 assessment or not-applicable/pending state.
- Reviewing Authority review and overrides.
- Uploaded documents.
- Final decision.

If any value is missing, it is displayed as `NA`. Numeric `0`, `false`, and `No` are valid values and are not treated as missing.

## 6. CCA Role

### Purpose

CCA starts the ACR cycle and fills the initial service/profile information.

### CCA Can Do

- Select officer/employee.
- Select designation/form type.
- Enter posting period.
- Enter place/office of posting.
- Enter officer profile and service details:
  - Date of birth
  - Date of joining Nigam
  - Date of joining present rank
  - Date of joining present station
  - Academic qualification
  - Technical qualification
  - Departmental exam passed
  - Property return date
  - Medical exam date
  - Career/posting summary
- Assign authorities:
  - Reporting Authority - RA1
  - Reporting Authority - RA2, where applicable
  - Reviewing Authority
  - Accepting Authority
- Save ACR as draft.
- Submit draft to officer.
- Upload CCA documents and officer photograph while the ACR is not final.

### CCA Workflow

1. Login as CCA.
2. Open CCA ACR page.
3. Click add/create ACR.
4. Fill officer, posting, service, and authority details.
5. Save as draft if information is incomplete.
6. Submit when ready.
7. After submit, status moves from `DRAFT` to `PENDING_OFFICER`.

### CCA Restrictions

- CCA can submit only draft ACRs.
- CCA cannot perform officer self-appraisal.
- CCA cannot submit RA, reviewing, or accepting decisions.
- CCA cannot edit final approved/rejected ACRs through normal workflow.

## 7. Officer / Employee Self-Appraisal

### Purpose

The officer fills their self-appraisal once the ACR reaches `PENDING_OFFICER`.

### Officer Can Do

- View ACR assigned to them.
- Save self-appraisal draft.
- Submit self-appraisal.
- Upload officer-section documents.

### Officer Fields

Officer self-appraisal includes:

- Leave details
- Duties description
- Targets set
- Targets achieved
- Shortfall reasons
- Major achievements
- Membership bodies
- Training details
- Awards/honours
- Auditor compliance, where applicable
- Property declaration
- Medical compliance

### Officer Workflow

1. Login as employee/officer.
2. Open own ACR queue.
3. Open pending ACR.
4. Fill self-appraisal details.
5. Upload supporting documents if required.
6. Save as draft until final.
7. Submit self-appraisal.
8. Status moves from `PENDING_OFFICER` to `PENDING_REPORTING`.

### Officer Restrictions

- Officer can work only when status is `PENDING_OFFICER`.
- Officer cannot edit after submitting self-appraisal.
- Officer cannot edit CCA, RA, Reviewing, or Accepting sections.

## 8. Reporting Authority - RA1

### Purpose

RA1 reviews officer self-appraisal and provides performance assessment.

### RA1 Can Do

- View ACRs assigned to them as Reporting Authority.
- Read CCA details and officer self-appraisal.
- Save reporting assessment draft.
- Submit reporting assessment.
- Upload documents in RA1 section.

### RA1 Assessment Includes

- Agreement with self-appraisal.
- Disagreement details.
- Integrity comments.
- Remarks.
- Performance scores:
  - Work targets
  - Work quality
  - Exceptional work
  - Work overall
  - Attitude
  - Responsibility
  - Stability
  - Communication
  - Moral courage
  - Leadership
  - Timeliness
  - Attributes overall
  - Knowledge
  - Planning
  - Decision making
  - Initiative
  - Teamwork
  - Competency overall
  - Overall grade

### RA1 Workflow

1. Login as assigned employee.
2. Open reporting queue.
3. Open ACR where reporting role is `RA1`.
4. Fill assessment and scores.
5. Save draft if needed.
6. Submit assessment.
7. If no RA2 is applicable, ACR moves to `PENDING_REVIEWING`.
8. If RA2 is applicable and still pending, ACR remains in `PENDING_REPORTING` until RA2 also submits.

### RA1 Restrictions

- RA1 can work only while ACR status is `PENDING_REPORTING`.
- RA1 cannot submit twice.
- RA1 cannot act on ACRs not assigned to them.
- RA1 cannot change officer or CCA details.

## 9. Reporting Authority - RA2

### Purpose

RA2 is used for form type/workflow where a second reporting authority is required, commonly `A1b`.

### RA2 Can Do

- Same reporting functions as RA1, but only when RA2 is assigned.
- Save and submit RA2 assessment.
- Upload documents in RA2 section.

### RA2 Workflow

1. Login as assigned RA2 employee.
2. Open reporting queue.
3. Open ACR where reporting role is `RA2`.
4. Fill assessment and scores.
5. Submit assessment.
6. When both required reporting assessments are submitted, status moves to `PENDING_REVIEWING`.

### RA2 Not Applicable

If RA2 is not assigned or the form type does not require RA2, the report should show a compact `Not Applicable` state instead of many empty RA2 fields.

### RA2 Pending

If RA2 is assigned but has not submitted yet, the report should show RA2 as `Pending`, not `Not Applicable`.

## 10. Reviewing Authority

### Purpose

The Reviewing Authority reviews officer self-appraisal and reporting authority assessment(s).

### Reviewing Authority Can Do

- View ACRs pending review.
- See officer self-appraisal.
- See RA1 and RA2 assessments where available.
- Save reviewing draft.
- Submit review.
- Enter agreement/disagreement with reporting authority.
- Enter comments.
- Enter overall grade.
- Apply score overrides where needed.
- Upload RVA section documents.

### Reviewing Workflow

1. Login as assigned Reviewing Authority.
2. Open reviewing queue.
3. Open ACR in `PENDING_REVIEWING`.
4. Review previous submissions.
5. Fill review comments and grade.
6. Apply score overrides only where required.
7. Save draft if needed.
8. Submit review.
9. Status moves from `PENDING_REVIEWING` to `PENDING_ACCEPTING`.

### Reviewing Restrictions

- Reviewing Authority can work only while status is `PENDING_REVIEWING`.
- Reviewing Authority cannot change officer/CCA/RA submitted data.
- Empty override fields mean no override applied.

## 11. Accepting Authority

### Purpose

Accepting Authority gives the final decision and closes the ACR.

### Accepting Authority Can Do

- View ACRs pending final decision.
- See full previous lifecycle details.
- Upload AA section documents while status is `PENDING_ACCEPTING`.
- Submit final decision.
- Approve or reject the ACR.
- Enter final grade and final remarks.
- Enter disagreement/rejection reason when not agreeing.
- Mark conflict resolved if applicable.

### Accepting Workflow

1. Login as assigned Accepting Authority.
2. Open accepting queue.
3. Open ACR in `PENDING_ACCEPTING`.
4. Review CCA, officer, RA, and Reviewing details.
5. Enter final decision.
6. Submit.
7. If approved, status becomes `APPROVED`.
8. If rejected, status becomes `REJECTED`.

### Accepting Restrictions

- There is no separate accepting draft workflow for final decision.
- Submit is final and closes the ACR.
- Accepting Authority cannot submit final decision unless status is `PENDING_ACCEPTING`.

## 12. Document Upload Rules

Documents are stored section-wise.

| Caller | Stored Section | Allowed Status |
|---|---|---|
| CCA | `CCA` | Any non-final status |
| Officer | `OFFICER` | `PENDING_OFFICER` |
| RA1 | `RA1` | `PENDING_REPORTING` |
| RA2 | `RA2` | `PENDING_REPORTING` |
| Reviewing Authority | `RVA` | `PENDING_REVIEWING` |
| Accepting Authority | `AA` | `PENDING_ACCEPTING` |

CCA officer photograph is stored separately as document type `OFFICER_PHOTO` under section `CCA`.

Each role sees CCA documents in the shared ACR view. Role-specific documents appear under `RoleDocuments` for the current actor. Admin lifecycle report can show all available documents from CCA and role sections.

## 13. Form Types and RA2 Behaviour

| Form Type | Expected Reporting Flow |
|---|---|
| `A1a` | RA1 only, then Reviewing Authority |
| `A1b` | RA1 and RA2 may both be required |
| `A2` | RA1 only, then Reviewing Authority |

RA2 should be treated carefully:

- If no RA2 user is assigned, show `Not Applicable`.
- If RA2 user is assigned but no submission exists, show `Pending`.
- If RA2 submitted, show the full RA2 assessment.
- Do not infer not-applicable only because score fields are empty.

## 14. Final Decision Rules

Final decision is made by Accepting Authority.

The final decision includes:

- Accepting authority
- Whether decision exists
- Approved/rejected status
- Agreement with previous authorities
- Disagreement/rejection reason
- Conflict resolved
- Final grade
- Final remarks
- Decision date

If `IsApproved = true`, ACR status becomes `APPROVED`.

If `IsApproved = false`, ACR status becomes `REJECTED`.

## 15. Admin Complete Lifecycle Report

The admin lifecycle report is read-only. It is meant for audit and review.

The report contains these sections:

1. Report Header
2. ACR Overview
3. Workflow Progress
4. Officer Profile
5. Posting and Service Details
6. Assigned Authorities
7. Employee / Officer Self-Appraisal
8. Training and Achievements
9. Reporting Authority - RA1
10. Reporting Authority - RA2
11. Reviewing Authority
12. Uploaded Documents
13. Final Decision

The report uses these display rules:

- Null or empty values display as `NA`.
- Numeric zero is valid and must display as `0`.
- Boolean values display as `Yes` or `No`.
- RA2 unavailable state is compact.
- Empty Reviewing override values are summarized as `No score overrides were applied.`
- Training JSON is displayed as a table.
- Uploaded documents are displayed as metadata rows.
- PDF output is generated using browser print from report HTML, not from a screenshot.

## 16. End-to-End Example

Example baseline:

| Item | Value |
|---|---|
| Officer | Sachin |
| Designation | SE |
| ACR Year | 2025 |
| Form Type | A1a |
| Posting Location | Hisar Sub |
| Status | Approved |
| RA1 Grade | 4.17 |
| RA2 | Not applicable / not present |
| Reviewing Grade | 9.5 |
| Final Grade | 8.3 |
| Final Decision | Approved |

Expected lifecycle interpretation:

1. CCA raised ACR for Sachin.
2. Officer completed self-appraisal.
3. RA1 submitted assessment with grade `4.17`.
4. RA2 is not applicable because no RA2 is assigned for this ACR/form flow.
5. Reviewing Authority submitted review with grade `9.5`.
6. Accepting Authority approved with final grade `8.3`.
7. Admin can view and download the complete report.

## 17. Common User Questions

### Why can one employee see Officer, Reporting, Reviewing, or Accepting screens?

Because `EMPLOYEE` is the system role. The actual workflow responsibility depends on whether that employee is assigned as officer, RA1, RA2, Reviewing Authority, or Accepting Authority for a specific ACR.

### Can CCA change officer self-appraisal?

No. CCA creates and maintains the initial ACR details but does not fill officer self-appraisal.

### Can RA1 and RA2 both submit?

Yes, when RA2 is assigned and applicable. For RA1-only form flows, RA2 is not applicable.

### Can Admin approve or reject ACR?

No. Admin can view and report. Final approval/rejection is done by the assigned Accepting Authority.

### What happens after final approval or rejection?

The ACR enters a final state. Normal workflow edits and uploads are blocked.

## 18. Quick Checklist By Role

### Admin

- Verify users and master data.
- Review ACR list.
- Open complete lifecycle report.
- Download PDF if needed.

### CCA

- Create ACR.
- Fill Section I/profile/service details.
- Assign authorities.
- Upload CCA documents/photo.
- Submit to officer.

### Officer

- Fill self-appraisal.
- Upload supporting documents.
- Submit to reporting authority.

### RA1 / RA2

- Review officer self-appraisal.
- Fill reporting assessment and scores.
- Upload supporting documents.
- Submit assessment.

### Reviewing Authority

- Review RA assessment(s).
- Add comments, grade, and optional overrides.
- Upload supporting documents.
- Submit to accepting authority.

### Accepting Authority

- Review complete ACR.
- Enter final grade and remarks.
- Approve or reject.

## 19. Technical Reference

Primary API contract documents:

- `Docs/API Contract/Admin_API_Contract (3).md`
- `Docs/API Contract/CCA_API_Contract (2).md`
- `Docs/API Contract/Officer_API_Contract.md`
- `Docs/API Contract/Reporting_API_Contract.md`
- `Docs/API Contract/Reviewing_API_Contract.md`
- `Docs/API Contract/Accepting_API_Contract.md`
- `Docs/API Contract/Document_API_Contract..md`

Main frontend report file:

- `ACRPortal/Views/Home/CCA.aspx`

Main lifecycle detail DTO:

- `ACRPortal.Domain/dtos/WebToApp/Ccaacrdtos.cs`

Main admin report endpoint:

- `GET /api/admin/acr/{acrId}`

Main CCA fallback/detail endpoint:

- `GET /api/cca/acr/{acrId}`

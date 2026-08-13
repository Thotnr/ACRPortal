# CCA Module User Manual

## Introduction

This document explains the `CCA` module of the ACR Portal in simple and non-technical language.

The CCA module is used to create, manage, save, review, and submit officer appraisal records.

This is one of the most important sections of the portal because the appraisal process starts from here.

## Purpose of the CCA Module

The CCA module is used for:

- Creating a new appraisal record for an officer
- Saving the appraisal as draft
- Editing a draft appraisal
- Submitting the appraisal for the next stage
- Searching and reviewing existing appraisal records
- Filtering records by status
- Exporting the current record list to Excel

## Who Uses This Module

This module is mainly used by the `CCA` user.

Important note:

- A `CCA` user can create and submit appraisals
- An `Admin` user can view the screen, but cannot raise a new appraisal from this page

## Main Screen Overview

When the CCA page opens, the user will see:

- A search box to search officer name
- A status filter to check appraisals by progress stage
- A `Reset` button to clear filters
- An `Export` button to download visible records
- A `Raise Appraisal` button to create a new appraisal
- A record list showing existing appraisals

## List Screen Features

The record list shows the following information:

- Officer Name
- Designation
- Posting
- From Date
- To Date
- Status
- Action button

### Available Actions on the List

- `View` button opens the full appraisal form
- Records can be searched by officer name
- Records can be filtered by status
- Records can be sorted by clicking column headings
- Number of rows per page can be changed

## Status Meaning

The following statuses may appear in the CCA list:

- `DRAFT`
  - Record is saved, but not yet submitted
- `PENDING_OFFICER`
  - Record has been submitted by CCA and is now waiting at officer stage
- `PENDING_REPORTING`
  - Record has moved to reporting authority stage
- `PENDING_REVIEWING`
  - Record has moved to reviewing authority stage
- `PENDING_ACCEPTING`
  - Record has moved to accepting authority stage
- `APPROVED`
  - Record has been completed and approved
- `REJECTED`
  - Record has been rejected

## Search and Filter

### Search

The search box is used to search records by officer name.

### Status Filter

The status filter helps the user quickly find records such as:

- Only drafts
- Only pending records
- Only approved records
- Only rejected records

### Reset Button

The `Reset` button clears:

- Search text
- Selected status filter

## Export Feature

The `Export` button downloads the currently visible list of appraisal records into an Excel file.

The exported sheet generally includes:

- Officer Name
- Officer Login ID
- Designation
- Form Type
- Department
- Posting Place
- Posting Dates
- ACR Year
- Status
- Record creation date

## Raise Appraisal

The `Raise Appraisal` button is used to create a new appraisal.

When clicked, a large form opens in a popup window.

## Appraisal Form Sections

The appraisal form is divided into 4 main sections:

1. `Period Details`
2. `Basic Information`
3. `Authorities`
4. `Other Information`

## 1. Period Details

This section captures the appraisal period and place of posting.

### Fields in This Section

- `From`
- `To`
- `Place / Office of Posting`

### What User Needs to Do

1. Select the appraisal start date
2. Select the appraisal end date
3. Select the `Place / Office of Posting`

Important note:

- `Place / Office of Posting` is selected from available SubDivision records already created in Masters

## 2. Basic Information

This section captures officer details and personal information.

### Fields in This Section

- `Name of the Officer`
- `Designation`
- `Date of Birth`
- `Date of Joining in the Nigam`
- `Academic Qualification`
- `Technical Qualification`
- `Date of Joining to Present Rank`
- `Date of Joining to Present Station`
- `Departmental Exam Passed`

### Important Behavior

- When officer is selected, the system links the related designation
- Form title changes automatically according to designation form type

## 3. Authorities

This section is used to assign the appraisal chain.

### Fields in This Section

- `Reporting Authority`
- `Second Reporting Authority` only in some cases
- `Review Authority`
- `Accepting Authority`

### Important Rule

If the selected designation belongs to form type `A1b`, then:

- `Second Reporting Authority` becomes mandatory

If the selected designation belongs to form type `A1a` or `A2`, then:

- `Second Reporting Authority` is not required

### Helpful System Feature

When an officer is selected, the system tries to suggest authority names automatically.

This helps the user fill:

- Reporting Authority
- Review Authority

The user can still verify and adjust the values before saving.

## 4. Other Information

This section captures additional dates.

### Fields in This Section

- `Property Return Date`
- `Medical Exam Date`

## Form Types Used in CCA

The CCA form changes slightly depending on the designation selected.

### A1a

- Used for senior engineering officers
- One reporting authority is required

### A1b

- Used for engineering officers from AE to XEN level
- Two reporting authorities are required

### A2

- Used for general and accounts side officers
- Technical Qualification field is hidden
- Second reporting authority is not required

## How to Create a New Appraisal

1. Open the `CCA` page
2. Click `Raise Appraisal`
3. Fill the period details
4. Select the place of posting
5. Select the officer name
6. Verify the designation
7. Fill the date of birth and other required details
8. Select reporting, review, and accepting authorities
9. Fill other information if available
10. Click `Save as Draft`

Important:

- In this screen, final submit is not done directly at first step
- The record must be saved as draft first

## Save as Draft

The `Save as Draft` button allows the user to save incomplete or in-progress work.

### Why Draft is Useful

- User may not have all information at one time
- User can save the record and continue later
- User can check details again before final submission

### Draft Rule

- At least officer selection is needed to save a draft

After saving draft:

- The record is stored in the system
- It appears in the list with status `DRAFT`
- The same record can be opened again for editing

## Edit Draft Appraisal

A draft record can be edited again whenever needed.

### How to Edit Draft

1. Search the record in the list
2. Click `View`
3. Make required changes
4. Click `Save as Draft` again

Important note:

- If any changes are made after saving draft, the system asks the user to save draft again before final submission

## Final Submission

Once all details are complete and draft is saved, the user can submit the appraisal.

### How to Submit

1. Open the draft record
2. Verify all details carefully
3. Make sure no pending changes are left
4. Click `Submit`

After submission:

- The record moves out of draft stage
- Status changes to `PENDING_OFFICER`
- The appraisal goes to the next stage in the process

## View Existing Appraisal

The `View` button opens an existing appraisal record.

Depending on the record status:

- If status is `DRAFT`, the form can be edited
- If status is already moved ahead, the form opens in view mode only

This helps users review submitted records without changing them.

## Important Validation Rules

The system checks several rules before saving or submitting.

### Date Rules

- Future dates are not allowed
- `To` date must be greater than `From` date
- Appraisal period must be at least 90 days
- Date of birth must be in the past

### Required Information Rules

For final submission, the following are important:

- Posting period
- Officer name
- Designation
- Place of posting
- Date of birth
- Reporting Authority
- Review Authority
- Accepting Authority

### Authority Rules

- Officer cannot be the same as reporting authority
- Officer cannot be the same as review authority
- Officer cannot be the same as accepting authority
- For `A1b`, second reporting authority is compulsory
- Reporting Authority and Second Reporting Authority cannot be the same

### Duplicate Protection

The system also prevents duplicate appraisal creation for the same officer and same posting start period.

## Common Reasons Why Save or Submit May Fail

If the form does not save or submit, common reasons may be:

- Mandatory field is blank
- Posting period is less than 90 days
- Date entered is in future
- Officer and authority names are wrongly selected as same person
- Draft has not been saved yet
- Changes were made after draft save but draft was not saved again
- Same appraisal already exists

## Place of Posting Selection

The `Place / Office of Posting` dropdown is linked to the SubDivision master.

This means:

- SubDivision master should already be available in the system
- If SubDivision records are missing, posting selection may not be properly available

## Authority Selection Guidance

When selecting authorities, user should:

1. Select the correct officer first
2. Check whether system suggestions are shown
3. Verify the suggested names
4. Ensure authorities are not wrongly repeated
5. Confirm second reporting authority where required

## Appraisal Flow in Simple Terms

The overall working flow is:

1. CCA opens the page
2. CCA raises a new appraisal
3. CCA fills the form
4. CCA saves the form as draft
5. CCA reviews and updates the draft if needed
6. CCA submits the draft
7. Record moves to the officer stage

## Read-Only Cases

In some cases, the form opens only for viewing.

Example:

- If record is no longer in draft stage
- If record has already moved ahead in workflow
- If admin is viewing the screen

In such cases, details can be seen but not changed.

## Best Practice for Users

To work smoothly in this module, follow these points:

1. Complete all master setup before using CCA screen
2. Always verify the selected officer and designation
3. Use correct posting dates
4. Save draft before closing the form
5. Review the draft carefully before final submit
6. Check authority names properly before submission
7. Use search and filter to find records quickly
8. Export records whenever a working list is required

## Simple Summary

The CCA module is the starting point of the appraisal process.

In simple words:

1. Create appraisal
2. Save as draft
3. Edit if needed
4. Submit for next stage
5. Track progress using status

## Conclusion

The `CCA` module helps the organization maintain a clean and structured appraisal initiation process. If the draft and submission steps are followed carefully, the appraisal workflow moves smoothly to the next levels without confusion.

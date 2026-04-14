# Masters Module User Manual

## Introduction

This document explains the `Masters` section of the ACR Portal in simple language.

The purpose of the `Masters` section is to create and maintain the basic records required in the system, such as:

- State
- Zone
- Circle
- Division
- SubDivision
- Designation
- Employee

These masters should be created carefully because the rest of the portal works based on this setup.

## Masters Included in This Section

The following pages are available inside the `Masters` menu:

1. `State`
2. `Zone`
3. `Circle`
4. `Division`
5. `SubDivision`
6. `Designation`
7. `Add Employee`

## Correct Order to Use Masters

To avoid errors, masters should be created in the order given below:

1. Create `State`
2. Create `Zone`
3. Create `Circle`
4. Create `Division`
5. Create `SubDivision`
6. Create `Designation`
7. Create `Employee`

This order is important because some pages depend on earlier masters.

Example:

- Circle cannot be created until Zone is available
- Division cannot be created until Circle is available
- SubDivision cannot be created until Division is available
- Employee creation becomes easier after all masters are ready

## Common Features Available on Most Master Pages

Most pages in the `Masters` section work in a similar way.

You will usually see:

- A list of existing records
- A search box to find records quickly
- An `Add` button to create a new record
- An edit icon to update an existing record
- Page size options like 10, 25, 50 etc.
- Column headings that can be used for sorting

## 1. State Master

### Purpose

This page is used to create and manage states in the system.

### Information to Fill

- `State ID`
- `State Name`

### How to Add a State

1. Open `Masters > State`
2. Click `Add State`
3. Enter the `State ID`
4. Enter the `State Name`
5. Click `Save`

### How to Edit a State

1. Find the required state in the list
2. Click the edit icon
3. Update the `State Name`
4. Click `Save`

### Important Points

- Same `State ID` should not be used twice
- Same `State Name` should not be used twice
- Do not leave mandatory fields blank

## 2. Zone Master

### Purpose

This page is used to create and manage zones.

### Information to Fill

- `Zone ID`
- `Zone Name`

### How to Add a Zone

1. Open `Masters > Zone`
2. Click `Add Zone`
3. Enter the `Zone ID`
4. Enter the `Zone Name`
5. Click `Save`

### How to Edit a Zone

1. Find the required zone in the list
2. Click the edit icon
3. Update the `Zone Name`
4. Click `Save`

### Important Points

- Same `Zone ID` should not be used twice
- Same `Zone Name` should not be used twice

## 3. Circle Master

### Purpose

This page is used to create circles under a zone.

### Information to Fill

- `Zone`
- `Circle ID`
- `Circle Name`

### How to Add a Circle

1. Open `Masters > Circle`
2. Click `Add Circle`
3. Select the correct `Zone`
4. Enter the `Circle ID`
5. Enter the `Circle Name`
6. Click `Save`

### How to Edit a Circle

1. Find the required circle in the list
2. Click the edit icon
3. Update the `Circle Name`
4. Click `Save`

### Useful Feature

- You can filter the list by `Zone`

### Important Points

- Zone should already exist before creating a circle
- Same `Circle ID` should not be used twice
- Same `Circle Name` should not be used twice

## 4. Division Master

### Purpose

This page is used to create divisions under a zone and circle.

### Information to Fill

- `Zone`
- `Circle`
- `Division ID`
- `Division Name`

### How to Add a Division

1. Open `Masters > Division`
2. Click `Add Division`
3. Select the correct `Zone`
4. Select the correct `Circle`
5. Enter the `Division ID`
6. Enter the `Division Name`
7. Click `Save`

### How to Edit a Division

1. Find the required division in the list
2. Click the edit icon
3. Update the `Division Name`
4. Click `Save`

### Useful Features

- You can filter the list by `Zone`
- You can also filter the list by `Circle`

### Important Points

- Zone and Circle should already exist before creating a division
- Same `Division ID` should not be used twice
- Same `Division Name` should not be used twice

## 5. SubDivision Master

### Purpose

This page is used to create sub-divisions under a zone, circle, and division.

### Information to Fill

- `Zone`
- `Circle`
- `Division`
- `SubDivision ID`
- `SubDivision Name`

### How to Add a SubDivision

1. Open `Masters > SubDivision`
2. Click `Add SubDivision`
3. Select the correct `Zone`
4. Select the correct `Circle`
5. Select the correct `Division`
6. Enter the `SubDivision ID`
7. Enter the `SubDivision Name`
8. Click `Save`

### How to Edit a SubDivision

1. Find the required sub-division in the list
2. Click the edit icon
3. Update the `SubDivision Name`
4. Click `Save`

### Useful Features

- You can filter the list by `Zone`
- You can filter the list by `Circle`
- You can filter the list by `Division`

### Important Points

- Zone, Circle, and Division should already exist before creating a sub-division
- Same `SubDivision ID` should not be used twice
- Same `SubDivision Name` should not be used twice

## 6. Designation Master

### Purpose

This page is used to create employee designations.

### Information to Fill

- `Designation`
- `Description`
- `Form Type`

### Available Form Types

- `A1a - SE and above`
- `A1b - AE upto XEN`
- `A2 - General and Accounts Wing`

### How to Add a Designation

1. Open `Masters > Designation`
2. Click `Add Designation`
3. Enter the `Designation`
4. Enter the `Description`
5. Select the `Form Type`
6. Click `Save`

### How to Edit a Designation

1. Find the required designation in the list
2. Click the edit icon
3. Update the details
4. Click `Save`

### Important Points

- Same designation should not be created again
- `Form Type` must be selected
- It is better to complete designation setup before adding employees

## 7. Add Employee

### Purpose

This page is used to add and manage employee records in the portal.

### Main Uses

- Add new employee
- Update employee details
- Change employee active or inactive status
- Export employee list
- Filter employee list for quick search

### Employee Form Sections

The employee form has two main parts:

#### A. Basic Details

- `Name`
- `Login ID (HRMS)`
- `Email`
- `Phone`
- `Designation`
- `Type`
- `Reporting Manager`

#### B. Location Details

- `State`
- `Zone`
- `Circle`
- `Division`
- `SubDivision`

### Important Note About Location Selection

Location should be selected step by step:

1. First select `State`
2. Then select `Zone`
3. Then select `Circle`
4. Then select `Division`
5. Then select `SubDivision`

Each next option becomes easier to choose after the previous one is selected.

### How to Add an Employee

1. Open `Masters > Add Employee`
2. Click `Add Employee`
3. Fill in the basic details
4. Select `Designation`
5. Select `Type`
6. Select `Reporting Manager` if needed
7. Select the employee location
8. Click `Save`

### How to Edit an Employee

1. Find the employee in the list
2. Click the edit icon
3. Update the required details
4. Click `Save`

### Useful Features

- Filter by `Designation`
- Filter by `Zone`
- Filter by `Circle`
- Filter by `Division`
- Filter by `SubDivision`
- Search for employee records
- Export current employee list

### Status Change

The employee list also provides a status button.

- If employee is active, active icon is shown
- If employee is inactive, inactive icon is shown
- On clicking the status button, confirmation is asked before changing status

## Common Reasons for Save Errors

If record is not saved, common reasons may be:

- Same ID already exists
- Same name already exists
- Required field is blank
- Parent master is missing
- Wrong master order is being followed

## Best Practice for Users

For smooth working, follow these points:

1. Always create masters in the correct order
2. Check existing records before creating a new one
3. Avoid duplicate IDs and duplicate names
4. Complete location masters before employee entry
5. Complete designation master before employee entry
6. Use search and filters before adding new records

## Simple Flow Summary

The easiest way to understand the full process is:

1. First create location masters
   `State -> Zone -> Circle -> Division -> SubDivision`
2. Then create `Designation`
3. Finally create `Employee`

If this sequence is followed, the system setup remains clean and easy to manage.

## Conclusion

The `Masters` section is the base setup of the ACR Portal. Once these records are created properly, employee management and further portal operations become smooth and well-organized.

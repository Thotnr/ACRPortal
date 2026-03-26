# External Libraries Used in ACRPortal UI

## Summary
**Total External CDN Libraries: 3 unique libraries**

---

## 📊 Library Breakdown

### 1. **Bootstrap 5.3.2** (UI Framework)
- **Purpose**: Responsive CSS framework for layout and components
- **Type**: CSS + JavaScript
- **Used in**: Reviewing.aspx, Reporting.aspx, Officer.aspx, Accepting.aspx

**Links:**
- **CSS**: `https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css`
- **JS**: `https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js`

---

### 2. **Bootstrap Icons 1.10.5** (Icon Library)
- **Purpose**: Font icons for UI elements
- **Type**: Font (CSS)
- **Used in**: Reviewing.aspx, Reporting.aspx, Officer.aspx, Accepting.aspx

**Link:**
- **CSS**: `https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css`

---

### 3. **jQuery 3.7.1** (JavaScript Library)
- **Purpose**: DOM manipulation and AJAX requests
- **Type**: JavaScript
- **Used in**: Reviewing.aspx, Reporting.aspx, Officer.aspx, Accepting.aspx

**Link:**
- **JS**: `https://code.jquery.com/jquery-3.7.1.min.js`

---

### 4. **Select2 4.1.0-rc.0** (Dropdown Enhancement)
- **Purpose**: Enhanced select dropdown with search and multi-select
- **Type**: CSS + JavaScript
- **Used in**: CCA.aspx (Only)

**Links:**
- **CSS**: `https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css`
- **JS**: `https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js`

---

## 📋 File-wise Usage

| File | Bootstrap | Bootstrap Icons | jQuery | Select2 |
|------|-----------|-----------------|--------|---------|
| Reviewing.aspx | ✅ | ✅ | ✅ | ❌ |
| Reporting.aspx | ✅ | ✅ | ✅ | ❌ |
| Officer.aspx | ✅ | ✅ | ✅ | ❌ |
| Accepting.aspx | ✅ | ✅ | ✅ | ❌ |
| CCA.aspx | ❌ | ❌ | ❌ | ✅ |

---

## 🏠 Internal Libraries

### Local Assets:
- **constant.js** (~/assets/js/shared/constant.js) - Custom constants and utility functions

---

## 📌 CDN Provider
- **Primary CDN**: jsDelivr (cdn.jsdelivr.net)
- **Secondary CDN**: jQuery Official (code.jquery.com)

All external libraries are loaded via CDN (Content Delivery Network) for faster performance.

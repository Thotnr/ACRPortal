# Auth API Contract
**RoutePrefix:** `api/auth`  
**Controller:** `AuthController.cs`  
**All responses:** `ApiResponse<T>`

---

## Bugs Fixed in This Implementation
1. **JWT role claim bug** — `EncodeJwtToken` was receiving `user.DisplayName` where `systemRole` was expected. Fixed: now passes `user.SystemRole`.
2. **Route prefix** — Login endpoints were on `api/user`. Moved to `api/auth` via new `AuthController`.
3. **`MarkExpiredOtpEntries`** — was using plain `loginId` as lookup but OTP table stores AES-encrypted identity. Fixed to pass `identityHash`.

---

## API 1 — Login Step 1
**POST** `/api/auth/login/step1`  
Public — no token required.

### Request
```json
{ "LoginId": "emp_001", "Password": "welcome@123" }
```

### Success `200`
```json
{
  "Success": true,
  "Message": "OTP sent successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `BAD_REQUEST` | LoginId and Password are required | 400 |
| `AUTH_FAILED` | Invalid credentials | 401 |
| `ACCOUNT_INACTIVE` | Your account is not active | 403 |
| `RATE_LIMIT` | Too many OTP requests. Please wait 60 seconds | 429 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

---

## API 2 — Login Step 2
**POST** `/api/auth/login/step2`  
Public — no token required.

### Request
```json
{ "LoginId": "emp_001", "Otp": "123456" }
```

### Success `200`
```json
{
  "Success": true,
  "Message": "Login successful",
  "Data": {
    "Token": "eyJhbGci...",
    "ExpiresAt": "2026-03-06T10:00:00",
    "UserId": "a1b2c3d4-...",
    "DisplayName": "Ramesh Kumar",
    "SystemRole": "EMPLOYEE"
  },
  "ErrorCode": null
}
```

### LoginResponse model
```csharp
public class LoginResponse {
    public string Token { get; set; }
    public DateTime ExpiresAt { get; set; }
    public string UserId { get; set; }
    public string DisplayName { get; set; }
    public string SystemRole { get; set; }
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `BAD_REQUEST` | LoginId and OTP are required | 400 |
| `OTP_INVALID` | Invalid or expired OTP | 401 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

---

## API 3 — Logout
**POST** `/api/auth/logout`  
Requires: `Authorization: Bearer <token>`

Extracts `session_id` from JWT claims → marks session as `REVOKED` in DB.

### Request
No body.

### Success `200`
```json
{
  "Success": true,
  "Message": "Logged out successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `TOKEN_INVALID` | Token missing or invalid | 401 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

---

## API 4 — Get Current User (Me)
**GET** `/api/auth/me`  
Requires: `Authorization: Bearer <token>`

Reads `user_id` from JWT → fetches fresh user data from DB. Useful for page load/session check.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "UserId": "a1b2c3d4-...",
    "LoginId": "emp_001",
    "DisplayName": "Ramesh Kumar",
    "SystemRole": "EMPLOYEE",
    "UserStatus": "ACTIVE"
  },
  "ErrorCode": null
}
```

### MeResponse model
```csharp
public class MeResponse {
    public string UserId { get; set; }
    public string LoginId { get; set; }
    public string DisplayName { get; set; }
    public string SystemRole { get; set; }
    public string UserStatus { get; set; }
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `TOKEN_INVALID` | Token missing or invalid | 401 |
| `USER_NOT_FOUND` | User no longer exists | 404 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

---

## API 5 — Change Password
**POST** `/api/auth/change-password`  
Requires: `Authorization: Bearer <token>`

Used when user wants to update their own password (e.g., after first login with `welcome@123`).

### Request
```json
{
  "CurrentPassword": "welcome@123",
  "NewPassword": "MyNewPass@456"
}
```

### Success `200`
```json
{
  "Success": true,
  "Message": "Password changed successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `TOKEN_INVALID` | Token missing or invalid | 401 |
| `BAD_REQUEST` | CurrentPassword and NewPassword are required | 400 |
| `WRONG_PASSWORD` | Current password is incorrect | 400 |
| `SAME_PASSWORD` | New password cannot be the same as current | 400 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

---

## API 6 — Forgot Password
**POST** `/api/auth/forgot-password`  
Public — no token required.

Generates a reset token, stores in `users.reset_token` + `users.reset_token_expiry` (already in schema), and sends email. Always returns 200 regardless of whether LoginId exists (security — no user enumeration).

### Request
```json
{ "LoginId": "emp_001" }
```

### Success `200`
```json
{
  "Success": true,
  "Message": "If this account exists, a password reset link has been sent",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `BAD_REQUEST` | LoginId is required | 400 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

> Note: Never returns 404 for unknown LoginId — intentional.

---

## API 7 — Reset Password
**POST** `/api/auth/reset-password`  
Public — no token required.

Validates reset token from DB, updates password, clears token columns.

### Request
```json
{
  "LoginId": "emp_001",
  "ResetToken": "abc123xyz...",
  "NewPassword": "ResetPass@789"
}
```

### Success `200`
```json
{
  "Success": true,
  "Message": "Password reset successful. Please login with your new password.",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| ErrorCode | Message | HTTP |
|---|---|---|
| `BAD_REQUEST` | All fields are required | 400 |
| `TOKEN_INVALID` | Reset token is invalid or has expired | 400 |
| `INTERNAL_ERROR` | Unexpected error | 500 |

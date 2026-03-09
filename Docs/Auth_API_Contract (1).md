# Auth API Contract
**RoutePrefix:** `api/auth`  
**Controller:** `AuthController.cs`  
**All responses:** `ApiResponse<T>`

---

## Bugs Fixed in This Implementation
1. **JWT role claim bug** — `EncodeJwtToken` was receiving `user.DisplayName` where `systemRole` was expected. Fixed: now passes `user.SystemRole`.
2. **Route prefix** — Login endpoints were on `api/user`. Moved to `api/auth` via `AuthController`. `UserController` now only handles `POST /api/user/createuser`.
3. **`MarkExpiredOtpEntries`** — was passing plain `loginId` but OTP table stores AES-encrypted identity. Fixed: now passes `identityHash`.
4. **`CountRecentOtpAttempts`** — same bug as #3. Fixed: now passes `identityHash`.
5. **OTP reuse** — `MarkOtpAsVerified` was never called after successful OTP validation. Fixed: called immediately after `GetOtp` returns a result.
6. **`ACCOUNT_INACTIVE` check missing** — `LoginStep1` never checked `user_status`. Fixed: returns `ACCOUNT_INACTIVE` / 403 if status is not `ACTIVE`.
7. **`LoginResponse` incomplete** — only had `Token` and `SystemRole`. Fixed: now includes `ExpiresAt`, `UserId`, `DisplayName`.
8. **Audience mismatch** — `AppliesToAddress` in `EncodeJwtToken` required a full URI. Fixed: removed audience from encode/decode entirely, `ValidateAudience = false`.

---

## Architecture

```
AuthController  →  IAuthUseCase  →  AuthService  →  IAuthRepoPort  →  AuthAdapter
UserController  →  IUserUseCase  →  UserService  →  IUserRepoPort  →  UserAdapter
```

`AuthService` handles all auth flows (login, logout, me, passwords).  
`UserService` handles user management only (signup — called by ADMIN).

---

## API 1 — Login Step 1
**POST** `/api/auth/login/step1`  
Public — `[NoAuth]`, no token required.

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
| Scenario | ErrorCode | Message | HTTP |
|---|---|---|---|
| Missing fields | `BAD_REQUEST` | LoginId and Password are required | 400 |
| Wrong credentials | `AUTH_FAILED` | Invalid credentials | 401 |
| Account not active | `ACCOUNT_INACTIVE` | Your account is not active | 403 |
| Too many OTP requests | `RATE_LIMIT` | Too many OTP requests. Please wait 60 seconds | 429 |
| Unexpected error | `INTERNAL_ERROR` | exception message | 500 |

---

## API 2 — Login Step 2
**POST** `/api/auth/login/step2`  
Public — `[NoAuth]`, no token required.

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

### `LoginResponse` model
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
| Scenario | ErrorCode | Message | HTTP |
|---|---|---|---|
| Missing fields | `BAD_REQUEST` | LoginId and OTP are required | 400 |
| Invalid / expired OTP | `OTP_INVALID` | Invalid or expired OTP | 401 |
| Unexpected error | `INTERNAL_ERROR` | exception message | 500 |

---

## API 3 — Logout
**POST** `/api/auth/logout`  
Requires: `Authorization: Bearer <token>`

Extracts encrypted `sid` claim from JWT → decrypts it → marks session as `REVOKED` in DB.

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
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Get Current User
**GET** `/api/auth/me`  
Requires: `Authorization: Bearer <token>`

Reads decrypted `user_id` from JWT (set by `JwtApiAuthFilter`) → fetches fresh user row from DB.

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

### `MeResponse` model
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
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| User deleted from DB | `USER_NOT_FOUND` | 404 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 5 — Change Password
**POST** `/api/auth/change-password`  
Requires: `Authorization: Bearer <token>`

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
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Missing fields | `BAD_REQUEST` | 400 |
| Token invalid | `TOKEN_INVALID` | 401 |
| Wrong current password | `WRONG_PASSWORD` | 400 |
| New == current | `SAME_PASSWORD` | 400 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 6 — Forgot Password
**POST** `/api/auth/forgot-password`  
Public — `[NoAuth]`, no token required.

Generates a reset token, hashes it with SHA-256, stores hash in `users.reset_token` + expiry in `users.reset_token_expiry`. Always returns 200 — never reveals if LoginId exists.

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

> Note: Only returns `INTERNAL_ERROR` / 500 on unexpected exceptions. Never 404.

---

## API 7 — Reset Password
**POST** `/api/auth/reset-password`  
Public — `[NoAuth]`, no token required.

Hashes incoming `ResetToken` with SHA-256, looks up matching row in DB with valid expiry, updates password, clears token columns.

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
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Missing fields | `BAD_REQUEST` | 400 |
| Token invalid / expired | `TOKEN_INVALID` | 400 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## `IdentityModels.User` — current shape
```csharp
public class User {
    public Guid UserId { get; set; }
    public string LoginId { get; set; }
    public string PasswordHash { get; set; }
    public string DisplayName { get; set; }
    public string SystemRole { get; set; }
    public string UserStatus { get; set; }   // raw: PENDING / ACTIVE / INACTIVE
    public bool IsActive => UserStatus == "ACTIVE";  // computed — read-only
}
```

> `IsActive` is computed from `UserStatus`. Never assign it directly.

---

## Login page JS — endpoints to call
```javascript
// Step 1
POST /api/auth/login/step1

// Step 2
POST /api/auth/login/step2
```
> Login.cshtml must be updated — old endpoints were `/api/user/login/step1` and `/api/user/login/step2`.

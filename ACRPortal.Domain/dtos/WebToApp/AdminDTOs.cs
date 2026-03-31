using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Request DTOs                                                        //
    // ------------------------------------------------------------------ //

    public class CreateUserRequest
    {
        // Required
        public string DisplayName { get; set; }
        public string LoginId { get; set; }

        // Optional — defaults applied in service
        public string Password { get; set; }   // default: "welcome@123"
        public string SystemRole { get; set; }   // default: "EMPLOYEE"

        // Contact info — inserted into dbo.user_identities
        public string Email { get; set; }   // optional — stored as identity_type = 'EMAIL'
        public string Phone { get; set; }   // optional — stored as identity_type = 'PHONE'

        // Optional master data — all nullable
        public int? DsgId { get; set; }   // FK → tbDsg.dsgId
        public int? StateId { get; set; }   // FK → State.State_ID
        public int? ZoneId { get; set; }   // FK → Zone.Zone_ID
        public int? CircleId { get; set; }   // FK → Circle.Circle_ID
        public int? DivisionId { get; set; }   // FK → Division.Division_ID
        public int? SubDivisionId { get; set; }   // FK → SubDivision.SubDivisionID

        // Optional — must be an ACTIVE EMPLOYEE; cannot be the user being created
        public string ManagerId { get; set; }   // manager's login_id, nullable
    }

    public class UpdateUserRequest
    {
        // All nullable — only non-null fields are applied.
        // UserId, LoginId, SystemRole, UserStatus, CreatedAt are immutable (ignored if sent).
        public string DisplayName { get; set; }
        public string Password { get; set; }   // if set, re-hashed and stored
        public string Email { get; set; }   // if set, replaces existing EMAIL identity (AES-encrypted)
        public string Phone { get; set; }   // if set, replaces existing PHONE identity (AES-encrypted)
        public int? DsgId { get; set; }
        public int? StateId { get; set; }
        public int? ZoneId { get; set; }
        public int? CircleId { get; set; }
        public int? DivisionId { get; set; }
        public int? SubDivisionId { get; set; }

        // Manager — must be ACTIVE EMPLOYEE; cannot be the user being updated
        public string ManagerId { get; set; }   // manager's login_id, nullable

        // Explicit clear flags
        public bool ClearEmail { get; set; }      // true → deletes EMAIL identity row
        public bool ClearPhone { get; set; }      // true → deletes PHONE identity row
        public bool ClearDsg { get; set; }        // true → sets dsg_id = NULL
        public bool ClearGeography { get; set; }  // true → clears all 5 geography fields
        public bool ClearManager { get; set; }    // true → sets manager_id = NULL
    }

    public class UpdateUserStatusRequest
    {
        public string UserStatus { get; set; }   // "ACTIVE" | "INACTIVE"
    }

    // ------------------------------------------------------------------ //
    //  Response DTOs                                                       //
    // ------------------------------------------------------------------ //

    public class CreateUserResponse
    {
        public string UserId { get; set; }
    }

    public class UserListItem
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }
        public int? DsgId { get; set; }
        public int? StateId { get; set; }
        public int? ZoneId { get; set; }
        public int? CircleId { get; set; }
        public int? DivisionId { get; set; }
        public int? SubDivisionId { get; set; }
        public string Email { get; set; }          // nullable, decrypted
        public string Phone { get; set; }          // nullable, decrypted
        public string ManagerId { get; set; }     // manager's login_id, nullable
        public string CreatedAt { get; set; }     // ISO 8601
    }


    public class UserDetailResponse
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }
        public string CreatedAt { get; set; }   // ISO 8601

        // Contact info (decrypted from dbo.user_identities)
        public string Email { get; set; }   // nullable
        public string Phone { get; set; }   // nullable

        // Master data — IDs only, all nullable
        public int? DsgId { get; set; }
        public int? StateId { get; set; }
        public int? ZoneId { get; set; }
        public int? CircleId { get; set; }
        public int? DivisionId { get; set; }
        public int? SubDivisionId { get; set; }

        // Manager
        public string ManagerId { get; set; }     // manager's login_id, nullable
    }

    // ------------------------------------------------------------------ //
    //  Bulk import                                                         //
    // ------------------------------------------------------------------ //

    public class BulkCreateResult
    {
        public int TotalRows { get; set; }
        public int SuccessCount { get; set; }
        public int FailureCount { get; set; }
        public List<RowError> Errors { get; set; } = new List<RowError>();
    }

    public class RowError
    {
        public int RowNumber { get; set; }   // 1-based; header = 1, first data = 2
        public string LoginId { get; set; }   // null if not parseable from that row
        public string Reason { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Admin ACR Management                                               //
    // ------------------------------------------------------------------ //

    public class AdminAcrListItem
    {
        public string AcrId { get; set; }
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; }  // "YYYY-MM-DD"
        public string PostingTo { get; set; }    // "YYYY-MM-DD"
        public string OfficerUserId { get; set; }
        public string OfficerName { get; set; }
        public string OfficerLoginId { get; set; }
        public string ReportingName { get; set; }
        public string ReviewingName { get; set; }
    }
}
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

        // Optional master data — all nullable
        public int? DsgId { get; set; }   // FK → tbDsg.dsgId
        public int? StateId { get; set; }   // FK → State.State_ID
        public int? ZoneId { get; set; }   // FK → Zone.Zone_ID
        public int? CircleId { get; set; }   // FK → Circle.Circle_ID
        public int? DivisionId { get; set; }   // FK → Division.Division_ID
        public int? SubDivisionId { get; set; }   // FK → SubDivision.SubDivisionID
    }

    public class UpdateUserRequest
    {
        // All nullable — only non-null fields are applied.
        // LoginId and SystemRole are immutable (ignored if sent).
        public string DisplayName { get; set; }
        public int? DsgId { get; set; }
        public int? StateId { get; set; }
        public int? ZoneId { get; set; }
        public int? CircleId { get; set; }
        public int? DivisionId { get; set; }
        public int? SubDivisionId { get; set; }

        // Send explicit "clear" flags to null out a field
        public bool ClearDsg { get; set; }
        public bool ClearGeography { get; set; }  // clears all 5 geography fields at once
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
        public string DsgName { get; set; }   // joined from tbDsg
        public string SubDivision { get; set; }   // joined from SubDivision table
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class UserListResponse
    {
        public List<UserListItem> Users { get; set; }
        public int TotalCount { get; set; }
    }

    public class UserDetailResponse
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }
        public string CreatedAt { get; set; }

        // Designation
        public int? DsgId { get; set; }
        public string DsgName { get; set; }

        // Geography — all nullable
        public int? StateId { get; set; }
        public string StateName { get; set; }
        public int? ZoneId { get; set; }
        public string ZoneName { get; set; }
        public int? CircleId { get; set; }
        public string CircleName { get; set; }
        public int? DivisionId { get; set; }
        public string DivisionName { get; set; }
        public int? SubDivisionId { get; set; }
        public string SubDivision { get; set; }
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
}
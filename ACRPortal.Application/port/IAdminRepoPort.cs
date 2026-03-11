using System;
using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    /// <summary>
    /// Data access port for admin user management.
    /// Implemented by AdminAdapter in ACRPortal.Infrastructure.
    /// </summary>
    public interface IAdminRepoPort
    {
        // ---- Existence checks --------------------------------------------
        bool IsLoginIdExists(string loginId);
        bool IsUserExists(Guid userId);

        // ---- Master data validation (read-only lookups) ------------------
        bool IsDsgIdValid(int dsgId);
        bool IsStateIdValid(int stateId);
        bool IsZoneIdValid(int zoneId);
        bool IsCircleIdValid(int circleId);
        bool IsDivisionIdValid(int divisionId);
        bool IsSubDivisionIdValid(int subDivisionId);

        // Parent-child hierarchy checks
        bool IsCircleInZone(int circleId, int zoneId);
        bool IsDivisionInCircle(int divisionId, int circleId);
        bool IsSubDivisionInDivision(int subDivisionId, int divisionId);

        // ---- Reads used for hierarchy resolution on partial update -------
        // Returns current geography IDs for a user (nulls if not set)
        UserGeoSnapshot GetUserGeoSnapshot(Guid userId);

        // ---- Write operations --------------------------------------------
        /// <summary>
        /// Creates a user and inserts email/phone identities in a single transaction.
        /// If either identity is a duplicate the entire operation is rolled back
        /// and a SqlException with Number 2627 or 2601 is thrown — caught in AdminService.
        /// </summary>
        string CreateUserWithIdentities(
            string displayName,
            string loginId,
            string passwordHash,
            string systemRole,
            int? dsgId,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId,
            string email,          // nullable
            string phone           // nullable
        );  // returns new user_id as string

        void UpdateUser(
            Guid userId,
            string displayName,
            int? dsgId,
            bool clearDsg,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId,
            bool clearGeography
        );

        void UpdateUserStatus(Guid userId, string userStatus);

        // ---- Reads -------------------------------------------------------
        UserListResponse GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId);
        UserDetailResponse GetUserById(Guid userId);
    }

    /// <summary>
    /// Snapshot of a user's current geography IDs — used to validate
    /// partial updates where only some levels of the hierarchy are sent.
    /// </summary>
    public class UserGeoSnapshot
    {
        public int? StateId { get; set; }
        public int? ZoneId { get; set; }
        public int? CircleId { get; set; }
        public int? DivisionId { get; set; }
        public int? SubDivisionId { get; set; }
    }
}
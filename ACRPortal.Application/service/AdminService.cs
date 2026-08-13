using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Application.service
{
    public class AdminService : IAdminUseCase
    {
        private readonly IAdminRepoPort _repo;
        private readonly ICcaRepoPort _ccaRepo;
        private readonly IDocumentRepoPort _docs;
        private readonly Security _security;

        public AdminService(IAdminRepoPort repo, ICcaRepoPort ccaRepo, IDocumentRepoPort docs)
        {
            _repo = repo;
            _ccaRepo = ccaRepo;
            _docs = docs;
            _security = new Security();
        }

        // ------------------------------------------------------------------ //
        //  Create User                                                         //
        // ------------------------------------------------------------------ //
        public ApiResponse<CreateUserResponse> CreateUser(CreateUserRequest req)
        {
            try
            {
                if (req == null)
                    return ApiResponse<CreateUserResponse>.Fail("Request body is required", "BAD_REQUEST");

                if (string.IsNullOrWhiteSpace(req.DisplayName) || string.IsNullOrWhiteSpace(req.LoginId))
                    return ApiResponse<CreateUserResponse>.Fail("DisplayName and LoginId are required", "BAD_REQUEST");

                // Defaults
                string role = string.IsNullOrWhiteSpace(req.SystemRole) ? "EMPLOYEE" : req.SystemRole.ToUpper();
                string password = string.IsNullOrWhiteSpace(req.Password) ? "welcome@123" : req.Password;

                if (role != "CCA" && role != "EMPLOYEE")
                    return ApiResponse<CreateUserResponse>.Fail("SystemRole must be CCA or EMPLOYEE", "BAD_REQUEST");

                // LoginId uniqueness
                if (_repo.IsLoginIdExists(req.LoginId))
                    return ApiResponse<CreateUserResponse>.Fail("LoginId already exists", "USER_EXISTS");

                // Validate geography hierarchy
                var geoError = ValidateGeoOnCreate(req);
                if (geoError != null) return geoError;

                // Validate ManagerId (login_id) if provided
                if (!string.IsNullOrWhiteSpace(req.ManagerId))
                {
                    // Cannot assign the user's own LoginId as their manager on create
                    // (edge case: if ManagerId == the LoginId being created right now)
                    if (string.Equals(req.ManagerId.Trim(), req.LoginId.Trim(), StringComparison.OrdinalIgnoreCase))
                        return ApiResponse<CreateUserResponse>.Fail("A user cannot be their own manager", "BAD_REQUEST");

                    if (!_repo.IsValidManager(req.ManagerId.Trim()))
                        return ApiResponse<CreateUserResponse>.Fail(
                            "Manager not found or is not an active employee", "INVALID_MANAGER");
                }

                // Hash password
                string hash = _security.HashWithSha256(password);

                string userId;
                try
                {
                    userId = _repo.CreateUserWithIdentities(
                        req.DisplayName.Trim(),
                        req.LoginId.Trim(),
                        hash,
                        role,
                        req.DsgId,
                        req.StateId,
                        req.ZoneId,
                        req.CircleId,
                        req.DivisionId,
                        req.SubDivisionId,
                        string.IsNullOrWhiteSpace(req.ManagerId) ? null : req.ManagerId.Trim(),
                        string.IsNullOrWhiteSpace(req.Email) ? null : req.Email.Trim(),
                        string.IsNullOrWhiteSpace(req.Phone) ? null : req.Phone.Trim()
                    );
                }
                catch (System.Data.SqlClient.SqlException sqlEx) when (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                {
                    string field = sqlEx.Message.Contains("PHONE") ? "phone number" : "email address";
                    return ApiResponse<CreateUserResponse>.Fail(
                        $"This {field} is already registered to another user",
                        "DUPLICATE_IDENTITY");
                }

                return ApiResponse<CreateUserResponse>.Ok(
                    new CreateUserResponse { UserId = userId },
                    "User created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<CreateUserResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Get All Users                                                       //
        // ------------------------------------------------------------------ //
        public ApiResponse<PagedResult<UserListItem>> GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId, int pageNumber, int pageSize, string search = null)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(role))
                {
                    role = role.ToUpper();
                    if (role != "CCA" && role != "EMPLOYEE")
                        return ApiResponse<PagedResult<UserListItem>>
                            .Fail("Role filter must be CCA or EMPLOYEE", "BAD_REQUEST");
                }

                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0 || pageSize > 100) pageSize = 10;

                var result = _repo.GetAllUsers(role, status, dsgId, zoneId, divisionId, pageNumber, pageSize, search);

                return ApiResponse<PagedResult<UserListItem>>.Ok(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<PagedResult<UserListItem>>
                    .Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Get User By Id                                                      //
        // ------------------------------------------------------------------ //
        public ApiResponse<UserDetailResponse> GetUserById(string userId)
        {
            try
            {
                Guid guid;
                if (!Guid.TryParse(userId, out guid))
                    return ApiResponse<UserDetailResponse>.Fail("Invalid userId format", "BAD_REQUEST");

                var user = _repo.GetUserById(guid);
                if (user == null)
                    return ApiResponse<UserDetailResponse>.Fail("User not found", "USER_NOT_FOUND");

                return ApiResponse<UserDetailResponse>.Ok(user, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<UserDetailResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Update User Profile                                                 //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> UpdateUser(string userId, UpdateUserRequest req)
        {
            try
            {
                if (req == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");

                Guid guid;
                if (!Guid.TryParse(userId, out guid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid userId format", "BAD_REQUEST");

                if (!_repo.IsUserExists(guid))
                    return ApiResponse<EmptyResponse>.Fail("User not found", "USER_NOT_FOUND");

                // Validate geography hierarchy
                var geoError = ValidateGeoOnUpdate(req, guid);
                if (geoError != null) return geoError;

                // Validate ManagerId (login_id) if provided and not being cleared
                string managerLoginId = null;
                if (!req.ClearManager && !string.IsNullOrWhiteSpace(req.ManagerId))
                {
                    managerLoginId = req.ManagerId.Trim();

                    // Fetch the user's own login_id to guard against self-assignment
                    var target = _repo.GetUserById(guid);
                    if (target != null && string.Equals(managerLoginId, target.LoginId, StringComparison.OrdinalIgnoreCase))
                        return ApiResponse<EmptyResponse>.Fail("A user cannot be their own manager", "BAD_REQUEST");

                    if (!_repo.IsValidManager(managerLoginId))
                        return ApiResponse<EmptyResponse>.Fail(
                            "Manager not found or is not an active employee", "INVALID_MANAGER");
                }

                // Hash password if being changed
                string passwordHash = null;
                if (!string.IsNullOrWhiteSpace(req.Password))
                    passwordHash = _security.HashWithSha256(req.Password.Trim());

                // Update user row fields
                _repo.UpdateUser(
                    guid,
                    string.IsNullOrWhiteSpace(req.DisplayName) ? null : req.DisplayName.Trim(),
                    passwordHash,
                    req.DsgId,
                    req.ClearDsg,
                    req.StateId,
                    req.ZoneId,
                    req.CircleId,
                    req.DivisionId,
                    req.SubDivisionId,
                    req.ClearGeography,
                    managerLoginId,
                    req.ClearManager
                );

                // Handle identity upserts / deletes
                if (req.ClearEmail)
                    _repo.DeleteUserIdentity(guid, "EMAIL");
                else if (!string.IsNullOrWhiteSpace(req.Email))
                {
                    try { _repo.UpsertUserIdentity(guid, "EMAIL", req.Email.Trim()); }
                    catch (System.Data.SqlClient.SqlException sqlEx) when (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                    {
                        return ApiResponse<EmptyResponse>.Fail(
                            "This email address is already registered to another user", "DUPLICATE_IDENTITY");
                    }
                }

                if (req.ClearPhone)
                    _repo.DeleteUserIdentity(guid, "PHONE");
                else if (!string.IsNullOrWhiteSpace(req.Phone))
                {
                    try { _repo.UpsertUserIdentity(guid, "PHONE", req.Phone.Trim()); }
                    catch (System.Data.SqlClient.SqlException sqlEx) when (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                    {
                        return ApiResponse<EmptyResponse>.Fail(
                            "This phone number is already registered to another user", "DUPLICATE_IDENTITY");
                    }
                }

                return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "User updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Update User Status                                                  //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> UpdateUserStatus(string userId, string userStatus)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userStatus))
                    return ApiResponse<EmptyResponse>.Fail("UserStatus is required", "BAD_REQUEST");

                userStatus = userStatus.ToUpper();
                if (userStatus != "ACTIVE" && userStatus != "INACTIVE")
                    return ApiResponse<EmptyResponse>.Fail("UserStatus must be ACTIVE or INACTIVE", "BAD_REQUEST");

                Guid guid;
                if (!Guid.TryParse(userId, out guid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid userId format", "BAD_REQUEST");

                if (!_repo.IsUserExists(guid))
                    return ApiResponse<EmptyResponse>.Fail("User not found", "USER_NOT_FOUND");

                _repo.UpdateUserStatus(guid, userStatus);

                return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "User status updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Unlock User (clears the failed-login-attempt lockout)              //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> UnlockUser(string userId)
        {
            try
            {
                Guid guid;
                if (!Guid.TryParse(userId, out guid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid userId format", "BAD_REQUEST");

                if (!_repo.IsUserExists(guid))
                    return ApiResponse<EmptyResponse>.Fail("User not found", "USER_NOT_FOUND");

                _repo.UnlockUser(guid);

                return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "User unlocked successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Private — Geography Validation                                     //
        // ================================================================== //

        /// <summary>
        /// Validates the full hierarchy on create.
        /// All IDs are available in the request — no need to fetch existing state.
        /// Hierarchy rule: each level must exist AND belong to its parent.
        /// </summary>
        private ApiResponse<CreateUserResponse> ValidateGeoOnCreate(CreateUserRequest req)
        {
            if (req.DsgId.HasValue && !_repo.IsDsgIdValid(req.DsgId.Value))
                return ApiResponse<CreateUserResponse>.Fail("Designation not found", "INVALID_DSG");

            if (req.StateId.HasValue && !_repo.IsStateIdValid(req.StateId.Value))
                return ApiResponse<CreateUserResponse>.Fail("State not found", "INVALID_STATE");

            if (req.ZoneId.HasValue && !_repo.IsZoneIdValid(req.ZoneId.Value))
                return ApiResponse<CreateUserResponse>.Fail("Zone not found", "INVALID_ZONE");

            if (req.CircleId.HasValue)
            {
                if (!req.ZoneId.HasValue)
                    return ApiResponse<CreateUserResponse>.Fail("ZoneId is required when CircleId is provided", "BAD_REQUEST");
                if (!_repo.IsCircleIdValid(req.CircleId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("Circle not found", "INVALID_CIRCLE");
                if (!_repo.IsCircleInZone(req.CircleId.Value, req.ZoneId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("Circle does not belong to the given Zone", "INVALID_CIRCLE");
            }

            if (req.DivisionId.HasValue)
            {
                if (!req.CircleId.HasValue)
                    return ApiResponse<CreateUserResponse>.Fail("CircleId is required when DivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsDivisionIdValid(req.DivisionId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("Division not found", "INVALID_DIVISION");
                if (!_repo.IsDivisionInCircle(req.DivisionId.Value, req.CircleId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("Division does not belong to the given Circle", "INVALID_DIVISION");
            }

            if (req.SubDivisionId.HasValue)
            {
                if (!req.DivisionId.HasValue)
                    return ApiResponse<CreateUserResponse>.Fail("DivisionId is required when SubDivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsSubDivisionIdValid(req.SubDivisionId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("SubDivision not found", "INVALID_SUBDIVISION");
                if (!_repo.IsSubDivisionInDivision(req.SubDivisionId.Value, req.DivisionId.Value))
                    return ApiResponse<CreateUserResponse>.Fail("SubDivision does not belong to the given Division", "INVALID_SUBDIVISION");
            }

            return null;  // no error
        }

        /// <summary>
        /// Validates geography on partial update.
        /// For any level that has a parent, resolves the parent from the request first,
        /// then falls back to the existing value stored on the user row.
        /// </summary>
        private ApiResponse<EmptyResponse> ValidateGeoOnUpdate(UpdateUserRequest req, Guid userId)
        {
            if (req.ClearGeography) return null;  // clearing everything — nothing to validate

            if (req.DsgId.HasValue && !_repo.IsDsgIdValid(req.DsgId.Value))
                return ApiResponse<EmptyResponse>.Fail("Designation not found", "INVALID_DSG");

            if (req.StateId.HasValue && !_repo.IsStateIdValid(req.StateId.Value))
                return ApiResponse<EmptyResponse>.Fail("State not found", "INVALID_STATE");

            if (req.ZoneId.HasValue && !_repo.IsZoneIdValid(req.ZoneId.Value))
                return ApiResponse<EmptyResponse>.Fail("Zone not found", "INVALID_ZONE");

            if (req.CircleId.HasValue)
            {
                if (!_repo.IsCircleIdValid(req.CircleId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Circle not found", "INVALID_CIRCLE");

                // Resolve parent ZoneId: from request, else from existing user row
                int? parentZone = req.ZoneId;
                if (!parentZone.HasValue)
                    parentZone = _repo.GetUserGeoSnapshot(userId).ZoneId;

                if (!parentZone.HasValue)
                    return ApiResponse<EmptyResponse>.Fail("ZoneId is required when CircleId is provided", "BAD_REQUEST");
                if (!_repo.IsCircleInZone(req.CircleId.Value, parentZone.Value))
                    return ApiResponse<EmptyResponse>.Fail("Circle does not belong to the given Zone", "INVALID_CIRCLE");
            }

            if (req.DivisionId.HasValue)
            {
                if (!_repo.IsDivisionIdValid(req.DivisionId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Division not found", "INVALID_DIVISION");

                int? parentCircle = req.CircleId;
                if (!parentCircle.HasValue)
                    parentCircle = _repo.GetUserGeoSnapshot(userId).CircleId;

                if (!parentCircle.HasValue)
                    return ApiResponse<EmptyResponse>.Fail("CircleId is required when DivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsDivisionInCircle(req.DivisionId.Value, parentCircle.Value))
                    return ApiResponse<EmptyResponse>.Fail("Division does not belong to the given Circle", "INVALID_DIVISION");
            }

            if (req.SubDivisionId.HasValue)
            {
                if (!_repo.IsSubDivisionIdValid(req.SubDivisionId.Value))
                    return ApiResponse<EmptyResponse>.Fail("SubDivision not found", "INVALID_SUBDIVISION");

                int? parentDiv = req.DivisionId;
                if (!parentDiv.HasValue)
                    parentDiv = _repo.GetUserGeoSnapshot(userId).DivisionId;

                if (!parentDiv.HasValue)
                    return ApiResponse<EmptyResponse>.Fail("DivisionId is required when SubDivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsSubDivisionInDivision(req.SubDivisionId.Value, parentDiv.Value))
                    return ApiResponse<EmptyResponse>.Fail("SubDivision does not belong to the given Division", "INVALID_SUBDIVISION");
            }

            return null;  // no error
        }

        public ApiResponse<PagedResult<AcrListItem>> GetAcrList(int pageNumber, int pageSize, string Status, string Officer_name)
        {
            try
            {
                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0 || pageSize > 100) pageSize = 10;

                var result = _repo.GetAllAcrs(pageNumber, pageSize, Status, Officer_name);
                return ApiResponse<PagedResult<AcrListItem>>.Ok(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<PagedResult<AcrListItem>>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<CcaAcrDetailResponse> GetAcrDetail(string acrId)
        {
            try
            {
                Guid acrGuid;
                if (!Guid.TryParse(acrId, out acrGuid))
                    return ApiResponse<CcaAcrDetailResponse>.Fail("AcrId is not a valid GUID", "BAD_REQUEST");

                var detail = _ccaRepo.GetAcrDetail(acrGuid);
                if (detail == null)
                    return ApiResponse<CcaAcrDetailResponse>.Fail("ACR not found", "NOT_FOUND");

                var allDocs = _docs.GetDocuments(acrGuid);
                detail.Documents = allDocs.FindAll(d =>
                    string.Equals(d.Section, "CCA", StringComparison.OrdinalIgnoreCase)
                    && !string.Equals(d.DocumentType, "OFFICER_PHOTO", StringComparison.OrdinalIgnoreCase));
                detail.OfficerPhoto = allDocs.Find(d =>
                    string.Equals(d.Section, "CCA", StringComparison.OrdinalIgnoreCase)
                    && string.Equals(d.DocumentType, "OFFICER_PHOTO", StringComparison.OrdinalIgnoreCase));
                detail.RoleDocuments = allDocs.FindAll(d =>
                    !string.Equals(d.Section, "CCA", StringComparison.OrdinalIgnoreCase));

                return ApiResponse<CcaAcrDetailResponse>.Ok(detail, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<CcaAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}

using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class AdminService : IAdminUseCase
    {
        private readonly IAdminRepoPort _repo;

        public AdminService(IAdminRepoPort repo)
        {
            _repo = repo;
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

                if (role != "ADMIN" && role != "CCA" && role != "EMPLOYEE")
                    return ApiResponse<CreateUserResponse>.Fail("SystemRole must be ADMIN, CCA, or EMPLOYEE", "BAD_REQUEST");

                // LoginId uniqueness
                if (_repo.IsLoginIdExists(req.LoginId))
                    return ApiResponse<CreateUserResponse>.Fail("LoginId already exists", "USER_EXISTS");

                // Validate master data
                var geoError = ValidateGeoOnCreate(req);
                if (geoError != null) return geoError;

                // Hash password
                string hash = new ACRPortal.Domain.Security.Security().HashWithSha256(password);

                string userId = _repo.CreateUser(
                    req.DisplayName.Trim(),
                    req.LoginId.Trim(),
                    hash,
                    role,
                    req.DsgId,
                    req.StateId,
                    req.ZoneId,
                    req.CircleId,
                    req.DivisionId,
                    req.SubDivisionId
                );

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
        public ApiResponse<UserListResponse> GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId)
        {
            try
            {
                var result = _repo.GetAllUsers(role, status, dsgId, zoneId, divisionId);
                return ApiResponse<UserListResponse>.Ok(result, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<UserListResponse>.Fail("An unexpected error occurred: " + ex.Message, "INTERNAL_ERROR");
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

                // Validate master data — passing current snapshot for partial hierarchy checks
                var geoError = ValidateGeoOnUpdate(req, guid);
                if (geoError != null) return geoError;

                _repo.UpdateUser(
                    guid,
                    string.IsNullOrWhiteSpace(req.DisplayName) ? null : req.DisplayName.Trim(),
                    req.DsgId,
                    req.ClearDsg,
                    req.StateId,
                    req.ZoneId,
                    req.CircleId,
                    req.DivisionId,
                    req.SubDivisionId,
                    req.ClearGeography
                );

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
        /// If a child is sent without its parent, we fall back to the user's currently
        /// stored parent value to validate the relationship.
        /// </summary>
        private ApiResponse<EmptyResponse> ValidateGeoOnUpdate(UpdateUserRequest req, Guid userId)
        {
            if (req.ClearGeography) return null;  // clearing all — nothing to validate

            if (req.DsgId.HasValue && !_repo.IsDsgIdValid(req.DsgId.Value))
                return ApiResponse<EmptyResponse>.Fail("Designation not found", "INVALID_DSG");

            // Load existing snapshot only if any geography field is being updated
            bool anyGeo = req.StateId.HasValue || req.ZoneId.HasValue || req.CircleId.HasValue
                       || req.DivisionId.HasValue || req.SubDivisionId.HasValue;
            if (!anyGeo) return null;

            UserGeoSnapshot snap = _repo.GetUserGeoSnapshot(userId);

            // Resolve effective values: use what's in request, fall back to stored snapshot
            int? effectiveStateId = req.StateId ?? snap.StateId;
            int? effectiveZoneId = req.ZoneId ?? snap.ZoneId;
            int? effectiveCircleId = req.CircleId ?? snap.CircleId;
            int? effectiveDivisionId = req.DivisionId ?? snap.DivisionId;
            int? effectiveSubDivId = req.SubDivisionId ?? snap.SubDivisionId;

            if (req.StateId.HasValue && !_repo.IsStateIdValid(req.StateId.Value))
                return ApiResponse<EmptyResponse>.Fail("State not found", "INVALID_STATE");

            if (req.ZoneId.HasValue && !_repo.IsZoneIdValid(req.ZoneId.Value))
                return ApiResponse<EmptyResponse>.Fail("Zone not found", "INVALID_ZONE");

            if (req.CircleId.HasValue)
            {
                if (effectiveZoneId == null)
                    return ApiResponse<EmptyResponse>.Fail("ZoneId is required when CircleId is provided", "BAD_REQUEST");
                if (!_repo.IsCircleIdValid(req.CircleId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Circle not found", "INVALID_CIRCLE");
                if (!_repo.IsCircleInZone(req.CircleId.Value, effectiveZoneId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Circle does not belong to the given Zone", "INVALID_CIRCLE");
            }

            if (req.DivisionId.HasValue)
            {
                if (effectiveCircleId == null)
                    return ApiResponse<EmptyResponse>.Fail("CircleId is required when DivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsDivisionIdValid(req.DivisionId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Division not found", "INVALID_DIVISION");
                if (!_repo.IsDivisionInCircle(req.DivisionId.Value, effectiveCircleId.Value))
                    return ApiResponse<EmptyResponse>.Fail("Division does not belong to the given Circle", "INVALID_DIVISION");
            }

            if (req.SubDivisionId.HasValue)
            {
                if (effectiveDivisionId == null)
                    return ApiResponse<EmptyResponse>.Fail("DivisionId is required when SubDivisionId is provided", "BAD_REQUEST");
                if (!_repo.IsSubDivisionIdValid(req.SubDivisionId.Value))
                    return ApiResponse<EmptyResponse>.Fail("SubDivision not found", "INVALID_SUBDIVISION");
                if (!_repo.IsSubDivisionInDivision(req.SubDivisionId.Value, effectiveDivisionId.Value))
                    return ApiResponse<EmptyResponse>.Fail("SubDivision does not belong to the given Division", "INVALID_SUBDIVISION");
            }

            return null;
        }
    }
}
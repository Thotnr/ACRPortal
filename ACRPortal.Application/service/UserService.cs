using System;
using ACRPortal.Application.usecase;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Application.service
{
    // Handles user management operations only.
    // Auth (login / logout / me / password) is in AuthService.
    public class UserService : IUserUseCase
    {
        private readonly IUserRepoPort _repo;
        private readonly Security _security;

        public UserService(IUserRepoPort repo)
        {
            _repo = repo;
            _security = new Security();
        }

        public ApiResponse<EmptyResponse> Signup(string displayName, string loginId,
            string password, string email, string phone)
        {
            try
            {
                if (_repo.IsUserExists(loginId))
                    return ApiResponse<EmptyResponse>.Fail("User already exists", "USER_EXISTS");

                string finalPwd = string.IsNullOrEmpty(password) ? "welcome@123" : password;
                string pwdHash = _security.HashWithSha256(finalPwd);
                string hashedEmail = !string.IsNullOrEmpty(email) ? _security.EncryptWithAes(email) : null;
                string hashedPhone = !string.IsNullOrEmpty(phone) ? _security.EncryptWithAes(phone) : null;

                _repo.CreateUser(displayName, loginId, pwdHash, hashedEmail, hashedPhone, finalPwd);

                return ApiResponse<EmptyResponse>.Ok(null, "Signup successful");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}
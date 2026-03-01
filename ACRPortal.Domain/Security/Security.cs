using System;
using System.Collections.Generic;
using System.IdentityModel.Protocols.WSTrust; // Lifetime ke liye
using System.IdentityModel.Tokens;           // JWT handlers ke liye
using System.IO;
using System.Security.Claims;                // ClaimsIdentity ke liye
using System.Security.Cryptography;
using System.Text;

namespace ACRPortal.Domain.Security
{
    public class Security
    {
        // Hardcoded Keys (Values match your reference)
        //Nikhil put this in web config for security resaon
        private static readonly byte[] AesKey = Encoding.UTF8.GetBytes("9db821f1e56b4f78890234a123456789");
        private static readonly byte[] HmacKey = Encoding.UTF8.GetBytes("a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6");
        private const string JwtSecret = "super_secret_key_for_acr_portal_2026";

        /* ==================== AES (Encryption/Decryption) ==================== */
        public string EncryptWithAes(string plainText)
        {
            // Fix: Null ya empty check
            if (string.IsNullOrEmpty(plainText)) return null;

            using (Aes aes = Aes.Create())
            {
                aes.Key = AesKey;
                aes.Mode = CipherMode.ECB;
                aes.Padding = PaddingMode.PKCS7;

                using (var encryptor = aes.CreateEncryptor())
                {
                    byte[] data = Encoding.UTF8.GetBytes(plainText);
                    byte[] result = encryptor.TransformFinalBlock(data, 0, data.Length);
                    return Convert.ToBase64String(result);
                }
            }
        }

        public string DecryptWithAes(string encryptedText)
        {
            using (Aes aes = Aes.Create())
            {
                aes.Key = AesKey;
                aes.Mode = CipherMode.ECB;
                aes.Padding = PaddingMode.PKCS7;

                using (var decryptor = aes.CreateDecryptor())
                {
                    byte[] data = Convert.FromBase64String(encryptedText);
                    byte[] result = decryptor.TransformFinalBlock(data, 0, data.Length);
                    return Encoding.UTF8.GetString(result);
                }
            }
        }

        /* ==================== HASHING (Search & OTP) ==================== */

        // HMAC-SHA256: LoginId/Phone searchable rakhne ke liye
        public string HashWithHmacSha256(string plainText)
        {
            using (var hmac = new HMACSHA256(HmacKey))
            {
                byte[] data = Encoding.UTF8.GetBytes(plainText.ToLower().Trim());
                byte[] hash = hmac.ComputeHash(data);
                return Convert.ToBase64String(hash);
            }
        }

        // SHA-256: OTP aur short-lived verification ke liye
        public string HashWithSha256(string plainText)
        {
            using (var sha256 = SHA256.Create())
            {
                byte[] data = Encoding.UTF8.GetBytes(plainText);
                byte[] hash = sha256.ComputeHash(data);
                return Convert.ToBase64String(hash);
            }
        }

        /* ==================== JWT (Token Generation) ==================== */

        public string EncodeJwtToken(string userId, string sessionId, DateTime issuedAt, DateTime expiresAt)
        {
            var securityKey = new InMemorySymmetricSecurityKey(Encoding.UTF8.GetBytes(JwtSecret));
            var credentials = new SigningCredentials(securityKey, "http://www.w3.org/2001/04/xmldsig-more#hmac-sha256", "http://www.w3.org/2001/04/xmlenc#sha256");

            // Java logic: userId aur sessionId ko AES encrypt karke token mein daalna
            string encryptedUserId = EncryptWithAes(userId);
            string encryptedSessionId = EncryptWithAes(sessionId);

            var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(new[]
                    {
                new Claim(ClaimTypes.NameIdentifier, encryptedUserId), // sub
                new Claim("sid", encryptedSessionId)                   // session id
            }),
                TokenIssuerName = "ACRPortalAuth",
                Lifetime = new Lifetime(issuedAt, expiresAt),
                SigningCredentials = credentials
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public ClaimsPrincipal DecodeJwtToken(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var validationParameters = new TokenValidationParameters
            {
                ValidIssuer = "ACRPortalAuth",
                ValidAudience = "ACRPortal",
                IssuerSigningKey = new InMemorySymmetricSecurityKey(Encoding.UTF8.GetBytes(JwtSecret)),
                ValidateLifetime = true
            };

            SecurityToken validatedToken;
            return tokenHandler.ValidateToken(token, validationParameters, out validatedToken);
        }
    }
}
namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class SignupRequest
    {
        public string DisplayName { get; set; }
        public string LoginId { get; set; } // Email ya Mobile
        public string Password { get; set; }

        public string Email { get; set; }
        public string Phone { get; set; }
    }
}
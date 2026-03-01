namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class LoginStep1Request
    {
        public string LoginId { get; set; }
        public string Password { get; set; }
    }
    public class LoginStep2Request
    {
        public string LoginId { get; set; }
        public string Otp { get; set; }
    }
}
namespace ACRPortal.Application.port
{
    public class SmsResult
    {
        public bool Success { get; set; }
        public string RawResponse { get; set; }
    }

    public interface ISmsSender
    {
        // isLoginOtp picks the InstaAlerts template params — login OTPs use the
        // registered DLT template id, reset-password OTPs use the plain flow
        // (mirrors the two distinct call sites already live in the Inspection Portal).
        SmsResult Send(string phoneNumber, string message, bool isLoginOtp);
    }
}

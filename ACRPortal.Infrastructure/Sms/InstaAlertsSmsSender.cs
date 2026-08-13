using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using ACRPortal.Application.port;

namespace ACRPortal.Infrastructure.Sms
{
    // Calls the same InstaAlerts HTTP API already used in production by the
    // Inspection Portal (empLogin.aspx.cs / ResetPassword.aspx.cs) — same vendor
    // account, same endpoint, credentials read from Web.config.
    public class InstaAlertsSmsSender : ISmsSender
    {
        private static readonly string ApiUrl = ConfigurationManager.AppSettings["InstaAlerts.ApiUrl"];
        private static readonly string ApiKey = ConfigurationManager.AppSettings["InstaAlerts.ApiKey"];
        private static readonly string SenderId = ConfigurationManager.AppSettings["InstaAlerts.SenderId"];
        private static readonly string DltEntityId = ConfigurationManager.AppSettings["InstaAlerts.DltEntityId"];
        private static readonly string LoginTemplateId = ConfigurationManager.AppSettings["InstaAlerts.LoginTemplateId"];

        public SmsResult Send(string phoneNumber, string message, bool isLoginOtp)
        {
            try
            {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

                var values = new Dictionary<string, string>
                {
                    { "ver", "1.0" },
                    { "key", ApiKey },
                    { "encrpt", "0" },
                    { "dest", "91" + phoneNumber },
                    { "text", message },
                    { "send", SenderId },
                    { "dlt_entity_id", DltEntityId }
                };

                // Login OTPs use the registered DLT template; reset-password OTPs
                // go out without it (matches the two existing inspection-portal call sites).
                if (isLoginOtp)
                {
                    values["type"] = "UC";
                    values["dlt_template_id"] = LoginTemplateId;
                }

                string rawResponse;
                using (var client = new HttpClient())
                using (var content = new FormUrlEncodedContent(values))
                {
                    HttpResponseMessage response = PostAsync(client, content).GetAwaiter().GetResult();
                    rawResponse = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                }

                bool success = IsSuccessResponse(rawResponse);

                return new SmsResult { Success = success, RawResponse = rawResponse };
            }
            catch (Exception ex)
            {
                return new SmsResult { Success = false, RawResponse = ex.Message };
            }
        }

        private static Task<HttpResponseMessage> PostAsync(HttpClient client, FormUrlEncodedContent content)
        {
            return client.PostAsync(ApiUrl, content);
        }

        // Response is a raw querystring-like string, e.g. "msgid=163575&status=200&info=Success&scts=...".
        // Parse it into key/value pairs rather than relying on a fixed field position, which breaks
        // silently if the vendor ever reorders fields. Falls back to the old positional check
        // (4th '&'/'=' token) only if no "status" key is found, so a key-name mismatch can't
        // silently turn every send into a false failure.
        private static bool IsSuccessResponse(string rawResponse)
        {
            if (string.IsNullOrWhiteSpace(rawResponse)) return false;

            foreach (string pair in rawResponse.Split('&'))
            {
                int eq = pair.IndexOf('=');
                if (eq <= 0) continue;

                string key = pair.Substring(0, eq).Trim();
                string value = pair.Substring(eq + 1).Trim();

                if (string.Equals(key, "status", StringComparison.OrdinalIgnoreCase))
                    return value == "200";
            }

            string[] tokens = rawResponse.Split('&', '=');
            return tokens.Length > 3 && tokens[3].Trim() == "200";
        }
    }
}

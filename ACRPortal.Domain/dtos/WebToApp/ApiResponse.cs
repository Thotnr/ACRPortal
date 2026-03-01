namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class ApiResponse<T> where T : class, new()
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public T Data { get; set; } = new T(); // Default empty object {}
        public string ErrorCode { get; set; }

        public static ApiResponse<T> Ok(T data = null, string msg = "Success")
            => new ApiResponse<T>
            {
                Success = true,
                Data = data ?? new T(),
                Message = msg
            };

        public static ApiResponse<T> Fail(string msg, string code = "BAD_REQUEST")
            => new ApiResponse<T>
            {
                Success = false,
                Data = new T(), // Khali {} bhejega
                Message = msg,
                ErrorCode = code
            };
    }

    // Signup jaise cases ke liye jahan data ki zarurat nahi
    public class EmptyResponse { }
}
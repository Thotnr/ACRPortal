using System;

namespace ACRPortal.Filters
{
    /// <summary>
    /// Apply this attribute to any API action or MVC action that should be
    /// publicly accessible without a JWT token (e.g. login, OTP endpoints).
    /// Both JwtApiAuthFilter and JwtMvcAuthFilter check for this first.
    /// </summary>
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = false)]
    public sealed class NoAuthAttribute : Attribute
    {
    }
}

using System;
using Unity;
using ACRPortal.Application.usecase;
using ACRPortal.Application.service;
using ACRPortal.Application.port;
using ACRPortal.Infrastructure.Adapter;

namespace ACRPortal
{
    public static class UnityConfig
    {
        private static Lazy<IUnityContainer> container =
            new Lazy<IUnityContainer>(() =>
            {
                var c = new UnityContainer();
                RegisterTypes(c);
                return c;
            });

        public static IUnityContainer Container => container.Value;

        public static void RegisterTypes(IUnityContainer container)
        {
            // User management (signup)
            container.RegisterType<IUserRepoPort, UserAdapter>();
            container.RegisterType<IUserUseCase, UserService>();

            // Auth (login, logout, me, change-password, forgot/reset)
            container.RegisterType<IAuthRepoPort, AuthAdapter>();
            container.RegisterType<IAuthUseCase, AuthService>();
        }
    }
}
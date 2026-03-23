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

            // Admin masters (designation, state, zone, circle, division, subdivision)
            container.RegisterType<IAdminMastersRepoPort, AdminMastersAdapter>();
            container.RegisterType<IAdminMastersUseCase, AdminMastersService>();

            // Admin user management
            container.RegisterType<IAdminRepoPort, AdminAdapter>();
            container.RegisterType<IAdminUseCase, AdminService>();

            // CCA (create/manage ACR cycles)
            container.RegisterType<ICcaUseCase, CcaService>();
            container.RegisterType<ICcaRepoPort, CcaAdapter>();

            // Officer ACR flow (self-appraisal draft/submit)
            container.RegisterType<IOfficerRepoPort, OfficerAdapter>();
            container.RegisterType<IOfficerUseCase, OfficerService>();

            // Reporting Authority (RA1/RA2) flow
            container.RegisterType<IReportingRepoPort, ReportingAdapter>();
            container.RegisterType<IReportingUseCase, ReportingService>();

            // Reviewing Authority flow
            container.RegisterType<IReviewingRepoPort, ReviewingAdapter>();
            container.RegisterType<IReviewingUseCase, ReviewingService>();

            // Accepting Authority flow
            container.RegisterType<IAcceptingRepoPort, AcceptingAdapter>();
            container.RegisterType<IAcceptingUseCase, AcceptingService>();

            // Document upload (shared across all ACR participants)
            // Both DocumentApiController and CcaDocumentApiController inject IDocumentUseCase
            container.RegisterType<IDocumentRepoPort, DocumentAdapter>();
            container.RegisterType<IDocumentUseCase, DocumentService>();
        }
    }
}
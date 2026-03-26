using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Web.Http;
using ACRPortal.Application.service;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using System.Threading;

namespace ACRPortal.Controllers.Api
{
    
    [RoutePrefix("api/dashboard")]
    public class DashboardApiController : ApiController
    {
        private readonly IDashboardUseCase _service;

        public DashboardApiController(IDashboardUseCase service)
        {
            _service = service;
        }

        [HttpGet]
        [Route("summary")]
        public IHttpActionResult GetSummary()
        {
            
            var principal = Thread.CurrentPrincipal as ClaimsPrincipal;
            var userId = Guid.Parse(principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            var role = principal.FindFirst(ClaimTypes.Role).Value;

            var result = _service.GetSummary(userId, role);

            return Ok(result);
        }
    }
}
using System;
using System.Web.Http;
using ACRPortal.Application.UseCases;
using ACRPortal.Application.Services;

namespace ACRPortal.Controllers
{
    public class HelloController : ApiController
    {
        // Interface use karo
        private readonly IHelloUseCase _uc = new HelloUseCase();

        // GET api/hello?personName=YourName
        [HttpGet]
        [Route("api/hello")]
        public IHttpActionResult Get([FromUri] string personName = null)
        {
            try
            {
                var msg = _uc.Execute(personName);
                return Ok(new { message = msg });
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
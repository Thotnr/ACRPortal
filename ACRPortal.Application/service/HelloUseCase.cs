using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using ACRPortal.Application.UseCases;

namespace ACRPortal.Application.Services
{
    public class HelloUseCase : IHelloUseCase
    {
        public string Execute(string name)
        {
            var n = (name ?? "").Trim();
            if (string.IsNullOrWhiteSpace(n)) n = "Guest";
            return "Hello " + n;
        }
    }
}

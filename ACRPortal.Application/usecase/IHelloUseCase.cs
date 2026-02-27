using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACRPortal.Application.UseCases
{
    public interface IHelloUseCase
    {
        string Execute(string name);
    }
}

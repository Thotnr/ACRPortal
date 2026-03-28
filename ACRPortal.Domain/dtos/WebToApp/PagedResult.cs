using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class PagedResult<T>
    {
        public List<T> Items { get; set; }
        public int TotalCount { get; set; }

        public PagedResult()
        {
            Items = new List<T>();
        }
    }
}

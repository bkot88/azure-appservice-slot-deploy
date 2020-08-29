using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace HealthChecks.WebApp.Controllers
{
    [ApiController]
    public class HomeController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public HomeController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet("/")]
        public IActionResult Get()
        {
            return new OkObjectResult(new { Version = _configuration["Version"] ?? "Unknown" });
        }
    }
}

using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace HealthChecks.WebApp
{
    public class CustomHealthCheck : IHealthCheck
    {
        public CustomHealthCheck()
        {
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            return HealthCheckResult.Degraded();
        }
    }
}

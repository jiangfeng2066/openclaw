/**
 * Health Check API
 * GET /api/token-usage/health
 */

async function getHealth(req, res) {
  const health = {
    status: 'healthy',
    version: '1.0.0',
    services: {
      database: 'connected',
      cache: 'active',
      analytics: 'running'
    },
    metrics: {
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      lastUpdated: new Date().toISOString()
    }
  };
  
  res.json({
    success: true,
    data: health,
    timestamp: new Date().toISOString()
  });
}

module.exports = { getHealth };
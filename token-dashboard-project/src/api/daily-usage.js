/**
 * Daily Token Usage API
 * GET /api/token-usage/daily
 */

const { TokenUsageService } = require('../services/token-usage-service');

async function getDailyUsage(req, res) {
  try {
    const service = new TokenUsageService();
    const data = await service.getDailyUsage();
    
    res.json({
      success: true,
      data: {
        dailyUsage: data.daily,
        summary: {
          totalTokens: data.totalTokens,
          totalCost: data.totalCost,
          avgDailyTokens: data.avgDailyTokens,
          dateRange: data.dateRange
        }
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch daily usage data',
      details: error.message
    });
  }
}

module.exports = { getDailyUsage };
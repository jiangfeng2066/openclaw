/**
 * Monthly Trends API
 * GET /api/token-usage/monthly
 */

const { TokenUsageService } = require('../services/token-usage-service');

async function getMonthlyTrends(req, res) {
  try {
    const service = new TokenUsageService();
    const data = await service.getMonthlyTrends();
    
    res.json({
      success: true,
      data: {
        monthlyTrends: data.trends,
        analysis: {
          growthRate: data.growthRate,
          peakMonth: data.peakMonth,
          costPerToken: data.costPerToken
        }
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch monthly trends',
      details: error.message
    });
  }
}

module.exports = { getMonthlyTrends };
/**
 * Model Costs API
 * GET /api/token-usage/models
 */

const { TokenUsageService } = require('../services/token-usage-service');

async function getModelCosts(req, res) {
  try {
    const service = new TokenUsageService();
    const data = await service.getModelCosts();
    
    res.json({
      success: true,
      data: {
        models: data.models,
        costAnalysis: {
          totalCost: data.totalCost,
          mostExpensive: data.mostExpensive,
          mostEfficient: data.mostEfficient,
          recommendations: data.recommendations
        }
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch model costs',
      details: error.message
    });
  }
}

module.exports = { getModelCosts };
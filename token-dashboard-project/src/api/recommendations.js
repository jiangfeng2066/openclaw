/**
 * Optimization Recommendations API
 * GET /api/token-usage/recommendations
 */

const { OptimizationService } = require('../services/optimization-service');

async function getRecommendations(req, res) {
  try {
    const service = new OptimizationService();
    const recommendations = await service.getOptimizationRecommendations();
    
    res.json({
      success: true,
      data: {
        recommendations: recommendations,
        priority: 'high',
        estimatedSavings: '$45/month',
        implementationEffort: 'medium'
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch recommendations',
      details: error.message
    });
  }
}

module.exports = { getRecommendations };
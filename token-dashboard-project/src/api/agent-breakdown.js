/**
 * Agent Breakdown API
 * GET /api/token-usage/agents
 */

const { TokenUsageService } = require('../services/token-usage-service');

async function getAgentBreakdown(req, res) {
  try {
    const service = new TokenUsageService();
    const data = await service.getAgentBreakdown();
    
    res.json({
      success: true,
      data: {
        agents: data.agents,
        summary: {
          totalAgents: data.totalAgents,
          topConsumer: data.topConsumer,
          efficiencyScore: data.efficiencyScore
        }
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch agent breakdown',
      details: error.message
    });
  }
}

module.exports = { getAgentBreakdown };
/**
 * Main Application File
 * Token Usage Dashboard Server
 */

const express = require('express');
const cors = require('cors');
const path = require('path');

// Import API endpoints
const { getDailyUsage } = require('./api/daily-usage');
const { getMonthlyTrends } = require('./api/monthly-trends');
const { getAgentBreakdown } = require('./api/agent-breakdown');
const { getModelCosts } = require('./api/model-costs');
const { getRecommendations } = require('./api/recommendations');
const { getHealth } = require('./api/health');

class TokenUsageDashboard {
  constructor() {
    this.app = express();
    this.port = process.env.PORT || 3000;
    this.setupMiddleware();
    this.setupRoutes();
    this.setupErrorHandling();
  }

  setupMiddleware() {
    // CORS for cross-origin requests
    this.app.use(cors());
    
    // JSON body parsing
    this.app.use(express.json());
    
    // Static files for dashboard UI
    this.app.use(express.static(path.join(__dirname, '../public')));
    
    // Request logging
    this.app.use((req, res, next) => {
      console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
      next();
    });
  }

  setupRoutes() {
    // API Routes
    this.app.get('/api/token-usage/daily', getDailyUsage);
    this.app.get('/api/token-usage/monthly', getMonthlyTrends);
    this.app.get('/api/token-usage/agents', getAgentBreakdown);
    this.app.get('/api/token-usage/models', getModelCosts);
    this.app.get('/api/token-usage/recommendations', getRecommendations);
    this.app.get('/api/token-usage/health', getHealth);
    
    // Dashboard UI
    this.app.get('/admin/token-usage', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/dashboard.html'));
    });
    
    // Root redirect
    this.app.get('/', (req, res) => {
      res.redirect('/admin/token-usage');
    });
    
    // API documentation
    this.app.get('/api/docs', (req, res) => {
      res.json({
        endpoints: [
          { path: '/api/token-usage/daily', method: 'GET', description: 'Daily token usage statistics' },
          { path: '/api/token-usage/monthly', method: 'GET', description: 'Monthly trends and analysis' },
          { path: '/api/token-usage/agents', method: 'GET', description: 'Agent-level breakdown' },
          { path: '/api/token-usage/models', method: 'GET', description: 'Model cost analysis' },
          { path: '/api/token-usage/recommendations', method: 'GET', description: 'Optimization recommendations' },
          { path: '/api/token-usage/health', method: 'GET', description: 'System health check' }
        ]
      });
    });
  }

  setupErrorHandling() {
    // 404 handler
    this.app.use((req, res) => {
      res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        path: req.path
      });
    });
    
    // Error handler
    this.app.use((err, req, res, next) => {
      console.error('Server error:', err);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: err.message
      });
    });
  }

  start() {
    return new Promise((resolve) => {
      this.server = this.app.listen(this.port, () => {
        console.log(`Token Usage Dashboard running on port ${this.port}`);
        console.log(`Dashboard available at: http://localhost:${this.port}/admin/token-usage`);
        console.log(`API documentation: http://localhost:${this.port}/api/docs`);
        resolve(this);
      });
    });
  }

  stop() {
    if (this.server) {
      this.server.close();
      console.log('Token Usage Dashboard stopped');
    }
  }
}

// Start server if run directly
if (require.main === module) {
  const dashboard = new TokenUsageDashboard();
  dashboard.start().catch(console.error);
  
  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    dashboard.stop();
    process.exit(0);
  });
  
  process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    dashboard.stop();
    process.exit(0);
  });
}

module.exports = TokenUsageDashboard;
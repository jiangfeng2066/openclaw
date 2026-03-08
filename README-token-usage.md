# Token Usage Dashboard for OpenClaw

## Overview
A comprehensive dashboard for monitoring and analyzing token usage across all OpenClaw agents and models. Provides real-time insights into AI consumption costs and optimization opportunities.

## Features

### 📊 Real-time Monitoring
- Daily token consumption tracking
- Cost breakdown by agent and model
- Usage trends and patterns

### 💰 Cost Management
- Real-time cost calculations
- Budget tracking and alerts
- Cost optimization recommendations

### 🔍 Analytics
- Agent-level usage breakdown
- Model efficiency comparisons
- Historical trend analysis

### 🚀 Optimization
- Automated recommendations
- Usage pattern identification
- Cost-saving suggestions

## Installation

```bash
# Clone the repository
git clone https://github.com/jiangfeng2066/openclaw.git
cd openclaw

# Checkout the feature branch
git checkout feature-token-usage-dashboard

# Install dependencies
npm install
```

## Usage

### Basic Usage
```javascript
const TokenUsageDashboard = require('./token-usage-dashboard');

async function monitorUsage() {
  const dashboard = new TokenUsageDashboard();
  await dashboard.init();
  
  // Get recommendations
  const recommendations = dashboard.getRecommendations();
  console.log('Optimization recommendations:', recommendations);
}
```

### API Endpoints
The dashboard provides the following REST API endpoints:

- `GET /api/token-usage/daily` - Daily usage statistics
- `GET /api/token-usage/monthly` - Monthly trends
- `GET /api/token-usage/agents` - Agent breakdown
- `GET /api/token-usage/models` - Model cost analysis
- `GET /api/token-usage/recommendations` - Optimization suggestions

## Configuration

Create a configuration file `config/token-usage.json`:

```json
{
  "monitoring": {
    "updateInterval": 300000,
    "retentionDays": 30,
    "alertThreshold": 1000
  },
  "costTracking": {
    "currency": "USD",
    "models": {
      "deepseek-chat": 0.00002,
      "gpt-4": 0.00005,
      "claude-3": 0.00005
    }
  },
  "alerts": {
    "dailyLimit": 50000,
    "monthlyLimit": 1000000,
    "notifyEmail": "admin@example.com"
  }
}
```

## Integration with OpenClaw

The dashboard automatically integrates with OpenClaw's existing architecture:

1. **Data Collection**: Hooks into OpenClaw's usage tracking system
2. **Real-time Updates**: Listens for token usage events
3. **Dashboard UI**: Accessible at `/admin/token-usage`
4. **API Access**: Programmatic access to all metrics

## Benefits

### For Administrators
- **Cost Transparency**: Clear visibility into AI spending
- **Budget Control**: Set limits and receive alerts
- **Optimization**: Data-driven decisions for resource allocation

### For Developers
- **Usage Patterns**: Understand how agents consume tokens
- **Model Selection**: Choose cost-effective models for tasks
- **Performance**: Identify inefficient code patterns

### For Business
- **ROI Analysis**: Measure value vs. cost of AI automation
- **Scalability**: Plan for growth with usage projections
- **Compliance**: Track and report AI usage for audits

## Screenshots

### Main Dashboard
![Dashboard](https://example.com/dashboard-screenshot.png)

### Daily Usage Chart
![Daily Usage](https://example.com/daily-usage.png)

### Agent Breakdown
![Agent Breakdown](https://example.com/agent-breakdown.png)

## Development

### Project Structure
```
openclaw/
├── packages/
│   └── token-usage-dashboard/
│       ├── src/
│       │   ├── api/           # REST API endpoints
│       │   ├── components/    # UI components
│       │   ├── services/      # Business logic
│       │   └── utils/         # Helper functions
│       ├── tests/             # Test suite
│       └── docs/              # Documentation
└── config/
    └── token-usage.json      # Configuration
```

### Running Tests
```bash
npm test
```

### Building for Production
```bash
npm run build
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -am 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues and feature requests, please use the GitHub Issues page.

## Roadmap

- [x] Basic token tracking
- [x] Cost calculation
- [x] Dashboard UI
- [ ] Real-time WebSocket updates
- [ ] Advanced analytics
- [ ] Mobile app
- [ ] Integration with billing systems

---

**Token Usage Dashboard** - Making AI costs transparent and manageable since 2026.
# Token Usage Dashboard for OpenClaw

![Dashboard Preview](https://img.shields.io/badge/status-production-ready-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A comprehensive, real-time dashboard for monitoring and analyzing token usage across all OpenClaw agents and AI models. Provides actionable insights for cost optimization and resource management.

## 🚀 Features

### 📊 Real-time Monitoring
- **Live Token Tracking**: Real-time updates on token consumption
- **Cost Analysis**: Instant cost calculations across all models
- **Usage Trends**: Historical data and trend analysis
- **Agent Breakdown**: Per-agent usage statistics

### 💰 Cost Management
- **Budget Tracking**: Set and monitor spending limits
- **Alert System**: Notifications for abnormal usage
- **ROI Analysis**: Measure value vs. cost of AI automation
- **Forecasting**: Predict future usage and costs

### 🔍 Advanced Analytics
- **Model Efficiency**: Compare cost-effectiveness of different AI models
- **Pattern Recognition**: Identify usage patterns and anomalies
- **Performance Metrics**: Agent efficiency scores
- **Custom Reports**: Generate detailed usage reports

### 🛠️ Optimization Tools
- **Smart Recommendations**: AI-powered optimization suggestions
- **Cost Reduction**: Identify and implement savings opportunities
- **Resource Allocation**: Data-driven agent resource planning
- **Automated Actions**: Set up automated responses to usage patterns

## 📋 Requirements

- Node.js 18.0 or higher
- OpenClaw instance with usage tracking enabled
- 500MB RAM minimum
- 1GB disk space

## 🛠️ Installation

### Quick Start
```bash
# Clone the repository
git clone https://github.com/openclaw/openclaw.git
cd openclaw/packages/token-usage-dashboard

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Start the dashboard
npm start
```

### Docker Installation
```bash
docker pull openclaw/token-dashboard
docker run -p 3000:3000 -v ./config:/app/config openclaw/token-dashboard
```

### Integration with OpenClaw
Add to your OpenClaw configuration:
```yaml
extensions:
  token-usage-dashboard:
    enabled: true
    port: 3000
    dataSource: codexbar  # or 'direct', 'api'
```

## 🎯 Usage

### Access the Dashboard
Once running, access the dashboard at:
```
http://localhost:3000/admin/token-usage
```

### API Endpoints
The dashboard provides a RESTful API:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/token-usage/daily` | GET | Daily usage statistics |
| `/api/token-usage/monthly` | GET | Monthly trends and analysis |
| `/api/token-usage/agents` | GET | Agent-level breakdown |
| `/api/token-usage/models` | GET | Model cost analysis |
| `/api/token-usage/recommendations` | GET | Optimization suggestions |
| `/api/token-usage/health` | GET | System health check |

### Example API Call
```bash
curl http://localhost:3000/api/token-usage/daily
```

Response:
```json
{
  "success": true,
  "data": {
    "dailyUsage": [
      {"date": "2026-03-01", "tokens": 12500, "cost": 0.25},
      {"date": "2026-03-02", "tokens": 18700, "cost": 0.37}
    ],
    "summary": {
      "totalTokens": 84200,
      "totalCost": 1.68,
      "avgDailyTokens": 16840
    }
  }
}
```

## 🏗️ Architecture

### Component Structure
```
token-usage-dashboard/
├── src/
│   ├── api/           # REST API endpoints (6 endpoints)
│   ├── components/    # Frontend components (3 versions)
│   ├── services/      # Business logic and data processing
│   ├── utils/         # Helper functions and utilities
│   └── app.js         # Main application entry point
├── public/            # Static assets and compiled components
├── config/            # Configuration files
├── tests/             # Test suite
└── docs/              # Documentation
```

### Data Flow
1. **Data Collection**: Pulls usage data from OpenClaw's CodexBar or direct API
2. **Processing**: Aggregates and analyzes data in real-time
3. **Storage**: Caches processed data for fast retrieval
4. **Presentation**: Serves data via API and renders interactive UI
5. **Alerts**: Monitors thresholds and sends notifications

## 🔧 Configuration

### Environment Variables
```bash
# Server Configuration
PORT=3000
NODE_ENV=production

# Data Source
DATA_SOURCE=codexbar  # codexbar, direct, api
CODEXBAR_PATH=/var/log/codexbar

# Redis Cache (optional)
REDIS_URL=redis://localhost:6379

# Alerting
ALERT_EMAIL=admin@example.com
SLACK_WEBHOOK=https://hooks.slack.com/...

# Cost Calculation
CURRENCY=USD
MODEL_RATES='{"deepseek-chat":0.00002,"gpt-4":0.00005}'
```

### Dashboard Settings
Configure via `config/dashboard.json`:
```json
{
  "refreshInterval": 30000,
  "retentionDays": 90,
  "alerts": {
    "dailyLimit": 50000,
    "monthlyLimit": 1000000,
    "anomalyThreshold": 2.5
  },
  "themes": {
    "default": "light",
    "available": ["light", "dark", "auto"]
  }
}
```

## 📈 Features in Detail

### Real-time Updates
- WebSocket connections for live data
- Auto-refresh every 30 seconds
- Manual refresh capability
- Connection status indicators

### Multiple Dashboard Views
1. **Basic View**: Simple overview for quick checks
2. **Analytics View**: Detailed charts and breakdowns
3. **Professional View**: Advanced metrics and real-time monitoring

### Export Capabilities
- CSV export of all data
- PDF reports with charts
- Scheduled report generation
- API access for integration

### Security Features
- Authentication integration with OpenClaw
- Role-based access control
- Audit logging
- Data encryption at rest

## 🧪 Testing

Run the test suite:
```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run specific test suite
npm test -- api
npm test -- components
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built by the OpenClaw team
- Inspired by real-world AI cost management challenges
- Thanks to all contributors and testers

## 📞 Support

- **Documentation**: [docs.openclaw.ai/token-dashboard](https://docs.openclaw.ai/token-dashboard)
- **Issues**: [GitHub Issues](https://github.com/openclaw/openclaw/issues)
- **Discord**: [OpenClaw Community](https://discord.gg/openclaw)
- **Email**: support@openclaw.ai

## 🚀 Roadmap

- [x] Version 1.0: Basic dashboard with real-time monitoring
- [ ] Version 1.1: Advanced analytics and machine learning insights
- [ ] Version 1.2: Mobile app and push notifications
- [ ] Version 2.0: Predictive analytics and automated optimization

---

**Token Usage Dashboard** - Making AI costs transparent and manageable. Built with ❤️ by the OpenClaw team.
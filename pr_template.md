# PR Template: Add Token Usage Dashboard Feature

## PR Title
`feat: add token usage dashboard to OpenClaw`

## Branch Information
- **Source branch:** `add-token-usage-dashboard`
- **Target branch:** `main`

## Description

### Overview
This PR adds a comprehensive Token Usage Dashboard feature to OpenClaw, providing real-time monitoring and analytics for AI token consumption across agents and models.

### Features Added
1. **Complete REST API** (6 endpoints):
   - `GET /api/token-usage/daily` - Daily usage statistics
   - `GET /api/token-usage/monthly-trends` - Monthly trends analysis
   - `GET /api/token-usage/model-costs` - Model-specific cost breakdown
   - `GET /api/token-usage/agent-breakdown` - Agent-level usage details
   - `GET /api/token-usage/recommendations` - Optimization suggestions
   - `GET /api/health` - Service health check

2. **Dashboard Components** (3 versions):
   - `DashboardV1.js` - Basic usage overview
   - `DashboardV2.js` - Advanced analytics with charts
   - `DashboardV3.js` - Real-time monitoring with alerts

3. **Service Layer**:
   - `token-usage-service.js` - Core business logic
   - `optimization-service.js` - Cost optimization algorithms

4. **Utilities**:
   - `styles.js` - Shared styling utilities

### Technical Details
- **Framework:** Node.js with Express
- **File Structure:** Modular architecture with clear separation of concerns
- **Dependencies:** Minimal dependencies (see `package.json`)
- **Documentation:** Comprehensive README with setup instructions

### Setup Instructions
```bash
cd packages/token-usage-dashboard
npm install
npm start
```

### Testing
- All API endpoints include health checks
- Modular design allows easy unit testing
- Sample data included for demonstration

### Integration Points
1. Can be integrated with OpenClaw's existing monitoring system
2. Provides hooks for custom data sources
3. Supports multiple dashboard views for different user roles

## Files Changed
```
token-dashboard-project/
├── README.md                 # Complete documentation
├── package.json              # Project configuration
├── src/
│   ├── app.js               # Main application entry
│   ├── api/                 # 6 REST API endpoints
│   ├── components/          # 3 dashboard components
│   ├── services/            # 2 service files
│   └── utils/               # Shared utilities
```

## Checklist
- [x] Code compiles without errors
- [x] All API endpoints functional
- [x] Documentation complete
- [x] No sensitive data included
- [x] Follows OpenClaw coding standards

## Screenshots
*(Add dashboard screenshots here)*

## Related Issues
- Closes #(issue-number) - Add token usage monitoring feature
- Related to #(issue-number) - Enhance OpenClaw analytics capabilities

## Deployment Notes
- Requires Node.js v14+
- Environment variables for configuration
- Can be deployed as standalone service or integrated module
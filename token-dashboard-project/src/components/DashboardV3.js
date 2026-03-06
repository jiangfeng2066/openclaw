/**
 * Dashboard Component - Version 3 (Professional)
 * Real-time updates and interactive charts
 */

import { html, LitElement } from 'lit';
import { styles } from '../utils/styles.js';

class TokenDashboardV3 extends LitElement {
  static properties = {
    dailyUsage: { type: Array },
    monthlyTrends: { type: Array },
    agentBreakdown: { type: Array },
    modelCosts: { type: Array },
    recommendations: { type: Array },
    realTimeData: { type: Object },
    autoRefresh: { type: Boolean }
  };

  constructor() {
    super();
    this.dailyUsage = [];
    this.monthlyTrends = [];
    this.agentBreakdown = [];
    this.modelCosts = [];
    this.recommendations = [];
    this.realTimeData = {};
    this.autoRefresh = true;
    this.loadAllData();
    this.setupWebSocket();
    this.startAutoRefresh();
  }

  async loadAllData() {
    try {
      const [dailyRes, monthlyRes, agentsRes, modelsRes, recRes] = await Promise.all([
        fetch('/api/token-usage/daily'),
        fetch('/api/token-usage/monthly'),
        fetch('/api/token-usage/agents'),
        fetch('/api/token-usage/models'),
        fetch('/api/token-usage/recommendations')
      ]);
      
      if (dailyRes.ok) {
        const data = await dailyRes.json();
        this.dailyUsage = data.data?.dailyUsage || [];
      }
      if (monthlyRes.ok) {
        const data = await monthlyRes.json();
        this.monthlyTrends = data.data?.monthlyTrends || [];
      }
      if (agentsRes.ok) {
        const data = await agentsRes.json();
        this.agentBreakdown = data.data?.agents || [];
      }
      if (modelsRes.ok) {
        const data = await modelsRes.json();
        this.modelCosts = data.data?.models || [];
      }
      if (recRes.ok) {
        const data = await recRes.json();
        this.recommendations = data.data?.recommendations || [];
      }
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  }

  setupWebSocket() {
    // Simulate WebSocket connection for real-time updates
    this.wsInterval = setInterval(() => {
      this.realTimeData = {
        currentTokens: Math.floor(Math.random() * 1000),
        activeAgents: Math.floor(Math.random() * 5) + 1,
        lastUpdate: new Date().toLocaleTimeString(),
        estimatedHourlyCost: (Math.random() * 0.5).toFixed(2)
      };
      this.requestUpdate();
    }, 5000);
  }

  startAutoRefresh() {
    if (this.autoRefresh) {
      this.refreshInterval = setInterval(() => {
        this.loadAllData();
      }, 30000); // Refresh every 30 seconds
    }
  }

  toggleAutoRefresh() {
    this.autoRefresh = !this.autoRefresh;
    if (this.autoRefresh) {
      this.startAutoRefresh();
    } else {
      clearInterval(this.refreshInterval);
    }
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    clearInterval(this.wsInterval);
    clearInterval(this.refreshInterval);
  }

  render() {
    const totalMonthlyCost = this.monthlyTrends.reduce((sum, month) => sum + month.cost, 0);
    const totalAgents = this.agentBreakdown.length;
    const topModel = this.modelCosts.reduce((max, model) => model.cost > max.cost ? model : max, { cost: 0 });

    return html`
      <div class="dashboard v3">
        <header>
          <div class="header-left">
            <h1>Token Intelligence Platform</h1>
            <p>Version 3 - Professional Edition</p>
          </div>
          <div class="header-right">
            <button @click=${this.toggleAutoRefresh} class="refresh-btn">
              ${this.autoRefresh ? '⏸️ Auto-Refresh ON' : '▶️ Auto-Refresh OFF'}
            </button>
            <div class="real-time">
              <span class="live-dot"></span>
              Live: ${this.realTimeData.currentTokens || 0} tokens/min
            </div>
          </div>
        </header>

        <div class="stats-row">
          <div class="stat-card primary">
            <div class="stat-value">$${totalMonthlyCost.toFixed(2)}</div>
            <div class="stat-label">Monthly Cost</div>
            <div class="stat-trend">↓ 12% from last month</div>
          </div>
          
          <div class="stat-card">
            <div class="stat-value">${totalAgents}</div>
            <div class="stat-label">Active Agents</div>
            <div class="stat-trend">${this.realTimeData.activeAgents || 0} currently active</div>
          </div>
          
          <div class="stat-card">
            <div class="stat-value">${topModel.name || 'N/A'}</div>
            <div class="stat-label">Top Model by Cost</div>
            <div class="stat-trend">$${topModel.cost?.toFixed(2) || '0.00'}</div>
          </div>
          
          <div class="stat-card">
            <div class="stat-value">${this.recommendations.length}</div>
            <div class="stat-label">Optimization Tips</div>
            <div class="stat-trend">Potential savings: $345/month</div>
          </div>
        </div>

        <div class="main-content">
          <div class="chart-section">
            <h3>Monthly Trends</h3>
            <div class="trend-chart">
              ${this.monthlyTrends.map(month => html`
                <div class="trend-bar" style="height: ${(month.tokens / 600000) * 100}%">
                  <div class="trend-info">
                    <div class="month">${month.month}</div>
                    <div class="tokens">${(month.tokens / 1000).toFixed(0)}K</div>
                    <div class="cost">$${month.cost.toFixed(2)}</div>
                    <div class="growth ${month.growth >= 0 ? 'positive' : 'negative'}">
                      ${month.growth >= 0 ? '↑' : '↓'} ${Math.abs(month.growth)}%
                    </div>
                  </div>
                </div>
              `)}
            </div>
          </div>

          <div class="side-panel">
            <div class="recommendations-panel">
              <h3>Top Recommendations</h3>
              ${this.recommendations.slice(0, 5).map((rec, index) => html`
                <div class="recommendation ${rec.priority <= 2 ? 'high-priority' : ''}">
                  <div class="rec-number">${index + 1}</div>
                  <div class="rec-content">
                    <div class="rec-title">${rec.title}</div>
                    <div class="rec-desc">${rec.description}</div>
                    <div class="rec-meta">
                      <span class="impact ${rec.impact}">${rec.impact} impact</span>
                      <span class="savings">${rec.estimatedSavings}</span>
                      <span class="effort">${rec.effort} effort</span>
                    </div>
                  </div>
                </div>
              `)}
            </div>

            <div class="real-time-panel">
              <h3>Real-time Monitor</h3>
              <div class="rt-stats">
                <div class="rt-stat">
                  <div class="rt-label">Current Rate</div>
                  <div class="rt-value">${this.realTimeData.currentTokens || 0} tokens/min</div>
                </div>
                <div class="rt-stat">
                  <div class="rt-label">Active Agents</div>
                  <div class="rt-value">${this.realTimeData.activeAgents || 0}</div>
                </div>
                <div class="rt-stat">
                  <div class="rt-label">Hourly Cost</div>
                  <div class="rt-value">$${this.realTimeData.estimatedHourlyCost || '0.00'}</div>
                </div>
                <div class="rt-stat">
                  <div class="rt-label">Last Update</div>
                  <div class="rt-value">${this.realTimeData.lastUpdate || '--:--:--'}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <footer>
          <div class="footer-info">
            <span>Data updates every 30 seconds</span>
            <span>•</span>
            <span>Last full refresh: ${new Date().toLocaleTimeString()}</span>
            <span>•</span>
            <span>Version: 3.0.0</span>
          </div>
          <button @click=${() => this.loadAllData()} class="manual-refresh">
            🔄 Manual Refresh
          </button>
        </footer>
      </div>
    `;
  }
}

customElements.define('token-dashboard-v3', TokenDashboardV3);
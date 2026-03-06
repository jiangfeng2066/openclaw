/**
 * Dashboard Component - Version 2 (Advanced)
 * With agent breakdown and model costs
 */

import { html, LitElement } from 'lit';
import { styles } from '../utils/styles.js';

class TokenDashboardV2 extends LitElement {
  static properties = {
    dailyUsage: { type: Array },
    agentBreakdown: { type: Array },
    modelCosts: { type: Array },
    recommendations: { type: Array }
  };

  constructor() {
    super();
    this.dailyUsage = [];
    this.agentBreakdown = [];
    this.modelCosts = [];
    this.recommendations = [];
    this.loadAllData();
  }

  async loadAllData() {
    try {
      const [dailyRes, agentsRes, modelsRes, recRes] = await Promise.all([
        fetch('/api/token-usage/daily'),
        fetch('/api/token-usage/agents'),
        fetch('/api/token-usage/models'),
        fetch('/api/token-usage/recommendations')
      ]);
      
      const dailyData = await dailyRes.json();
      const agentsData = await agentsRes.json();
      const modelsData = await modelsRes.json();
      const recData = await recRes.json();
      
      if (dailyData.success) this.dailyUsage = dailyData.data.dailyUsage;
      if (agentsData.success) this.agentBreakdown = agentsData.data.agents;
      if (modelsData.success) this.modelCosts = modelsData.data.models;
      if (recData.success) this.recommendations = recData.data.recommendations;
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  }

  render() {
    return html`
      <div class="dashboard v2">
        <header>
          <h1>Token Analytics Dashboard</h1>
          <p>Version 2 - Advanced Analytics</p>
        </header>
        
        <div class="grid-layout">
          <div class="panel daily-usage">
            <h3>Daily Token Usage</h3>
            <div class="chart">
              ${this.dailyUsage.map(day => html`
                <div class="chart-bar" style="width: ${(day.tokens / 25000) * 100}%">
                  <span class="date">${day.date}</span>
                  <span class="tokens">${day.tokens.toLocaleString()}</span>
                  <span class="cost">$${day.cost.toFixed(2)}</span>
                </div>
              `)}
            </div>
          </div>
          
          <div class="panel agent-breakdown">
            <h3>Agent Breakdown</h3>
            <div class="pie-chart">
              ${this.agentBreakdown.map(agent => html`
                <div class="slice" style="--percentage: ${agent.percentage}%">
                  <span class="agent-name">${agent.name}</span>
                  <span class="agent-percent">${agent.percentage}%</span>
                </div>
              `)}
            </div>
          </div>
          
          <div class="panel model-costs">
            <h3>Model Cost Analysis</h3>
            <table>
              <thead>
                <tr>
                  <th>Model</th>
                  <th>Tokens</th>
                  <th>Cost</th>
                  <th>Cost/Token</th>
                </tr>
              </thead>
              <tbody>
                ${this.modelCosts.map(model => html`
                  <tr>
                    <td>${model.name}</td>
                    <td>${model.tokens.toLocaleString()}</td>
                    <td>$${model.cost.toFixed(2)}</td>
                    <td>$${model.costPerToken.toFixed(5)}</td>
                  </tr>
                `)}
              </tbody>
            </table>
          </div>
          
          <div class="panel recommendations">
            <h3>Optimization Recommendations</h3>
            <ul>
              ${this.recommendations.slice(0, 3).map(rec => html`
                <li>
                  <strong>${rec.title}</strong>
                  <p>${rec.description}</p>
                  <span class="savings">Save: ${rec.estimatedSavings}</span>
                </li>
              `)}
            </ul>
          </div>
        </div>
      </div>
    `;
  }
}

customElements.define('token-dashboard-v2', TokenDashboardV2);
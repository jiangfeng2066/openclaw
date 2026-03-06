/**
 * Dashboard Component - Version 1 (Basic)
 * Simple token usage overview
 */

import { html, LitElement } from 'lit';
import { styles } from '../utils/styles.js';

class TokenDashboardV1 extends LitElement {
  static properties = {
    dailyUsage: { type: Array },
    totalTokens: { type: Number },
    totalCost: { type: Number }
  };

  constructor() {
    super();
    this.dailyUsage = [];
    this.totalTokens = 0;
    this.totalCost = 0;
    this.loadData();
  }

  async loadData() {
    try {
      const response = await fetch('/api/token-usage/daily');
      const data = await response.json();
      if (data.success) {
        this.dailyUsage = data.data.dailyUsage;
        this.totalTokens = data.data.summary.totalTokens;
        this.totalCost = data.data.summary.totalCost;
      }
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  }

  render() {
    return html`
      <div class="dashboard v1">
        <header>
          <h1>Token Usage Dashboard</h1>
          <p>Version 1 - Basic Overview</p>
        </header>
        
        <div class="summary-cards">
          <div class="card">
            <h3>Total Tokens</h3>
            <div class="value">${this.totalTokens.toLocaleString()}</div>
            <div class="label">Last 5 days</div>
          </div>
          
          <div class="card">
            <h3>Total Cost</h3>
            <div class="value">$${this.totalCost.toFixed(2)}</div>
            <div class="label">USD</div>
          </div>
          
          <div class="card">
            <h3>Avg Daily</h3>
            <div class="value">${(this.totalTokens / 5).toLocaleString()}</div>
            <div class="label">Tokens per day</div>
          </div>
        </div>
        
        <div class="daily-chart">
          <h3>Daily Usage</h3>
          <div class="chart-container">
            ${this.dailyUsage.map(day => html`
              <div class="bar" style="height: ${(day.tokens / 25000) * 100}%">
                <div class="bar-label">${day.date.split('-')[2]}</div>
                <div class="bar-value">${(day.tokens / 1000).toFixed(1)}K</div>
              </div>
            `)}
          </div>
        </div>
      </div>
    `;
  }
}

customElements.define('token-dashboard-v1', TokenDashboardV1);
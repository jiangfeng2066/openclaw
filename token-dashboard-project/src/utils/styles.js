/**
 * Shared styles for dashboard components
 */

export const styles = `
  .dashboard {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
    padding: 20px;
    background: #f8f9fa;
    min-height: 100vh;
  }

  /* Version 1 Styles */
  .dashboard.v1 {
    max-width: 800px;
    margin: 0 auto;
  }

  .dashboard.v1 .summary-cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin: 30px 0;
  }

  .dashboard.v1 .card {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    text-align: center;
  }

  .dashboard.v1 .card h3 {
    margin: 0 0 10px 0;
    color: #666;
    font-size: 14px;
    font-weight: 600;
  }

  .dashboard.v1 .card .value {
    font-size: 32px;
    font-weight: 700;
    color: #2c3e50;
    margin: 10px 0;
  }

  .dashboard.v1 .card .label {
    color: #7f8c8d;
    font-size: 12px;
  }

  .dashboard.v1 .daily-chart {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }

  .dashboard.v1 .chart-container {
    display: flex;
    height: 200px;
    align-items: flex-end;
    gap: 30px;
    padding: 20px 0;
  }

  .dashboard.v1 .bar {
    flex: 1;
    background: linear-gradient(to top, #3498db, #2980b9);
    border-radius: 5px 5px 0 0;
    position: relative;
    min-height: 10px;
  }

  .dashboard.v1 .bar-label {
    position: absolute;
    bottom: -25px;
    left: 0;
    right: 0;
    text-align: center;
    font-size: 12px;
    color: #7f8c8d;
  }

  .dashboard.v1 .bar-value {
    position: absolute;
    top: -25px;
    left: 0;
    right: 0;
    text-align: center;
    font-size: 12px;
    font-weight: 600;
    color: #2c3e50;
  }

  /* Version 2 Styles */
  .dashboard.v2 {
    max-width: 1200px;
    margin: 0 auto;
  }

  .dashboard.v2 .grid-layout {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
    margin: 30px 0;
  }

  .dashboard.v2 .panel {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }

  .dashboard.v2 .panel h3 {
    margin: 0 0 20px 0;
    color: #2c3e50;
    font-size: 16px;
    font-weight: 600;
  }

  .dashboard.v2 .chart {
    height: 150px;
    display: flex;
    align-items: flex-end;
    gap: 10px;
  }

  .dashboard.v2 .chart-bar {
    flex: 1;
    background: linear-gradient(to top, #9b59b6, #8e44ad);
    border-radius: 5px 5px 0 0;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    padding: 5px;
    font-size: 11px;
    color: white;
  }

  .dashboard.v2 .pie-chart {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    background: conic-gradient(
      #e74c3c 0% 32%,
      #3498db 32% 54%,
      #2ecc71 54% 79%,
      #f39c12 79% 100%
    );
    margin: 0 auto;
    position: relative;
  }

  .dashboard.v2 table {
    width: 100%;
    border-collapse: collapse;
  }

  .dashboard.v2 th {
    text-align: left;
    padding: 8px;
    border-bottom: 2px solid #eee;
    color: #7f8c8d;
    font-size: 12px;
    font-weight: 600;
  }

  .dashboard.v2 td {
    padding: 8px;
    border-bottom: 1px solid #eee;
    font-size: 14px;
  }

  /* Version 3 Styles */
  .dashboard.v3 {
    max-width: 1400px;
    margin: 0 auto;
  }

  .dashboard.v3 header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #e0e0e0;
  }

  .dashboard.v3 .header-left h1 {
    margin: 0;
    color: #2c3e50;
    font-size: 28px;
  }

  .dashboard.v3 .header-left p {
    margin: 5px 0 0 0;
    color: #7f8c8d;
    font-size: 14px;
  }

  .dashboard.v3 .refresh-btn {
    background: #3498db;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 14px;
  }

  .dashboard.v3 .real-time {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #27ae60;
    margin-top: 10px;
  }

  .dashboard.v3 .live-dot {
    width: 8px;
    height: 8px;
    background: #27ae60;
    border-radius: 50%;
    animation: pulse 1.5s infinite;
  }

  @keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
  }

  .dashboard.v3 .stats-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 30px;
  }

  .dashboard.v3 .stat-card {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }

  .dashboard.v3 .stat-card.primary {
    background: linear-gradient(135deg, #3498db, #2980b9);
    color: white;
  }

  .dashboard.v3 .stat-value {
    font-size: 32px;
    font-weight: 700;
    margin: 10px 0;
  }

  .dashboard.v3 .stat-label {
    font-size: 14px;
    color: #7f8c8d;
    margin-bottom: 5px;
  }

  .dashboard.v3 .stat-card.primary .stat-label {
    color: rgba(255,255,255,0.9);
  }

  .dashboard.v3 .stat-trend {
    font-size: 12px;
    color: #27ae60;
  }

  .dashboard.v3 .main-content {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 30px;
    margin-bottom: 30px;
  }

  .dashboard.v3 .chart-section,
  .dashboard.v3 .side-panel {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }

  .dashboard.v3 .trend-chart {
    display: flex;
    height: 300px;
    align-items: flex-end;
    gap: 40px;
    padding: 20px 0;
  }

  .dashboard.v3 .trend-bar {
    flex: 1;
    background: linear-gradient(to top, #9b59b6, #8e44ad);
    border-radius: 5px 5px 0 0;
    position: relative;
  }

  .dashboard.v3 .trend-info {
    position: absolute;
    bottom: -80px;
    left: 0;
    right: 0;
    text-align: center;
  }

  .dashboard.v3 .recommendation {
    display: flex;
    gap: 15px;
    padding: 15px;
    margin-bottom: 10px;
    background: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #3498db;
  }

  .dashboard.v3 .recommendation.high-priority {
    border-left-color: #e74c3c;
    background: #fff5f5;
  }

  .dashboard.v3 .rt-stats {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
  }

  .dashboard.v3 .rt-stat {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    text-align: center;
  }

  .dashboard.v3 footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
    color: #7f8c8d;
    font-size: 14px;
  }
`;
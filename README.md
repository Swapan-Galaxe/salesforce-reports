# Salesforce Reports - Deployment Guide

## Quick Deploy
```bash
deploy.bat
```

## Manual Steps
```bash
# 1. Login
sf org login web --alias myorg

# 2. Deploy
sf project deploy start --source-dir force-app

# 3. Test
sf apex run test --tests AnalyticsQueryBuilderTest --result-format human

# 4. Run Analytics
sf apex run --file test-analytics.apex

# 5. Schedule Reports
sf apex run --file schedule-job.apex

# 6. Open Org
sf org open
```

## Components
- **AnalyticsQueryBuilder.cls** - SOQL queries for revenue, pipeline, sales trends
- **ReportDistributionScheduler.cls** - Automated email reports with CSV
- **ReportGenerator.cls** - Programmatic report creation
- **salesDashboard (LWC)** - Dashboard component for Lightning pages

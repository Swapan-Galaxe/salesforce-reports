// Schedule Weekly Report Distribution
System.schedule('Weekly Sales Report', '0 0 8 ? * MON', new ReportDistributionScheduler());
System.debug('Report distribution scheduled successfully for every Monday at 8 AM');

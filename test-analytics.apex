// Test Analytics Query Builder
List<AggregateResult> revenueResults = AnalyticsQueryBuilder.getRevenueByIndustry();
System.debug('=== Revenue by Industry ===');
for (AggregateResult ar : revenueResults) {
    System.debug(ar.get('Industry') + ': $' + ar.get('totalRevenue') + ' (' + ar.get('accountCount') + ' accounts)');
}

List<AggregateResult> pipelineResults = AnalyticsQueryBuilder.getPipelineByStage();
System.debug('\n=== Pipeline by Stage ===');
for (AggregateResult ar : pipelineResults) {
    System.debug(ar.get('StageName') + ': $' + ar.get('totalAmount') + ' (' + ar.get('oppCount') + ' opportunities)');
}

List<AggregateResult> topReps = AnalyticsQueryBuilder.getTopSalesReps(5);
System.debug('\n=== Top 5 Sales Reps ===');
for (AggregateResult ar : topReps) {
    System.debug(ar.get('ownerName') + ': $' + ar.get('totalRevenue') + ' (' + ar.get('wonDeals') + ' deals)');
}

List<AggregateResult> monthlyTrend = AnalyticsQueryBuilder.getMonthlySalesTrend();
System.debug('\n=== Monthly Sales Trend ===');
for (AggregateResult ar : monthlyTrend) {
    System.debug('Month ' + ar.get('month') + ': $' + ar.get('revenue'));
}

public class AnalyticsQueryBuilder {
    public static List<AggregateResult> getRevenueByMonth() {
        return [SELECT CALENDAR_MONTH(CloseDate) month, SUM(Amount) revenue FROM Opportunity WHERE StageName = 'Closed Won' GROUP BY CALENDAR_MONTH(CloseDate)];
    }
    
    public static List<AggregateResult> getPipelineByStage() {
        return [SELECT StageName, COUNT(Id) cnt, SUM(Amount) total FROM Opportunity WHERE IsClosed = false GROUP BY StageName];
    }
    
    public static List<AggregateResult> getSalesTrends() {
        return [SELECT Owner.Name ownerName, COUNT(Id) deals, SUM(Amount) revenue FROM Opportunity WHERE CloseDate = THIS_YEAR GROUP BY Owner.Name];
    }
}
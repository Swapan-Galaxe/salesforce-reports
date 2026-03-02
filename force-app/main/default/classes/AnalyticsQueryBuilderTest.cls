@isTest
public class AnalyticsQueryBuilderTest {
    @testSetup
    static void setup() {
        Opportunity opp = new Opportunity(Name='Test', StageName='Closed Won', 
                                          CloseDate=Date.today(), Amount=1000);
        insert opp;
    }
    
    @isTest
    static void testRevenueByMonth() {
        Test.startTest();
        List<AggregateResult> results = AnalyticsQueryBuilder.getRevenueByMonth();
        Test.stopTest();
        System.assertNotEquals(null, results);
    }
    
    @isTest
    static void testPipelineByStage() {
        List<AggregateResult> results = AnalyticsQueryBuilder.getPipelineByStage();
        System.assertNotEquals(null, results);
    }
    
    @isTest
    static void testSalesTrends() {
        List<AggregateResult> results = AnalyticsQueryBuilder.getSalesTrends();
        System.assertNotEquals(null, results);
    }
}

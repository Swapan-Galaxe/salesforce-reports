public class ReportDistributionScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<AggregateResult> data = AnalyticsQueryBuilder.getRevenueByMonth();
        String csv = 'Month,Revenue\n';
        for (AggregateResult ar : data) {
            csv += ar.get('month') + ',' + ar.get('revenue') + '\n';
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'admin@example.com'});
        email.setSubject('Monthly Revenue Report');
        email.setPlainTextBody('See attached CSV report.');
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('revenue-report.csv');
        attachment.setBody(Blob.valueOf(csv));
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}
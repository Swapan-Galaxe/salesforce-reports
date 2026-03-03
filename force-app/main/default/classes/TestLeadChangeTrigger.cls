@isTest
private class TestLeadChangeTrigger {
     
    static testmethod void testLeadChange() {
        //Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
         
        //Insert a Lead test record
        Insert new Lead(FirstName = 'Test',
                        LastName = 'Lead33',
                        Company = 'Salesforce');
        //Call deliver to fire the trigger and deliver the test change event.
        Test.getEventBus().deliver();
         
        //Update Lead record
        Lead leadRecord = [SELECT Id, FirstName, LastName, Company FROM Lead LIMIT 1];
        leadRecord.Company = 'salesforce';
        Update leadRecord;
        //Call deliver to fire the trigger for the update operation.
        Test.getEventBus().deliver();
         
        //Delete Lead record
        Delete leadRecord;
        //Call deliver to fire the trigger for the delete operation.
        Test.getEventBus().deliver();
         
        //Undelete Lead record
        Lead deletedLead = [SELECT Id, IsDeleted FROM Lead WHERE Id = :leadRecord.Id ALL ROWS];
        Undelete deletedLead;
        //Call deliver to fire the trigger for the undelete operation.
        Test.getEventBus().deliver();
    }
}
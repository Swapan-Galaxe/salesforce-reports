public with sharing class ContactController {
        @AuraEnabled(cacheable=true)
        public static Contact getSingleContact() {
            return [
                SELECT Id, Name, Title, Phone, Email
                FROM Contact
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }

        @AuraEnabled(cacheable=true)
        public static List<Contact> getContacts(String accId) {
            return [
                SELECT AccountId, Id, FirstName, LastName, Title, Phone, Email
                FROM Contact
                WHERE AccountId = :accId
                WITH SECURITY_ENFORCED
            ];
        }

    @AuraEnabled(cacheable=true)
    public static string getContentVersion(Id docId){
        return [
            SELECT Id, IsLatest, Title, ContentDocumentId 
            FROM ContentVersion 
            WHERE ContentDocumentId=:docId AND isLatest=true
            LIMIT 1
        ].Id;
    }

    @AuraEnabled( cacheable = true )
    public static List<Contact> fetchContacts(String recordId) {
        return [SELECT Id, AccountId, FirstName, LastName, Email FROM Contact WHERE AccountId =:recordId LIMIT 100];
    }
 
    // Method to perform DML operations (insert/update/delete) on Contact records
    @AuraEnabled
    public static string dmlOnContacts(Object data, String removeContactIds) {
        List<Contact> updateContact = (List<Contact>) JSON.deserialize(JSON.serialize(data), List<Contact>.class);
        List<Contact> deleteContact = new List<Contact>();
 
        if(String.isNotBlank(removeContactIds)){
            List<Id> contactIds = removeContactIds.split(',');
            deleteContact = [SELECT Id FROM Contact WHERE Id IN :contactIds];
        }
 
        try {
            if(updateContact != null && !updateContact.isEmpty()){
                upsert updateContact;
            }
 
            if(deleteContact != null && !deleteContact.isEmpty()){    
                delete deleteContact;
            }
            return 'Success: Contact(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
       // return '';
    }
}
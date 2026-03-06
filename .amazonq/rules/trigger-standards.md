# Apex Trigger Standards

When creating or modifying Apex triggers, ALWAYS follow these rules:

## Trigger Template
Use this ONE TRIGGER per object pattern:

```apex
/**
 * @description Trigger for Account object
 * @author Your Name
 * @date 2024-01-01
 */
trigger AccountTrigger on Account (before insert, before update, after insert, after update, after delete, after undelete) {
    new AccountTriggerHandler().run();
}
```

## Handler Class Template
ALL logic goes in handler class:

```apex
/**
 * @description Handler for AccountTrigger
 * @author Your Name
 * @date 2024-01-01
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {
    
    private List<Account> newRecords;
    private List<Account> oldRecords;
    private Map<Id, Account> newRecordsMap;
    private Map<Id, Account> oldRecordsMap;
    
    public AccountTriggerHandler() {
        this.newRecords = (List<Account>) Trigger.new;
        this.oldRecords = (List<Account>) Trigger.old;
        this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        validateRecords(newRecords);
        setDefaultValues(newRecords);
    }
    
    public override void beforeUpdate() {
        validateRecords(newRecords);
        updateRelatedFields(newRecords, oldRecordsMap);
    }
    
    public override void afterInsert() {
        createRelatedRecords(newRecords);
    }
    
    public override void afterUpdate() {
        List<Account> changedAccounts = getRecordsWithFieldChange('Status__c');
        if (!changedAccounts.isEmpty()) {
            processStatusChange(changedAccounts);
        }
    }
    
    public override void afterDelete() {
        cleanupRelatedRecords(oldRecords);
    }
    
    // Private helper methods
    private void validateRecords(List<Account> accounts) {
        for (Account acc : accounts) {
            if (String.isBlank(acc.Name)) {
                acc.addError('Name is required');
            }
        }
    }
    
    private void setDefaultValues(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.Status__c == null) {
                acc.Status__c = 'Active';
            }
        }
    }
    
    private List<Account> getRecordsWithFieldChange(String fieldName) {
        List<Account> changedRecords = new List<Account>();
        for (Account acc : newRecords) {
            Object newValue = acc.get(fieldName);
            Object oldValue = oldRecordsMap?.get(acc.Id)?.get(fieldName);
            if (newValue != oldValue) {
                changedRecords.add(acc);
            }
        }
        return changedRecords;
    }
    
    private void createRelatedRecords(List<Account> accounts) {
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : accounts) {
            contactsToInsert.add(new Contact(
                FirstName = 'Default',
                LastName = 'Contact',
                AccountId = acc.Id
            ));
        }
        if (!contactsToInsert.isEmpty()) {
            Database.insert(contactsToInsert, AccessLevel.USER_MODE);
        }
    }
    
    private void processStatusChange(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        if (!accountIds.isEmpty()) {
            // Call service class for complex logic
            AccountService.handleStatusChange(accountIds);
        }
    }
    
    private void cleanupRelatedRecords(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        List<Contact> contactsToDelete = [
            SELECT Id FROM Contact 
            WHERE AccountId IN :accountIds 
            WITH USER_MODE
            LIMIT 10000
        ];
        if (!contactsToDelete.isEmpty()) {
            Database.delete(contactsToDelete, AccessLevel.USER_MODE);
        }
    }
}
```

## Base TriggerHandler Class
Create this ONCE for all triggers:

```apex
/**
 * @description Base class for all trigger handlers
 * @author Your Name
 * @date 2024-01-01
 */
public virtual class TriggerHandler {
    
    // Bypass mechanism
    private static Set<String> bypassedHandlers = new Set<String>();
    
    public void run() {
        if (isBypassed()) {
            return;
        }
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) beforeInsert();
            if (Trigger.isUpdate) beforeUpdate();
            if (Trigger.isDelete) beforeDelete();
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) afterInsert();
            if (Trigger.isUpdate) afterUpdate();
            if (Trigger.isDelete) afterDelete();
            if (Trigger.isUndelete) afterUndelete();
        }
    }
    
    // Virtual methods to override
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}
    
    // Bypass mechanism
    public static void bypass(String handlerName) {
        bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        bypassedHandlers.remove(handlerName);
    }
    
    public static void clearAllBypasses() {
        bypassedHandlers.clear();
    }
    
    private Boolean isBypassed() {
        return bypassedHandlers.contains(getHandlerName());
    }
    
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
}
```

## Trigger Best Practices

### ✅ DO
```apex
// One trigger per object
trigger AccountTrigger on Account (before insert, after update) { }

// Use handler pattern
new AccountTriggerHandler().run();

// Bulkify - process all records at once
Set<Id> accountIds = new Set<Id>();
for (Account acc : Trigger.new) {
    accountIds.add(acc.Id);
}

// Check field changes before processing
if (acc.Status__c != oldMap.get(acc.Id).Status__c) {
    // Process change
}

// Use addError() for validation
acc.addError('Validation failed');

// Query outside loops
Map<Id, Contact> contactMap = new Map<Id, Contact>(
    [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]
);
```

### ❌ DON'T
```apex
// Multiple triggers per object
trigger AccountTrigger1 on Account (before insert) { }
trigger AccountTrigger2 on Account (after update) { }

// Logic directly in trigger
trigger AccountTrigger on Account (before insert) {
    for (Account acc : Trigger.new) {
        // Don't put logic here!
    }
}

// SOQL in loops
for (Account acc : Trigger.new) {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
}

// DML in loops
for (Account acc : Trigger.new) {
    insert new Contact(AccountId = acc.Id);
}

// Hardcoded IDs
if (acc.RecordTypeId == '012000000000000') { }
```

## Recursion Prevention

```apex
public class TriggerHelper {
    private static Set<Id> processedIds = new Set<Id>();
    
    public static Boolean isFirstRun(Id recordId) {
        if (processedIds.contains(recordId)) {
            return false;
        }
        processedIds.add(recordId);
        return true;
    }
    
    public static void reset() {
        processedIds.clear();
    }
}

// Usage in handler
public override void afterUpdate() {
    List<Account> accountsToProcess = new List<Account>();
    for (Account acc : newRecords) {
        if (TriggerHelper.isFirstRun(acc.Id)) {
            accountsToProcess.add(acc);
        }
    }
    processAccounts(accountsToProcess);
}
```

## Test Class Template

```apex
@isTest
private class AccountTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
    }
    
    @isTest
    static void testBeforeInsert() {
        // Given
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'New Account ' + i));
        }
        
        // When
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        // Then
        List<Account> results = [SELECT Id, Status__c FROM Account WHERE Name LIKE 'New Account%'];
        Assert.areEqual(200, results.size());
        Assert.areEqual('Active', results[0].Status__c, 'Default status should be set');
    }
    
    @isTest
    static void testAfterUpdate() {
        // Given
        List<Account> accounts = [SELECT Id, Status__c FROM Account LIMIT 200];
        for (Account acc : accounts) {
            acc.Status__c = 'Inactive';
        }
        
        // When
        Test.startTest();
        update accounts;
        Test.stopTest();
        
        // Then
        List<Account> results = [SELECT Id, Status__c FROM Account];
        Assert.areEqual('Inactive', results[0].Status__c);
    }
    
    @isTest
    static void testValidation() {
        // Given
        Account acc = new Account(); // No name
        
        // When/Then
        Exception caughtException;
        Test.startTest();
        try {
            insert acc;
            Assert.fail('Should throw validation error');
        } catch (DmlException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        Assert.isNotNull(caughtException, 'Exception should be thrown');
        Assert.isTrue(caughtException.getMessage().contains('Name is required'));
    }
    
    @isTest
    static void testBypass() {
        // Given
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 1];
        
        // When
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        accounts[0].Name = 'Updated';
        update accounts;
        TriggerHandler.clearAllBypasses();
        Test.stopTest();
        
        // Then - trigger logic was bypassed
        Assert.areEqual('Updated', [SELECT Name FROM Account WHERE Id = :accounts[0].Id].Name);
    }
}
```

## Modern Apex in Triggers (Spring '24 - Spring '26)
```apex
// ✅ User Mode SOQL/DML (API 58+)
List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId IN :accountIds WITH USER_MODE];
Database.insert(contacts, AccessLevel.USER_MODE);

// ✅ Null-safe navigation (API 60+)
String city = account?.BillingAddress?.city;
String ownerName = account?.Owner?.Name ?? 'Unknown';

// ✅ Collection filtering (API 62+ / Spring '26)
List<Account> changedAccounts = newRecords.filter(acc => 
    acc.Status__c != oldRecordsMap.get(acc.Id).Status__c
);

// ✅ Pattern matching for record types (API 62+)
String action = switch on acc.Type {
    when 'Customer' => 'customer-workflow'
    when 'Partner' => 'partner-workflow'
    when else => 'default-workflow'
};
```

## Required Checklist
Every trigger MUST have:
- [ ] ONE trigger per object
- [ ] Handler class with all logic
- [ ] Extends TriggerHandler base class
- [ ] Bulkified (processes all records at once)
- [ ] No SOQL/DML in loops
- [ ] Field change detection before processing
- [ ] Recursion prevention if needed
- [ ] Test class with 200+ records
- [ ] Test all trigger contexts (before/after insert/update)
- [ ] Bypass mechanism for testing

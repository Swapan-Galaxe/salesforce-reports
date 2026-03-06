# Apex Development Standards

When creating or modifying Apex classes, ALWAYS follow these rules:

## Class Template
Use this structure for ALL Apex classes:

```apex
/**
 * @description Brief description of class purpose
 * @author Your Name
 * @date 2024-01-01
 */
public with sharing class ClassName {
    
    // Constants
    private static final Integer MAX_RECORDS = 200;
    private static final String ERROR_MESSAGE = 'Error occurred';
    
    /**
     * @description Method description
     * @param paramName Description of parameter
     * @return Description of return value
     */
    public static ReturnType methodName(ParamType paramName) {
        // Validate input
        if (paramName == null) {
            throw new IllegalArgumentException('Parameter cannot be null');
        }
        
        try {
            // Implementation
            return result;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
            throw e;
        }
    }
}
```

## Security - ALWAYS Use
```apex
// ✅ Use with sharing (enforces record-level security)
public with sharing class SecureClass { }

// ✅ Use inherited sharing for utility classes (API 46+)
public inherited sharing class UtilityClass { }

// ✅ User Mode SOQL (API 58+ / Spring '24) - PREFERRED
List<Account> accounts = [SELECT Id, Name FROM Account WITH USER_MODE];

// ✅ User Mode DML (API 58+ / Spring '24) - PREFERRED
Database.insert(accounts, AccessLevel.USER_MODE);
Database.update(accounts, AccessLevel.USER_MODE);
Database.delete(accounts, AccessLevel.USER_MODE);

// ✅ System Mode when needed (explicit)
List<Account> accounts = [SELECT Id, Name FROM Account WITH SYSTEM_MODE];
Database.insert(accounts, AccessLevel.SYSTEM_MODE);

// ✅ Legacy: Security.stripInaccessible (API 40+) - Use only if API < 58
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE, 
    [SELECT Id, Name FROM Account]
);
return decision.getRecords();
```

## Performance - Bulkify Everything
```apex
// ✅ CORRECT - Query outside loop
Map<Id, Account> accountMap = new Map<Id, Account>(
    [SELECT Id, Name FROM Account WHERE Id IN :accountIds LIMIT 200]
);
for (Id accId : accountIds) {
    Account acc = accountMap.get(accId);
}

// ✅ CORRECT - DML outside loop
List<Account> accountsToUpdate = new List<Account>();
for (Account acc : accounts) {
    acc.Status__c = 'Active';
    accountsToUpdate.add(acc);
}
Database.SaveResult[] results = Database.update(accountsToUpdate, false);

// ❌ NEVER do this
for (Account acc : accounts) {
    update acc; // DML in loop!
}
```

## DML - Always Handle Errors
```apex
// ✅ Use Database methods for partial success
public static void safeInsert(List<Account> accounts) {
    Database.SaveResult[] results = Database.insert(accounts, false);
    
    for (Database.SaveResult sr : results) {
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                System.debug('Error: ' + err.getMessage());
            }
        }
    }
}

// ✅ Use try-catch for critical operations
try {
    insert accounts;
} catch (DmlException e) {
    System.debug(LoggingLevel.ERROR, e.getMessage());
    throw new CustomException('Failed to insert accounts');
}
```

## Test Class Template
ALWAYS create test class with this structure:

```apex
@isTest
private class ClassNameTest {
    
    @TestSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;
    }
    
    @isTest
    static void testPositiveScenario() {
        // Given
        List<Account> accounts = [SELECT Id FROM Account LIMIT 200];
        
        // When
        Test.startTest();
        ClassName.methodName(accounts);
        Test.stopTest();
        
        // Then
        List<Account> results = [SELECT Id, Status__c FROM Account];
        Assert.areEqual(200, results.size(), 'Should process all records');
        Assert.areEqual('Active', results[0].Status__c, 'Status should be Active');
    }
    
    @isTest
    static void testNegativeScenario() {
        // Test error handling
        Exception caughtException;
        Test.startTest();
        try {
            ClassName.methodName(null);
            Assert.fail('Should throw exception');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
        
        Assert.isNotNull(caughtException, 'Exception should be thrown');
        Assert.isTrue(caughtException.getMessage().contains('null'));
    }
    
    @isTest
    static void testBulkScenario() {
        // Test with 200 records
        List<Account> accounts = [SELECT Id FROM Account];
        
        Test.startTest();
        ClassName.methodName(accounts);
        Test.stopTest();
        
        Assert.areEqual(200, [SELECT COUNT() FROM Account]);
    }
}
```

## Naming Conventions
- Classes: `AccountService`, `ContactController`
- Methods: `calculateRevenue()`, `processRecords()`
- Variables: `accountName`, `recordCount`
- Constants: `MAX_RECORDS`, `DEFAULT_STATUS`
- Collections: `accounts`, `contactsById`, `uniqueNames`

## Modern Apex Features (Spring '24 - Spring '26)
```apex
// ✅ User Mode for automatic security enforcement (API 58+)
List<Account> accounts = [SELECT Id, Name FROM Account WITH USER_MODE];
Database.insert(accounts, AccessLevel.USER_MODE);

// ✅ System Mode when needed (API 58+)
List<Account> accounts = [SELECT Id, Name FROM Account WITH SYSTEM_MODE];
Database.insert(accounts, AccessLevel.SYSTEM_MODE);

// ✅ Null-safe navigation (API 60+ / Spring '25)
String city = account?.BillingAddress?.city;
Integer size = accountList?.size();

// ✅ Null coalescing operator (API 60+ / Spring '25)
String name = account.Name ?? 'Default Name';
Integer count = recordCount ?? 0;

// ✅ Collection filtering (API 62+ / Spring '26)
List<Account> activeAccounts = accounts.filter(acc => acc.IsActive__c == true);
List<String> names = accounts.map(acc => acc.Name);
Integer total = opportunities.reduce(0, (sum, opp) => sum + opp.Amount);

// ✅ Pattern matching (API 62+ / Spring '26)
String result = switch on recordType {
    when 'Customer' => 'Process as customer'
    when 'Partner' => 'Process as partner'
    when else => 'Unknown type'
};

// ✅ Record types (API 62+ / Spring '26)
public record AccountInfo(String name, Decimal revenue, Boolean isActive) { }
AccountInfo info = new AccountInfo('Acme', 100000, true);
```

## Required Checklist
Every Apex class MUST have:
- [ ] `with sharing` or `inherited sharing` keyword
- [ ] Use WITH USER_MODE in SOQL (API 58+)
- [ ] Use AccessLevel.USER_MODE in DML (API 58+)
- [ ] No SOQL/DML in loops
- [ ] LIMIT clause in queries
- [ ] Try-catch for DML operations
- [ ] Input validation
- [ ] JavaDoc comments on public methods
- [ ] Test class with 200+ records
- [ ] Test.startTest() and Test.stopTest()
- [ ] Assert class methods (API 56+)
- [ ] Use modern Apex features (null-safe, collections) when possible

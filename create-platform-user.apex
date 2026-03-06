// Run: sf apex run --file create-platform-user.apex -o myorg

Profile platformProfile = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce Platform' AND Name LIKE '%Standard%' LIMIT 1];
UserRole superUserRole = [SELECT Id FROM UserRole WHERE Name = 'MDL Super User' LIMIT 1];

User testUser = new User(
    FirstName = 'Test',
    LastName = 'MDLSuperUser',
    Email = 'test.mdlsuperuser@example.com',
    Username = 'test.mdlsuperuser@example.com.sandbox',
    Alias = 'tmdlsu',
    TimeZoneSidKey = 'America/New_York',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US',
    ProfileId = platformProfile.Id,
    UserRoleId = superUserRole.Id
);
insert testUser;

// Assign permission set
PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'MDL_Super_User_Permissions' LIMIT 1];
insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = testUser.Id);

System.debug('User created: ' + testUser.Username);

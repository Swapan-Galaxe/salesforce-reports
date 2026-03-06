// Run: sf apex run --file create-mdl-user.apex -o myorg

Profile mdlProfile = [SELECT Id FROM Profile WHERE Name = 'MDLive' LIMIT 1];
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
    ProfileId = mdlProfile.Id,
    UserRoleId = superUserRole.Id
);
insert testUser;

System.debug('User created: ' + testUser.Username);
